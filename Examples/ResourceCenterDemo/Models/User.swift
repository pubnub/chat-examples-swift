//
//  User.swift
//  RCDemo
//
//  Created by Craig Lane on 4/1/19.
//

import Foundation

struct User: Codable, Hashable {
  var uuid: String
  var firstName: String?
  var lastName: String?
  var avatarImageName: String?

  public var displayName: String {
    return "\(firstName ?? "") \(lastName ?? "")"
  }

  static var defaultSender: User {
    if let sender = User.retrieve(from: .userDefaults, with: "DefaultedSender") {
      return sender
    }

    let sender = User.storedValues.randomElement() ?? User.storedValues[Int.random(in: 0..<User.storedValues.count)]

    sender.store(in: .userDefaults, at: "DefaultedSender")

    return sender
  }
}

extension User: Storable {
  static var storedValues: [User] {
    return  [
      User(uuid: "u-00000", firstName: "Finny", lastName: "Fish", avatarImageName: "bird-avatar"),
      User(uuid: "u-00001", firstName: "Daniel", lastName: "Dog", avatarImageName: "bird-avatar"),
      User(uuid: "u-00002", firstName: "Bernie", lastName: "Bear", avatarImageName: "bird-avatar"),
      User(uuid: "u-00003", firstName: "Carl", lastName: "Cat", avatarImageName: "bird-avatar"),
      User(uuid: "u-00004", firstName: "Uri", lastName: "Unicorn", avatarImageName: "bird-avatar"),
      User(uuid: "u-00005", firstName: "Monty", lastName: "Monkey", avatarImageName: "bird-avatar"),
      User(uuid: "u-00006", firstName: "Ollie", lastName: "Owl", avatarImageName: "bird-avatar"),
      User(uuid: "u-00007", firstName: "Larry", lastName: "Lion", avatarImageName: "bird-avatar")
    ]
  }
}
