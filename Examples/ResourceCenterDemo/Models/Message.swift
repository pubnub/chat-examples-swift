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
    return Message(uuid: token.description, text: self.text, senderId: self.senderId, sentDate: Date.from(token))
  }
}
