//
//  Mock+ChatProvider.swift
//  AnimalForestChatTests
//
//  Created by Craig Lane on 4/25/19.
//

import Foundation
// tag::TEST-1[]
// Mock+ChatProvider.swift
@testable import AnimalForestChat

class MockChatProvider: ChatProvider {
// tag::ignore[]
  var senderIdValue = ""

  var listenerValue = 0
  var subscribedRoomId: String?
// end::ignore[]
  var publishError: NSError?
  var publishResponse = MockPublishResponse()

  var messageEvent: ChatMessageEvent?

// tag::ignore[]
  var roomPresenceError: NSError?
  var roomPresenceResponse: MockRoomPresenceResponse?

  var roomHistoryError: NSError?
  var roomHistoryResponse: MockRoomHistoryResponse?

  var senderID: String {
    return senderIdValue
  }

// end::ignore[]
  func send(_ request: ChatMessageRequest, completion: @escaping (Result<ChatMessageResponse, NSError>) -> Void) {
    if let error = publishError {
      completion(.failure(error))
    } else {
      if let event = messageEvent {
        eventEmitter.listener?(.message(event))
      }
      completion(.success(publishResponse))
    }
  }
// tag::ignore[]
  func history(_ request: ChatHistoryRequest, completion: @escaping (Result<ChatHistoryResponse?, NSError>) -> Void) {
    if let error = roomHistoryError {
      completion(.failure(error))
    } else {
      completion(.success(roomHistoryResponse))
    }
  }

  func presence(for room: String, completion: @escaping (Result<ChatRoomPresenceResponse?, NSError>) -> Void) {
    if let error = roomPresenceError {
      completion(.failure(error))
    } else {
      completion(.success(roomPresenceResponse))
    }
  }

  var eventEmitter: ChatEventProvider {
    return ChatEventProvider.default
  }

  func isSubscribed(on roomId: String) -> Bool {
    return subscribedRoomId == roomId
  }

  func subscribe(to roomId: String) {
    subscribedRoomId = roomId
  }

  func unsubscribe(from roomId: String) {
    subscribedRoomId = nil
  }
// end::ignore[]
}
// end::TEST-1[]

struct MockPublishResponse: ChatMessageResponse {
  var sentAt: Int64 = 1234567890
  var responseMessage = "Response String"
}

struct MockRoomPresenceResponse: ChatRoomPresenceResponse {
  var occupancy: Int
  var uuids: [String]
}

struct MockRoomHistoryResponse: ChatHistoryResponse {
  var start: Int64
  var end: Int64
  var messages: [Message]
}

struct MockMessageEvent: ChatMessageEvent {
  var roomId: String
  var message: Message?
}

struct MockStatusEvent: ChatStatusEvent {
  var response: StatusResponse
  var request: RequestType
}

struct MockPresenceEvent: ChatPresenceEvent {
  var roomId: String
  var occupancy: Int
  var joined: [String]
  var timedout: [String]
  var left: [String]
}
