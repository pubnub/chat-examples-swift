//
//  ChatProvider.swift
//  RCDemo
//
//  Created by Craig Lane on 3/14/19.
//

import PubNub

struct ChatPublishRequest {
  var channel: String
  var message: [String: String]
  var parameters: ChatPublishParameters

  init(channel: String,
       message: String,
       senderId: String,
       parameters: ChatPublishParameters = ChatPublishParameters())
  {
    // swiftlint:disable:previous opening_brace
    self.message = ["senderId": senderId, "text": message]
    self.channel = channel
    self.parameters = ChatPublishParameters()
  }
}

struct ChatPublishParameters {
  var metadata: [String: Any]?
  var compressed: Bool = false
  var storeInHistory: Bool = true
  var mobilePushPayload: [String: Any]?
}

struct ChatHistoryRequest {
  var channel: String
  var parameters: ChatHistoryParameters

  init(channel: String, parameters: ChatHistoryParameters = ChatHistoryParameters()) {
    self.channel = channel
    self.parameters = parameters
  }
}

struct ChatHistoryParameters {
  var start: NSNumber?
  var end: NSNumber?
  var limit: UInt = 100
  var reverse: Bool = true
  var includeTimeToken: Bool = true
}
// tag::WRAP-1[]
protocol ChatEmitter {
  func add(_ listener: AnyObject)
  func remove(_ listener: AnyObject)

  func isSubscribed(on channel: String) -> Bool

  func subscribe(to channels: [String], withPresence: Bool)
  func unsubscribe(from channels: [String], withPresence: Bool)
}

protocol ChatRequester {
  var uuid: String { get }

  func publish(_ request: ChatPublishRequest, completion: @escaping  (Result<ChatPublishRepsonse, NSError>) -> Void)
  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryRepsonse?, NSError>) -> Void)
  func hereNow(for channel: String, completion: @escaping  (Result<ChatChannelPresenceResponse?, NSError>) -> Void)
}

typealias ChatProvider = ChatRequester & ChatEmitter
// end::WRAP-1[]

protocol ChatHistoryRepsonse {
  var start: Date { get }
  var end: Date { get }
  var messages: [Message] { get }
}

protocol ChatPublishRepsonse {
  var sentAt: Date { get }
  var responseMessage: String { get }
}

protocol ChatChannelPresenceResponse {
  var occupancy: Int { get }
  var uuids: [String] { get }
}

// tag::SERV-2[]
protocol ChatMessageEvent {
  var channel: String { get }
  var message: Message? { get }
}

protocol ChatPresenceEvent {
  var channel: String { get }
  var occupancy: Int { get }
  var joined: [String] { get }
  var timedout: [String] { get }
  var left: [String] { get }
  var refreshNow: Bool { get }
  var state: [String: Any]? { get }
}

protocol ChatStatusEvent {
  var status: String { get }
  var request: String { get }
}
// end::SERV-2[]
