//
//  User+SenderType.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/11/19.
//

import MessageKit

extension User: SenderType {
  var initials: String {
    return "\(firstName?.first ?? Character(""))\(lastName?.first ?? Character(""))"
  }

  public var senderId: String {
    return uuid
  }
}
