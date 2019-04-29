//
//  Mock+ChatProvider.swift
//  AnimalForestChatTests
//
//  Created by Craig Lane on 4/25/19.
//

import Foundation
// tag::TEST-1[]
@testable import AnimalForestChat

class MockChatProvider: ChatProvider {
  // tag::ignore[]
  var listenerValue = 0
  var subscribedRoomId: String?
  // end::ignore[]
  var publishError: NSError?
  var publishResponse = MockPublishResponse()
  // tag::ignore[]
  var roomPresenceError: NSError?
  var roomPresenceResponse: MockRoomPresenceResponse?

  var roomHistoryError: NSError?
  var roomHistoryResponse: MockRoomHistoryResponse?
  // end::ignore[]
  func publish(_ request: ChatPublishRequest, completion: @escaping (Result<ChatPublishResponse, NSError>) -> Void) {
    if let error = publishError {
      completion(.failure(error))
    } else {
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

  func add(_ listener: AnyObject) {
    listenerValue += 1
  }

  func remove(_ listener: AnyObject) {
    listenerValue -= 1
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

struct MockPublishResponse: ChatPublishResponse {
  var sentAt = Date()
  var responseMessage = "Response String"
}

struct MockRoomPresenceResponse: ChatRoomPresenceResponse {
  var occupancy: Int
  var uuids: [String]
}

struct MockRoomHistoryResponse: ChatHistoryResponse {
  var start: Date
  var end: Date
  var messages: [Message]
}

struct MockMessageEvent: ChatMessageEvent {
  var roomId: String
  var message: Message?
}

struct MockStatusEvent: ChatStatusEvent {
  var status: String
  var request: String
}

struct MockPresenceEvent: ChatPresenceEvent {
  var roomId: String
  var occupancy: Int
  var joined: [String]
  var timedout: [String]
  var left: [String]
}
