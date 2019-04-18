//
//  ChatService.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

import PubNub

class ChatService: NSObject {

  enum ChatState {
    case connected
    case notConnected
  }

  enum ChatEvent {
    case message(Int)
    case presence(Int)
    case status(ChatState)
  }

  let channel: String
  var state: ChatState = .notConnected

  private(set) var occupancy: Int = 0
  private var _occupantUUIDs = Set<String>()
  private var _messages = [Message]()

  private var latestTimetoken: NSNumber?

  typealias Listener = (ChatEvent) -> Void

  var listener: Listener?

  var chatProvider: ChatProvider

  private let presenceQueue = DispatchQueue(label: "ChatService Presence Queue",
                                            qos: .userInitiated, attributes: .concurrent)
  private let messageQueue = DispatchQueue(label: "ChatService Message Queue",
                                           qos: .userInitiated, attributes: .concurrent)
  private let eventQueue = DispatchQueue(label: "ChatService Event Queue")

  init(with chatType: ChatProvider, on channel: String) {
    self.chatProvider = chatType
    self.channel = channel

    super.init()
  }

  // MARK: - Thread Safe Collections
  var occupantUUIDs: Set<String> {
    var users = Set<String>()

    presenceQueue.sync {
      users = self._occupantUUIDs
    }

    return users
  }

  var messages: [Message] {
    var messages = [Message]()

    messageQueue.sync {
      messages = self._messages
    }

    return messages
  }

// tag::SUB-1[]
  // MARK: - Service Stop/Start
  func start() {
    chatProvider.add(self)
  }

  func stop() {
    chatProvider.remove(self)
  }

  func joinChannel() {
    if !chatProvider.isSubscribed(on: channel) {
      chatProvider.subscribe(to: [channel], withPresence: true)
    }
  }

  func leaveChannel() {
    chatProvider.unsubscribe(from: [channel], withPresence: true)
  }
// end::SUB-1[]

  // MARK: - Public (Internal) Methods

// tag::PUB-1[]
  func publish(_ message: String, completion: @escaping (Result<Message, NSError>) -> Void) -> Message {
    let request = ChatPublishRequest(channel: channel, message: message, senderId: chatProvider.uuid)
    let sendDate = Date()

    let message = Message(uuid: sendDate.timeToken.description,
                          text: message,
                          senderId: chatProvider.uuid,
                          sentDate: sendDate)

    chatProvider.publish(request) { (result) in
      switch result {
      case .success:
        completion(.success(message))
      case .failure(let error):
        completion(.failure(error))
      }
    }

    messageQueue.async(flags: .barrier) { [weak self] in
      self?._messages.append(message)
    }

    return message
  }
// end::PUB-1[]

// tag::HIST-1[]
  func getChannelHistory() {

    // TODO: Check local cache for any archived messages
    var params = ChatHistoryParameters()
    if let timetoken = self.latestTimetoken {
      // Previous received timestoken
      params.start = timetoken
    }

    let historyRequest = ChatHistoryRequest(channel: channel, parameters: params)

    chatProvider.history(historyRequest) { [weak self] (result) in
      switch result {
      case .success(let response):
        guard let response = response else {
          return
        }

        self?.messageQueue.async(flags: .barrier) {
          self?.latestTimetoken = response.end.timeToken

          self?._messages.append(contentsOf: response.messages)

          self?.eventQueue.async {
            self?.listener?(.message(response.messages.count))
          }
        }
      case .failure(let error):
        NSLog("Error getting message history: \(error.debugDescription)")
      }
    }
  }
// end::HIST-1[]

// tag::HERE-1[]
  func getChannelOccupancy() {
    chatProvider.hereNow(for: channel) { [weak self] (result) in
      switch result {
      case .success(let response):
        guard let response = response else {
          return
        }

        self?.presenceQueue.async(flags: .barrier) {
          // Verify our knownledge of the room
          for uuid in response.uuids {
              self?._occupantUUIDs.insert(uuid)
          }

          // Update Static Occupancy Count
          self?.occupancy = response.occupancy

          if self?._occupantUUIDs.count != self?.occupancy {
            NSLog("There is a mismatch between the occupancy count and the occupants list")
          }

          // Signal that the occupants list has changes
          self?.eventQueue.async {
            self?.listener?(.presence(response.occupancy))
          }
        }

      case .failure(let error):
        NSLog("Error getting current channel members: \(error.debugDescription)")
      }
    }
  }
// end::HERE-1[]

  // MARK: - Private Methods
  private func didConnect() {
    state = .connected

    // Get History
    getChannelHistory()

    // Get HereNow
    getChannelOccupancy()

    eventQueue.async { [weak self] in
      self?.listener?(.status(.connected))
    }
  }

  private func didDisconnect() {
    state = .notConnected

    eventQueue.async { [weak self] in
      self?.listener?(.status(.notConnected))
    }
  }

  private func didReceive(message response: ChatMessageEvent) {
    NSLog("Received Message \(String(describing: response.message)) from \(response.message?.sender.displayName ?? "")")

    guard self.channel == response.channel,
          let message = response.message else {
      return
    }

    messageQueue.async(flags: .barrier) { [weak self] in
      // TODO: Find a good way to only filter out messages sent from this device.
      // Determine if we've alrady added this published message
      if let strongSelf = self, message.senderId == strongSelf.chatProvider.uuid {
        NSLog("Message was already published by this user")

        return
      }
      self?.latestTimetoken = message.sentDate.timeToken

      self?._messages.append(message)

      self?.eventQueue.async {
        self?.listener?(.message(1))
      }
    }
  }

  private func didReceive(status event: Result<ChatStatusEvent, Error>) {
    switch event {
    case .success(let response):
      NSLog("Status Change Received: \(response.status)")

      switch response.status {
      case "Connected":
        didConnect()
      case "Expected Disconnect":
        didDisconnect()
      default:
        NSLog("Category \(response.status) was not processed.")
      }

    case .failure(let error):
      NSLog("Error Status Change Received: \(error)")
    }
  }

  private func didReceive(presence response: ChatPresenceEvent) {
    guard self.channel == response.channel else {
      return
    }

    presenceQueue.async(flags: .barrier) { [weak self] in
      self?.occupancy = response.occupancy

      if let state = response.state {
        NSLog("State-Change Presence Received: \(state) for \(response)")
      }

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

      self?.eventQueue.async {
        if response.refreshNow {
          DispatchQueue.main.async {
            self?.getChannelOccupancy()
          }
        }

        self?.listener?(.presence(count))
      }
    }
  }
}

// tag::SERV-1[]
// MARK: - PNObjectEventListener Extension
extension ChatService: PNObjectEventListener {
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
// end::SERV-1[]
