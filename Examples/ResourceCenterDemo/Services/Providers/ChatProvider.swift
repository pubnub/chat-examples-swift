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

protocol ChatEmitter {
  func add(_ listener: AnyObject)
  func remove(_ listener: AnyObject)

  func isSubscribed(on channel: String) -> Bool

  func subscribe(to channels: [String], withPresence: Bool)
  func unsubscribe(from channels: [String], withPresence: Bool)
}

protocol ChatRequester {
  var uuid: String { get }

  func publish(_ request: ChatPublishRequest, completion: @escaping  (Result<NSNumber, NSError>) -> Void)
  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<[String: Any?], NSError>) -> Void)
  func hereNow(for channel: String, completion: @escaping  (Result<[String: Any?], NSError>) -> Void)
}

typealias ChatProvider = ChatRequester & ChatEmitter

extension PubNub: ChatProvider {
  // MARK: - ChatRequester
  var uuid: String {
    return self.uuid()
  }

  func publish(_ request: ChatPublishRequest, completion: @escaping (Result<NSNumber, NSError>) -> Void) {
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
        completion(.success(status.data.timetoken))
      }
    }
  }

  func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<[String: Any?], NSError>) -> Void) {
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
      } else {
        completion(.success(["start": result?.data.start, "end": result?.data.end, "messages": result?.data.messages]))
      }
    }
  }

  func hereNow(for channel: String, completion: @escaping  (Result<[String: Any?], NSError>) -> Void) {
    hereNowForChannel(channel) { (result, status) in
      if let error = status?.error {
        completion(.failure(error))
      } else {
        completion(.success(["occupancy": result?.data.occupancy, "uuids": result?.data.uuids]))
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
