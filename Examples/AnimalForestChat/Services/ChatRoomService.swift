//
//  ChatService.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

import PubNub

class ChatRoomService: NSObject {
  // MARK: Types
  /// Tuple containing UUIDs for users that have `joined` and `left` chat
  typealias PresenceChange = (joined: [String], left: [String])

  /// Defines the connection state of a chat room
  ///
  /// - connected:    Chat room is connection and emitting events
  /// - notConnected: Chat room is not connected and no longer active
  enum ConnectionState {
    /// Chat room is connection and emitting events
    case connected
    /// Chat room is not connected and no longer active
    case notConnected
  }

  /// Defines an event received for a chat room
  ///
  /// - message:  A message sent or received on the chat room
  /// - users:    User(s) joined or left the chat room
  /// - status:   Status event of chat room
  enum ChatRoomEvent {
    /// A message sent or received on the chat room
    case messages(Result<[Message], NSError>)
    /// User(s) presence on the chat room changed
    case users(Result<PresenceChange, NSError>)
    /// Status event of chat room
    case status(Result<ConnectionState, NSError>)
  }

  typealias Listener = (ChatRoomEvent) -> Void

  // MARK: Public Properties
  /// A closure executed when the chat room changes.
  var listener: Listener?
  /// The user sending messages
  private(set) var sender: User
  /// The room being tracked by the service
  private(set) var room: ChatRoom

  // MARK: Private Properties
  private var _occupantUUIDs = Set<String>()
  private var _messages = [Message]()
  private var latestSentDate: Date?
  private var chatProvider: ChatProvider

  // MARK: Private Queues
  private let presenceQueue = DispatchQueue(label: "ChatRoomService Presence Queue",
                                            qos: .userInitiated, attributes: .concurrent)
  private let messageQueue = DispatchQueue(label: "ChatRoomService Message Queue",
                                           qos: .userInitiated, attributes: .concurrent)
  private let providerQueue = DispatchQueue(label: "ChatRoomService Provider Queue")
  private let eventQueue = DispatchQueue(label: "ChatRoomService Event Queue")

  init(for sender: User,
       in chatRoom: ChatRoom = ChatRoom.defaultValue,
       with provider: ChatProvider = PubNub.configure()) {
    self.sender = sender
    self.room = chatRoom
    self.chatProvider = provider

    super.init()
  }

  // MARK: - Thread Safe Collections
  /// List of `User` identifiers that are connected to the chat room
  var occupantUUIDs: [String] {
    var users = Set<String>()

    presenceQueue.sync {
      users = self._occupantUUIDs
    }

    return Array(users)
  }

  /// List of `Message` values that are associted with the chat room
  var messages: [Message] {
    var messages = [Message]()

    messageQueue.sync {
      messages = self._messages
    }

    return messages
  }

  /// Total users connected to the chat room
  var occupancy: Int {
    return occupantUUIDs.count
  }

  /// Connection state of the chat room
  var state: ConnectionState {
    return chatProvider.isSubscribed(on: room.uuid) ? .connected : .notConnected
  }

// tag::SUB-1[]
  // MARK: - Service Stop/Start
  /// Connects to, and starts listening for changes on, the chat room.
  func start() {
    if !chatProvider.isSubscribed(on: room.uuid) {
      chatProvider.add(self)
      chatProvider.subscribe(to: room.uuid)
    } else {
      // Already connected, so return connected
      emit(.status(.success(.connected)))
    }
  }

  /// Disconnects from, and stops listening for changes on, the chat room.
  func stop() {
    chatProvider.unsubscribe(from: room.uuid)
    chatProvider.remove(self)
  }
// end::SUB-1[]

  // MARK: - Public Methods
// tag::PUB-1[]
  /// Publish a message to the service's chat room
  /// - parameter text: The text to be published
  func publish(_ text: String, completion: @escaping (Result<Message, NSError>) -> Void) -> Message {
    let sendDate = Date()

    let message = Message(uuid: UUID().uuidString,
                          text: text,
                          sentDate: sendDate,
                          senderId: sender.uuid, roomId: room.uuid)

    let request = ChatPublishRequest(roomId: room.uuid, message: message)

    providerQueue.async { [weak self] in
      self?.chatProvider.publish(request) { (result) in
        switch result {
        case .success:
          completion(.success(message))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }

    messageQueue.async(flags: .barrier) { [weak self] in
      self?._messages.append(message)
      self?.emit(.messages(.success([message])))
    }

    return message
  }
// end::PUB-1[]

// tag::HIST-1[]
  /// Fetch the message history of the service's chat room
  func fetchMessageHistory() {
    var params = ChatHistoryParameters()

    // Search for any messages that we might have missed from our last token
    if let date = self.latestSentDate {
      params.start = date
      params.reverse = true
    }

    let historyRequest = ChatHistoryRequest(roomId: room.uuid, parameters: params)

    providerQueue.async { [weak self] in
      self?.chatProvider.history(historyRequest) { [weak self] (result) in
        switch result {
        case .success(let response):
          guard let response = response else {
            self?.emit(.messages(.success([])))
            return
          }

          self?.messageQueue.async(flags: .barrier) {
            self?.latestSentDate = response.end

            self?._messages.append(contentsOf: response.messages)

            self?.emit(.messages(.success(response.messages)))
          }
        case .failure(let error):
          NSLog("Error getting message history: \(error.debugDescription)")
          self?.emit(.messages(.failure(error)))
        }
      }
    }
  }
// end::HIST-1[]

// tag::HERE-1[]
  /// Fetch the current connected users of the service's chat room
  func fetchCurrentUsers() {
    let roomID = room.uuid

    providerQueue.async { [weak self] in
      self?.chatProvider.presence(for: roomID) { [weak self] (result) in
        switch result {
        case .success(let response):
          guard let response = response else {
            // Signal that the occupants list has changes
            self?.emit(.users(.success(([], []))))
            return
          }

          self?.presenceQueue.async(flags: .barrier) { [weak self] in
            var joinedList = [String]()
            // Verify our knownledge of the room
            for uuid in response.uuids {
              let value = self?._occupantUUIDs.insert(uuid)
              // Ensure we only notify changes from existing list
              if let wasAdded = value?.inserted, wasAdded {
                joinedList.append(uuid)
              }
            }

            // Signal that the occupants list has changes
            self?.emit(.users(.success((joinedList, []))))
          }

        case .failure(let error):
          NSLog("Error getting current chat room members: \(error.debugDescription)")
          self?.emit(.users(.failure(error)))
        }
      }
    }
  }
// end::HERE-1[]

  // MARK: Event Listeners
  /// Processes messages received on the chat room
  func didReceive(message response: ChatMessageEvent) {

    guard let message = response.message else {
      NSLog("Error: Received Message Event missing message body")
      return
    }

    NSLog("Received Message \(message) from \(message.sender.displayName)")

    messageQueue.async(flags: .barrier) { [weak self] in
      // Determine if this device already added this published message
      if let strongSelf = self,
        message.senderId == strongSelf.sender.uuid,
        strongSelf._messages.contains(message) {
          NSLog("Message was already notified on this device")

          return
      }

      self?.latestSentDate = message.sentDate

      self?._messages.append(message)

      self?.emit(.messages(.success([message])))
    }
  }

  /// Processes status changes received on the chat room
  func didReceive(status event: Result<ChatStatusEvent, NSError>) {
    switch event {
    case .success(let response):
      NSLog("Status Change Received: \(response.status)")

      switch response.status {
      case "Connected":
        emit(.status(.success(.connected)))
      case "Expected Disconnect":
        emit(.status(.success(.notConnected)))
      default:
        NSLog("Category \(response.status) was not processed.")
      }

    case .failure(let error):
      NSLog("Error Status Change Received: \(error)")
      emit(.status(.failure(error)))
    }
  }

  /// Processes user presence changes received on the chat room
  func didReceive(presence response: ChatPresenceEvent) {
    presenceQueue.async(flags: .barrier) { [weak self] in

      var count = 0
      for uuid in response.joined {
        self?._occupantUUIDs.insert(uuid)
        count += 1
      }
      for uuid in response.timedout {
        self?._occupantUUIDs.remove(uuid)
        count -= 1
      }
      for uuid in response.left {
        self?._occupantUUIDs.remove(uuid)
        count -= 1
      }

      self?.emit(.users(.success((response.joined, response.timedout+response.left))))
    }
  }

  // MARK: - Private Methods
  private func emit(_ event: ChatRoomEvent) {
    eventQueue.async { [weak self] in
      self?.listener?(event)
    }
  }
}

// MARK: - PNObjectEventListener Extension
// tag::EVENT-0[]
extension ChatRoomService: PNObjectEventListener {
  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    didReceive(message: message)
  }

  func client(_ client: PubNub, didReceive status: PNStatus) {
    if let error = status.error {
      didReceive(status: .failure(error))
    } else {
      didReceive(status: .success(status))
    }
  }

  func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
    didReceive(presence: event)
  }
}
// end::EVENT-0[]
