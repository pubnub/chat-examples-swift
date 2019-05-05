//
//  ChatService.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

// tag::INIT-0[]
import PubNub

class ChatRoomService {
  // tag::ignore[]
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
  /// - presence:    User(s) joined or left the chat room
  /// - status:   Status event of chat room
  enum ChatRoomEvent {
    /// A message sent or received on the chat room
    case messages(Result<[Message], NSError>)
    /// User(s) presence on the chat room changed
    case presence(Result<PresenceChange, NSError>)
    /// Status event of chat room
    case status(Result<ConnectionState, NSError>)
  }

  typealias Listener = (ChatRoomEvent) -> Void

  // MARK: Public Properties
  /// A closure executed when the chat room changes.
  var listener: Listener?
  /// The room being tracked by the service
  private(set) var room: ChatRoom

  // MARK: Private Properties
  private var chatProvider: ChatProvider

  private var _occupantUUIDs = Set<String>()
  private var _messages = [Message]()

  // MARK: Private Queues
  private let presenceQueue = DispatchQueue(label: "ChatRoomService Presence Queue",
                                            qos: .userInitiated, attributes: .concurrent)
  private let messageQueue = DispatchQueue(label: "ChatRoomService Message Queue",
                                           qos: .userInitiated, attributes: .concurrent)
  private let providerQueue = DispatchQueue(label: "ChatRoomService Provider Queue")
  private let eventQueue = DispatchQueue(label: "ChatRoomService Event Queue")

  private let historyRequestQueue = DispatchQueue(label: "ChatRoomService History Request Queue")
  private let historyRequestGroup = DispatchGroup()
  // end::ignore[]
  init(for chatRoom: ChatRoom = ChatRoom.defaultValue,
       with provider: ChatProvider = PubNub.configure()) {
    self.room = chatRoom
    self.chatProvider = provider

    // Enable the chat listener
    self.chatProvider.eventEmitter.listener = chatListener
  }

  deinit {
    chatProvider.unsubscribe(from: room.uuid)
  }
// end::INIT-0[]
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

  var latestSentAt: Int64? {
    return messages.last?.sentAt
  }

  /// Connection state of the chat room
  var state: ConnectionState {
    return chatProvider.isSubscribed(on: room.uuid) ? .connected : .notConnected
  }

  /// The user sending messages
  var sender: User? {
    return User.firstStored(with: { $0.uuid == chatProvider.senderID })
  }

// tag::SUB-1[]
  // MARK: - Service Stop/Start
  /// Connects to, and starts listening for changes on, the chat room.
  func start() {
    if !chatProvider.isSubscribed(on: room.uuid) {
      chatProvider.subscribe(to: room.uuid)
    } else {
      // Already connected
      emit(.status(.success(.connected)))
    }
  }

  /// Disconnects from, and stops listening for changes on, the chat room.
  func stop() {
    chatProvider.unsubscribe(from: room.uuid)
    emit(.status(.success(.notConnected)))
  }
// end::SUB-1[]

  // MARK: - Public Methods
// tag::PUB-1[]
  /// Send a message to the service's chat room
  /// - parameter text: The text to be published
  func send(_ text: String, completion: @escaping (Result<Message, NSError>) -> Void) {
    let sentAtValue = Date().timeIntervalAsImpreciseToken

    let message = Message(uuid: UUID().uuidString,
                          text: text,
                          sentAt: sentAtValue,
                          senderId: chatProvider.senderID,
                          roomId: room.uuid)

    let request = ChatMessageRequest(roomId: room.uuid, message: message)

    providerQueue.async { [weak self] in
      self?.chatProvider.send(request) { (result) in
        switch result {
        case .success:
          completion(.success(message))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
// end::PUB-1[]

// tag::HIST-1[]
  /// Fetch the message history of the service's chat room
  func fetchMessageHistory() {
    let roomID = room.uuid
    historyRequestQueue.async { [weak self] in
      // Start of our request operation
      self?.historyRequestGroup.enter()

      var params = ChatHistoryParameters()
      // Search for any messages that we might have missed from our last token
      if let sentAtValue = self?.latestSentAt {
        // Search starting after our last message
        params.start = sentAtValue
        params.reverse = true
      }

      let historyRequest = ChatHistoryRequest(roomId: roomID, parameters: params)

      self?.chatProvider.history(historyRequest) { [weak self] (result) in
        switch result {
        case .success(let response):
          guard let response = response else {
            self?.emit(.messages(.success([])))
            return
          }

          NSLog("Fetching Message History found \(response.messages.count) messages.")
          self?.add(response.messages)
        case .failure(let error):
          NSLog("Error getting message history: \(error.debugDescription)")
          self?.emit(.messages(.failure(error)))
        }
        // Request has been completed
        self?.historyRequestGroup.leave()
      }
      // Waits synchronously for the previously request to finish.
      self?.historyRequestGroup.wait()
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
            self?.emit(.presence(.success(([], []))))
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
            self?.emit(.presence(.success((joinedList, []))))
          }

        case .failure(let error):
          NSLog("Error getting current chat room members: \(error.debugDescription)")
          self?.emit(.presence(.failure(error)))
        }
      }
    }
  }
// end::HERE-1[]

  // MARK: Event Listeners
  /// Processes messages received on the chat room
  private func didReceive(message response: ChatMessageEvent) {
    guard let message = response.message else {
      NSLog("Error: Received Message Event missing message body")
      return
    }

    self.add([message])
  }

  /// Processes status changes received on the chat room
  private func didReceive(status event: Result<ChatStatusEvent, NSError>) {
    switch event {
    case .success(let response):
      NSLog("Status Change Received: \(response.status)")

      switch response.status {
      case "Connected":
        emit(.status(.success(.connected)))
      case "Expected Disconnect", "Unexpected Disconnect":
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
  private func didReceive(presence response: ChatPresenceEvent) {
    presenceQueue.async(flags: .barrier) { [weak self] in

      for uuid in response.joined {
        self?._occupantUUIDs.insert(uuid)
      }
      for uuid in response.timedout {
        self?._occupantUUIDs.remove(uuid)
      }
      for uuid in response.left {
        self?._occupantUUIDs.remove(uuid)
      }

      self?.emit(.presence(.success((response.joined, response.timedout+response.left))))
    }
  }

  // MARK: - Private Methods
  private func emit(_ event: ChatRoomEvent) {
    eventQueue.async { [weak self] in
      self?.listener?(event)
    }
  }

  private func add(_ messages: [Message]) {
    messageQueue.async(flags: .barrier) { [weak self] in
      // Determine if this device already added this published message
      for message in messages {
        if self?._messages.contains(message) ?? true {
          NSLog("Duplicate message found: \(message.uuid) was already added on this device")
          continue
        }
        self?._messages.append(message)
      }

      self?._messages.sort(by: { $0.sentAt < $1.sentAt })

      self?.emit(.messages(.success(messages)))
    }
  }

  private var chatListener: ChatEventProvider.Listener {
    return { [weak self] (event) in
      switch event {
      case .message(let message):
        self?.didReceive(message: message)
      case .presence(let event):
        self?.didReceive(presence: event)
      case .status(let result):
        self?.didReceive(status: result)
      }
    }
  }
}
