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

  static var defaultUser: User {
    return User(uuid: "user-0", firstName: "Craig", lastName: "FireFox", avatarImageName: "Red-Fox")
  }
}

extension User: Storable {
  static var storedValues: [User] {
    return  [
      User(uuid: "user-1", firstName: "Funky", lastName: "Monkey", avatarImageName: "Funky-Monkey"),
      User(uuid: "user-2", firstName: "Parrot", lastName: "Arra", avatarImageName: "Parrot-Arra"),
      User(uuid: "user-3", firstName: "Happy", lastName: "Turtle", avatarImageName: "Happy-Turtle"),
      User(uuid: "user-4", firstName: "Sleeping", lastName: "Chetah", avatarImageName: "Sleeping-Chetah"),
      User(uuid: "user-5", firstName: "Happy", lastName: "Chimpunk", avatarImageName: "Happy-Chimpunk"),
      User(uuid: "user-6", firstName: "Long", lastName: "Giraffe", avatarImageName: "Long-Giraffe"),
      User(uuid: "user-7", firstName: "Little", lastName: "Elephant", avatarImageName: "Little-Elephant"),
      User(uuid: "user-8", firstName: "Blue", lastName: "Bird", avatarImageName: "Blue-Bird"),
      User(uuid: "user-9", firstName: "Colorful", lastName: "Cock", avatarImageName: "Colorful-Rooster"),
      User(uuid: "user-10", firstName: "Tropical", lastName: "Toucan", avatarImageName: "Tropical-Toucan"),
      User(uuid: "user-11", firstName: "Cute", lastName: "Bear", avatarImageName: "Cute-Bear"),
      User(uuid: "user-12", firstName: "White", lastName: "Rabbit", avatarImageName: "White-Rabbit"),
      User(uuid: "user-13", firstName: "King", lastName: "Lion", avatarImageName: "King-Lion"),
      User(uuid: "user-14", firstName: "Night", lastName: "Owl", avatarImageName: "Night-Owl"),
      User(uuid: "user-15", firstName: "Forest", lastName: "Cat", avatarImageName: "Forest-Cat"),
      User(uuid: "user-16", firstName: "Striped", lastName: "Zebra", avatarImageName: "Striped-Zebra"),
      User(uuid: "user-17", firstName: "Jungle", lastName: "Tiger", avatarImageName: "Jungle-Tiger"),
      User(uuid: "user-18", firstName: "Baby", lastName: "Deer", avatarImageName: "Baby-Deer"),
      User(uuid: "user-19", firstName: "Wild", lastName: "Eagle", avatarImageName: "Wild-Eagle"),
      User(uuid: "user-20", firstName: "Safari", lastName: "Camel", avatarImageName: "Safari-Camel"),
      User(uuid: "user-21", firstName: "Honey", lastName: "Bee", avatarImageName: "Honey-Bee"),
      User(uuid: "user-22", firstName: "Brown", lastName: "Meerkat", avatarImageName: "Brown-Meerkat"),
      User(uuid: "user-23", firstName: "Angry", lastName: "Crocodile", avatarImageName: "Angry-Crocodile"),
      User(uuid: "user-24", firstName: "Mountain", lastName: "Kangaroo", avatarImageName: "Mountain-Kangaroo"),
      User(uuid: "user-25", firstName: "Scary", lastName: "Snake", avatarImageName: "Scary-Snake"),
      User(uuid: "user-26", firstName: "Greenland", lastName: "Reindeer", avatarImageName: "Greenland-Reindeer"),
      User(uuid: "user-27", firstName: "Crazy", lastName: "Frog", avatarImageName: "Crazy-Frog"),
      User(uuid: "user-28", firstName: "Black", lastName: "Pig", avatarImageName: "Black-Pig"),
      User(uuid: "user-29", firstName: "Red", lastName: "Fox", avatarImageName: "Red-Fox"),
      User(uuid: "user-30", firstName: "Bamboo", lastName: "Panda", avatarImageName: "Bamboo-Panda"),
      User(uuid: "user-31", firstName: "Cuddly", lastName: "Koala", avatarImageName: "Cuddly-Koala"),
      User(uuid: "user-32", firstName: "Fast", lastName: "Ostrich", avatarImageName: "Fast-Ostrich")
    ]
  }
}
