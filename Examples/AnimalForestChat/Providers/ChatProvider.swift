//
//  ChatProvider.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 3/14/19.
//

import Foundation

// tag::WRAP-1[]
protocol ChatProvider {
  /// Send a message to a chat room
  func send(_ request: ChatMessageRequest, completion: @escaping  (Result<ChatMessageResponse, NSError>) -> Void)
  // end::WRAP-1[]

  // tag::WRAP-2[]
  /// Get the message history of a chat room
  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryResponse?, NSError>) -> Void)
  // end::WRAP-2[]

  // tag::WRAP-3[]
  /// Get the current users online in a chat room
  func presence(for roomId: String, completion: @escaping  (Result<ChatRoomPresenceResponse?, NSError>) -> Void)
  // end::WRAP-3[]

  /// The user sending messages
  var senderID: String { get }

  // tag::WRAP-4[]
  /// Add listener delegate
  func add(_ listener: AnyObject)
  /// Remove listener delegate
  func remove(_ listener: AnyObject)
  // end::WRAP-4[]

  // tag::WRAP-5[]
  /// Start receiving changes on a chat room
  /// - parameter roomId: Identifier for the room
  /// - returns: Whether the room is currently being observed
  func subscribe(to roomId: String)
  /// Stop receiving changes on a chat room
  /// - parameter roomId: Identifier for the room
  func unsubscribe(from roomId: String)
  // end::WRAP-5[]

  // tag::WRAP-6[]
  /// Are changes to a room currently being observed
  /// - parameter roomId: Identifier for the room
  func isSubscribed(on roomId: String) -> Bool
}
// end::WRAP-6[]

// MARK: Publish Request/Response
struct ChatMessageRequest {
  /// Identifier of room being published on
  var roomId: String
  /// Key/Value payload of the text message
  var message: [String: String]
  /// Request parameters
  var parameters: ChatPublishParameters

  init(roomId: String,
       message: Message,
       parameters: ChatPublishParameters = ChatPublishParameters())
  {
    // swiftlint:disable:previous opening_brace
    self.message = ["senderId": message.senderId,
                    "text": message.text,
                    "uuid": message.uuid]
    self.roomId = roomId
    self.parameters = ChatPublishParameters()
  }
}

struct ChatPublishParameters {
  /// Additional information about the message
  var metadata: [String: Any]?
  /// Whether the message will be compressed prior to sending
  var compressed: Bool = false
  /// Whether the message should be stored in history
  var storeInHistory: Bool = true
  /// Content that will be attached to mobile payload
  var mobilePushPayload: [String: Any]?
}

protocol ChatMessageResponse {
  /// Updated sent `Date` from server
  var sentAt: Int64 { get }
  /// Server response message
  var responseMessage: String { get }
}

// MARK: History Request/Response
struct ChatHistoryRequest {
  /// Identifier of room being published on
  var roomId: String
  /// Request parameters
  var parameters: ChatHistoryParameters

  init(roomId: String, parameters: ChatHistoryParameters = ChatHistoryParameters()) {
    self.roomId = roomId
    self.parameters = parameters
  }
}

struct ChatHistoryParameters {
  /// Start `Date` value
  ///
  /// Value is exclusive, so response will include all messages after
  var start: Int64?
  /// Amount of messages returned
  var limit: UInt = 100
  /// Direction of message sentDate.
  ///
  /// Default is true, which means timeline is traversed newest to oldest.
  var reverse: Bool = false
  /// Should dates be included in message response
  var includeTimeToken: Bool = true
}

protocol ChatHistoryResponse {
  /// Sent at `Date` value of first returned message
  var start: Int64 { get }
  /// Sent at `Date` value of last returned message
  var end: Int64 { get }
  /// Historical messages for a chat room
  var messages: [Message] { get }
}

// Presence Request/Response
protocol ChatRoomPresenceResponse {
  /// Total active users in the chat room
  var occupancy: Int { get }
  /// List of `User` identifiers active on the chat room
  var uuids: [String] { get }
}

// MARK: Listeners
// tag::EVENT-1[]
protocol ChatMessageEvent {
  /// Identifier of the `ChatRoom` associated with the message
  var roomId: String { get }
  /// The message that was received
  var message: Message? { get }
}
// end::EVENT-1[]

// tag::EVENT-2[]
protocol ChatPresenceEvent {
  /// Identifier of the `ChatRoom` message was recieved on
  var roomId: String { get }
  /// Total active users in the chat room
  var occupancy: Int { get }
  /// List of `User` identifiers that have joined the chat room
  var joined: [String] { get }
  /// List of `User` identifiers that have timed out on the chat room
  var timedout: [String] { get }
  /// List of `User` identifiers that have left the chat room
  var left: [String] { get }
}
// end::EVENT-2[]

// tag::EVENT-3[]
protocol ChatStatusEvent {
  /// The status event that occurred
  var status: String { get }
  /// The associated request for the status event
  var request: String { get }
}
// end::EVENT-3[]
