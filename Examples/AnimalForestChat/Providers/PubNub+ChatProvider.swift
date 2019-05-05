//
//  PubNub+ChatProvider.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/17/19.
//

import Foundation

// tag::WRAP-1[]
import PubNub

// tag::ignore[]
// swiftlint:disable opening_brace
// end::ignore[]
extension PubNub: ChatProvider {
  func send(_ request: ChatMessageRequest, completion: @escaping (Result<ChatMessageResponse, NSError>) -> Void) {
    publish(request.message,
            toChannel: request.roomId,
            mobilePushPayload: request.parameters.mobilePushPayload,
            storeInHistory: request.parameters.storeInHistory,
            compressed: request.parameters.compressed,
            withMetadata: request.parameters.metadata)
    { (status) in
      if let error = status.error {
        completion(.failure(error))
      } else {
        completion(.success(status))
      }
    }
  }
// end::WRAP-1[]

  // tag::WRAP-2[]
  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryResponse?, NSError>) -> Void) {
    var startToken: NSNumber?
    if let start = request.parameters.start {
      startToken = NSNumber(value: start)
    }

    historyForChannel(request.roomId,
                      start: startToken,
                      end: nil,
                      limit: request.parameters.limit,
                      reverse: request.parameters.reverse,
                      includeTimeToken: request.parameters.includeTimeToken)
    { (result, status) in
      if let error = status?.error {
        completion(.failure(error))
      } else {
        completion(.success(result))
      }
    }
  }
  // end::WRAP-2[]

  // tag::WRAP-3[]
  func presence(for roomId: String, completion: @escaping  (Result<ChatRoomPresenceResponse?, NSError>) -> Void) {
    hereNowForChannel(roomId) { (result, status) in
      if let error = status?.error {
        completion(.failure(error))
      } else {
        completion(.success(result))
      }
    }
  }
  // end::WRAP-3[]

  var senderID: String {
    return self.uuid()
  }

  // tag::WRAP-4[]
  var eventEmitter: ChatEventProvider {
    let chatListener = ChatEventProvider.default
    self.addListener(chatListener)

    return chatListener
  }
  // end::WRAP-4[]

  // tag::WRAP-5[]
  func subscribe(to roomId: String) {
    self.subscribeToChannels([roomId], withPresence: true)
  }

  func unsubscribe(from roomId: String) {
    self.unsubscribeFromChannels([roomId], withPresence: true)
  }
}
// end::WRAP-5[]
// swiftlint:enable opening_brace

// MARK: Listener Extension
// tag::EMIT-1[]
extension ChatEventProvider: PNObjectEventListener {
  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    listener?(.message(message))
  }

  func client(_ client: PubNub, didReceive status: PNStatus) {
    if let error = status.error {
      listener?(.status(.failure(error)))
    } else {
      listener?(.status(.success(status)))
    }
  }

  func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
    listener?(.presence(event))
  }
}
// end::EMIT-1[]

// MARK: Request Responses
extension PNPresenceChannelHereNowResult: ChatRoomPresenceResponse {
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

extension PNPublishStatus: ChatMessageResponse {
  var sentAt: Int64 {
    return data.timetoken.int64Value
  }

  var responseMessage: String {
    return data.information
  }
}

// tag::WRAP-1[]
extension PNHistoryResult: ChatHistoryResponse {
  // tag::ignore[]
  var start: Int64 {
    return data.start.int64Value
  }

  var end: Int64 {
    return data.end.int64Value
  }
  // end::ignore[]

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
        let timeToken = message["timetoken"] as? Int64,
        let text = payload["text"],
        // /v2/history/sub-key/{sub_key}/channel/{channel}
        let roomId = clientRequest?.url?.lastPathComponent else {
          continue
      }

      response.append(
        Message(uuid: payload["uuid"] ?? UUID().uuidString,
                text: text,
                sentAt: timeToken,
                senderId: senderId,
                roomId: roomId))
    }

    return response
  }
}
// end::WRAP-1[]

// MARK: Listener Responses
// tag::EVENT-1[]
extension PNMessageResult: ChatMessageEvent {
  var roomId: String {
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

    return Message(uuid: payload["uuid"] as? String ?? UUID().uuidString,
                   text: text,
                   sentAt: data.timetoken.int64Value,
                   senderId: senderId,
                   roomId: data.channel)
  }
}
// end::EVENT-1[]

// tag::EVENT-2[]
extension PNPresenceEventResult: ChatPresenceEvent {
  var roomId: String {
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

    if let timeouts = data.presence.timeout {
      for uuid in timeouts {
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
    if let leavers = data.presence.leave {
      for uuid in leavers {
        left.append(uuid)
      }
    }

    return left
  }
}
// end::EVENT-2[]

// tag::EVENT-3[]
extension PNStatus: ChatStatusEvent {
  var status: String {
    return stringifiedCategory()
  }

  var request: String {
    return stringifiedOperation()
  }
}
// end::EVENT-3[]
