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

  // MARK: - Public (Internal) Methods
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
        // ["start": result?.data.start, "end": result?.data.end, "messages": result?.data.messages]
        self?.messageQueue.async(flags: .barrier) {
          if let messages = response["messages"] as? [[String: Any]] {
            if let endToken = response["end"] as? NSNumber {
              self?.latestTimetoken = endToken
            }

            var count = 0
            for  message in messages {
              if let payload = message["message"] as? [String: String],
                let senderId = payload["senderId"],
                let timeToken = message["timetoken"] as? NSNumber,
                let text = payload["text"] {
                count += 1

                // Verify that the message isn't already inside the messages list
                self?._messages.append(Message(uuid: timeToken.description,
                                              text: text,
                                              senderId: senderId,
                                              sentDate: Date.from(timeToken)))
              }
            }

            self?.eventQueue.async {
              self?.listener?(.message(count))
            }
          }
        }
      case .failure(let error):
        NSLog("Error getting message history: \(error.debugDescription)")
      }
    }
  }

  func getChannelOccupancy() {
    chatProvider.hereNow(for: channel) { [weak self] (result) in
      switch result {
      case .success(let response):
        // ["start": result?.data.start, "end": result?.data.end, "messages": result?.data.messages]
        guard let occupancy = response["occupancy"] as? Int, let uuids = response["uuids"] as? [[String: Any]] else {
          return
        }
        self?.presenceQueue.async(flags: .barrier) {
          // Verify our knownledge of the room
          for uuid in uuids {
            if let uuid = uuid["uuid"] as? String {
              self?._occupantUUIDs.insert(uuid)
            }
          }

          // Update Static Occupancy Count
          self?.occupancy = occupancy

          if self?._occupantUUIDs.count != self?.occupancy {
            NSLog("There is a mismatch between the occupancy count and the occupants list")
          }

          // Signal that the occupants list has changes
          self?.eventQueue.async {
            self?.listener?(.presence(occupancy))
          }
        }

      case .failure(let error):
        NSLog("Error getting current channel members: \(error.debugDescription)")
      }
    }
  }

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

  private func didReceive(message: [String: Any?], on channel: String) {
    NSLog("Received Message \(message)")

    guard self.channel == channel,
          let timetoken = message["timeToken"] as? NSNumber,
          let text = message["text"] as? String,
          let senderId = message["senderId"] as? String else {
      return
    }

    let message = Message(uuid: timetoken.description,
                          text: text,
                          senderId: senderId,
                          sentDate: Date.from(timetoken))

    messageQueue.async(flags: .barrier) { [weak self] in
      // TODO: Find a good way to only filter out messages sent from this device.
      // Determine if we've alrady added this published message
      if let strongSelf = self, senderId == strongSelf.chatProvider.uuid {
        NSLog("Message was already published by this user")

        return
      }
      self?.latestTimetoken = timetoken

      self?._messages.append(message)

      self?.eventQueue.async {
        self?.listener?(.message(1))
      }
    }
  }

  private func didReceive(status event: Result<[String: String], Error>) {
    switch event {
    case .success(let status):
      NSLog("Status Change Received: \(status)")
      guard let category = status["category"] else {
        return
      }

      switch category {
      case "Connected":
        didConnect()
      case "Expected Disconnect":
        didDisconnect()
      default:
        NSLog("Category \(category) was not processed.")
      }

    case .failure(let error):
      NSLog("Error Status Change Received: \(error)")
    }
  }

  private func didReceive(presence event: [String: Any?], on channel: String) {
    NSLog("Presence Event Received: \(event)")
    guard self.channel == channel,
          let occupancy = event["occupancy"] as? Int,
          let presenceEvent = event["eventType"] as? String else {
      return
    }

    presenceQueue.async(flags: .barrier) { [weak self] in
      self?.occupancy = occupancy

      let uuid = event["uuid"] as? String ?? ""
      var count = 0
      switch presenceEvent {
      case "state-change":
          NSLog("State-Change Presence Received: \(String(describing: event["state"] as? [String: Any])) for \(uuid)")
      case "join":
        self?._occupantUUIDs.insert(uuid)
        count += 1
      case "leave", "timeout":
        self?._occupantUUIDs.remove(uuid)
        count -= 1
      case "interval":
        if let timeouts = event["timeout"] as? [String] {
          timeouts.forEach {
            self?._occupantUUIDs.remove($0)
            count -= 1
          }
        }
        if let leaves = event["leave"] as? [String] {
          leaves.forEach {
            self?._occupantUUIDs.remove($0)
            count -= 1
          }
        }
        if let joins = event["join"] as? [String] {
          joins.forEach {
            self?._occupantUUIDs.insert($0)
            count += 1
          }
        }
      default:
        break
      }

      self?.eventQueue.async { [weak self] in
        if !(event["hereNowRefresh"] as? Bool ?? false) {
          DispatchQueue.main.async {
            self?.getChannelOccupancy()
          }
        } else {
          self?.listener?(.presence(count))
        }
      }
    }
  }
}

// MARK: - PNObjectEventListener Extension
extension ChatService: PNObjectEventListener {
  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    if message.data.channel == channel, var payload = message.data.message as? [String: Any?] {

      payload["timeToken"] = message.data.timetoken

      didReceive(message: payload, on: message.data.channel)
    }
  }

  func client(_ client: PubNub, didReceive status: PNStatus) {
    if let error = status.error {
      didReceive(status: .failure(error))
    } else {
      didReceive(status: .success(["category": status.stringifiedCategory(),
                                   "operation": status.stringifiedOperation()]))
    }
  }

  func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
    let payload: [String: Any?] = [
      "occupancy": event.data.presence.occupancy.intValue,
      "uuid": event.data.presence.uuid,
      "eventType": event.data.presenceEvent,
      "state": event.data.presence.state,
      "timeout": event.data.presence.timeout,
      "leave": event.data.presence.leave,
      "join": event.data.presence.join,
      // TODO: What to read for here_now_refresh value?
      "hereNowRefresh": false
    ]

    didReceive(presence: payload, on: event.data.channel)
  }
}
