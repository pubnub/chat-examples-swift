//
//  Message.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

struct Message: Codable, Hashable {
  var uuid: String
  var text: String

  var senderId: String
  var sentDate: Date
}

extension Message {
  static func payload(for message: String, by senderId: String) -> [String: String] {
    return [
      "senderId": senderId,
      "text": message
    ]
  }

  var user: User? {
    return  User.firstStored(with: { $0.senderId == senderId })
  }

  func updateTimetoken(with token: NSNumber) -> Message {
    return Message(uuid: self.uuid, text: self.text, senderId: self.senderId, sentDate: Date.from(token))
  }
}

extension Message: Equatable {
  /// Returns whether the two Message values are equal.
  ///
  /// - parameter lhs: The left-hand side value to compare.
  /// - parameter rhs: The right-hand side value to compare.
  ///
  /// - returns: `true` if the two values are equal, `false` otherwise.
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}
