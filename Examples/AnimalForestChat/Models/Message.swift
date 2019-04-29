//
//  Message.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

struct Message: Codable, Hashable {
  /// Unique identifier for the message
  var uuid: String
  /// The text content for the message
  var text: String
  /// The date at which the message was created
  var sentDate: Date
  /// Identifier of the user who sent the message
  var senderId: String
  /// Identifier of the room to which the message belongs
  var roomId: String
}

extension Message {
  /// The user who sent the message
  var user: User? {
    return  User.firstStored(with: { $0.uuid == senderId })
  }
  /// The room to which the message belongs
  var room: ChatRoom? {
    return ChatRoom.firstStored(with: { $0.uuid == roomId })
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
