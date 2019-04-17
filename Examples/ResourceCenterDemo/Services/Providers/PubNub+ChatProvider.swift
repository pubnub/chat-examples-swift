//
//  PubNub+ChatProvider.swift
//  RCDemo
//
//  Created by Craig Lane on 4/17/19.
//

import Foundation

import PubNub

extension PNPresenceChannelHereNowResult: ChatChannelPresenceResponse {
  var occupancy: Int {
    return data.occupancy.intValue
  }

  var uuids: [String] {
    guard let payload = data.uuids as? [[String: Any]] else {
      return []
    }

    return decode(payload)
  }

  func decode(_ payload: [[String: Any]]) -> [String] {

    var uuids = [String]()

    for item in payload {
      if let uuid = item["uuid"] as? String {
        uuids.append(uuid)
      }
    }

    return uuids
  }
}

extension PNPublishStatus: ChatPublishRepsonse {
  var sentAt: Date {
    return Date.from(data.timetoken)
  }

  var responseMessage: String {
    return data.information
  }
}

extension PNHistoryResult: ChatHistoryRepsonse {
  var start: Date {
    return Date.from(data.start)
  }

  var end: Date {
    return Date.from(data.end)
  }

  var messages: [Message] {
    guard let payload = data.messages as? [[String: Any]] else {
      return []
    }

    return decode(payload)
  }

  func decode(_ messages: [[String: Any]]) -> [Message] {

    var response = [Message]()

    for message in messages {
      guard let payload = message["message"] as? [String: String],
        let senderId = payload["senderId"],
        let timeToken = message["timetoken"] as? NSNumber,
        let text = payload["text"] else {
          continue
      }

      response.append(
        Message(uuid: senderId,
                text: text,
                senderId: senderId,
                sentDate: Date.from(timeToken)))
    }

    return response
  }
}

extension PubNub: ChatProvider {
  // MARK: - ChatRequester
  var uuid: String {
    return self.uuid()
  }

  func publish(_ request: ChatPublishRequest, completion: @escaping (Result<ChatPublishRepsonse, NSError>) -> Void) {
    publish(request.message,
            toChannel: request.channel,
            mobilePushPayload: request.parameters.mobilePushPayload,
            storeInHistory: request.parameters.storeInHistory,
            compressed: request.parameters.compressed,
            withMetadata: request.parameters.metadata)
    { (status) in
      // swiftlint:disable:previous opening_brace
      if let error = status.error {
        completion(.failure(error))
      } else {
        completion(.success(status))
      }
    }
  }

  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryRepsonse?, NSError>) -> Void) {

    historyForChannel(request.channel,
                      start: request.parameters.start,
                      end: request.parameters.end,
                      limit: request.parameters.limit,
                      reverse: request.parameters.reverse,
                      includeTimeToken: request.parameters.includeTimeToken)
    { (result, status) in
      // swiftlint:disable:previous opening_brace
      if let error = status?.error {
        completion(.failure(error))
      } else if let result = result {
        completion(.success(result))
      }
    }
  }

  func hereNow(for channel: String, completion: @escaping  (Result<ChatChannelPresenceResponse?, NSError>) -> Void) {
    // PNHereNowCompletionBlock
    hereNowForChannel(channel) { (result, status) in
      if let error = status?.error {
        completion(.failure(error))
      } else if let result = result {
        completion(.success(result))
      }
    }
  }

  // MARK: - ChatEmitter
  func add(_ listener: AnyObject) {
    guard let pnObjectListener = listener as? PNObjectEventListener else {
      return
    }

    addListener(pnObjectListener)
  }

  func remove(_ listener: AnyObject) {
    guard let pnObjectListener = listener as? PNObjectEventListener else {
      return
    }
    removeListener(pnObjectListener)
  }

  func subscribe(to channels: [String], withPresence: Bool) {
    self.subscribeToChannels(channels, withPresence: withPresence)
  }

  func unsubscribe(from channels: [String], withPresence: Bool) {
    self.unsubscribeFromChannels(channels, withPresence: withPresence)
  }
}

extension PNStatus: ChatStatusEvent {
  var status: String {
    return stringifiedCategory()
  }

  var request: String {
    return stringifiedOperation()
  }
}

extension PNPresenceEventResult: ChatPresenceEvent {
  var channel: String {
    return data.channel
  }

  var occupancy: Int {
    return data.presence.occupancy.intValue
  }

  var joined: [String] {
    var joined = [String]()
    if data.presenceEvent == "join", let uuid = data.presence.uuid {
      joined.append(uuid)
    }
    if let joins = data.presence.join {
      for uuid in joins {
        joined.append(uuid)
      }
    }

    return joined
  }

  var timedout: [String] {
    var timeout = [String]()
    if data.presenceEvent == "timeout", let uuid = data.presence.uuid {
      timeout.append(uuid)
    }
    if let joins = data.presence.timeout {
      for uuid in joins {
        timeout.append(uuid)
      }
    }

    return timeout
  }

  var left: [String] {
    var left = [String]()
    if data.presenceEvent == "leave", let uuid = data.presence.uuid {
      left.append(uuid)
    }
    if let joins = data.presence.leave {
      for uuid in joins {
        left.append(uuid)
      }
    }

    return left
  }

  var refreshNow: Bool {
    return false
  }

  var state: [String: Any]? {
    return data.presence.state
  }
}

extension PNMessageResult: ChatMessageEvent {
  var channel: String {
    return data.channel
  }
  var message: Message? {
    guard let payload = data.message as? [String: Any?] else {
      return nil
    }

    return decode(payload)
  }
  func decode(_ payload: [String: Any?]) -> Message? {
    guard let text = payload["text"] as? String,
      let senderId = payload["senderId"] as? String else {
        return nil
    }

    return Message(uuid: data.timetoken.description,
                   text: text,
                   senderId: senderId,
                   sentDate: Date.from(data.timetoken))
  }
}
