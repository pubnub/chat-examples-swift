//
//  PubNub+ChatProvider.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/17/19.
//

import Foundation

// tag::WRAP-0[]
import PubNub
// end::WRAP-0[]

// swiftlint:disable opening_brace
// tag::WRAP-1[]
extension PubNub: ChatProvider {
  func publish(_ request: ChatPublishRequest, completion: @escaping (Result<ChatPublishResponse, NSError>) -> Void) {
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
    historyForChannel(request.roomId,
                      start: request.parameters.start?.timeToken,
                      end: request.parameters.end?.timeToken,
                      limit: request.parameters.limit,
                      reverse: request.parameters.reverse,
                      includeTimeToken: request.parameters.includeTimeToken)
    { (result, status) in
      if let error = status?.error {
        completion(.failure(error))
      } else if let result = result {
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
      } else if let result = result {
        completion(.success(result))
      }
    }
  }
  // end::WRAP-3[]

  // tag::WRAP-4[]
  func add(_ listener: AnyObject) {
    // Verify that we're passing the correct object type
    guard let pnObjectListener = listener as? PNObjectEventListener else {
      return
    }

    addListener(pnObjectListener)
  }

  func remove(_ listener: AnyObject) {
    // Verify that we're passing the correct object type
    guard let pnObjectListener = listener as? PNObjectEventListener else {
      return
    }
    removeListener(pnObjectListener)
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

extension PNPublishStatus: ChatPublishResponse {
  var sentAt: Date {
    return Date.from(data.timetoken)
  }

  var responseMessage: String {
    return data.information
  }
}

// tag::WRAP-1[]
extension PNHistoryResult: ChatHistoryResponse {
  // tag::ignore[]
  var start: Date {
    return Date.from(data.start)
  }

  var end: Date {
    return Date.from(data.end)
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
        let timeToken = message["timetoken"] as? NSNumber,
        let text = payload["text"],
        // /v2/history/sub-key/{sub_key}/channel/{channel}
        let roomId = clientRequest?.url?.lastPathComponent else {
          continue
      }

      response.append(
        Message(uuid: message["uuid"] as? String ?? UUID().uuidString,
                text: text,
                sentDate: Date.from(timeToken),
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
                   sentDate: Date.from(data.timetoken),
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
