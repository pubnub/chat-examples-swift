//
//  Message+MessageType.swift
//  RCDemo
//
//  Created by Craig Lane on 4/11/19.
//

import MessageKit

extension Message: MessageType {
  var messageId: String {
    return uuid
  }

  var sender: SenderType {
    return user ?? User.defaultValue
  }

  var kind: MessageKind {
    return .text(self.text)
  }
}
