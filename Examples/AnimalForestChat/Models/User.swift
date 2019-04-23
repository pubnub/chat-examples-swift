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
  var designation: String?
  var avatarImageName: String?

  static let senderStorageKey = "DefaultedSender"

  public var displayName: String {
    return "\(firstName ?? "") \(lastName ?? "")"
  }

  static var defaultSender: User? {
    // Retrieve the sender from cache
    if let sender = User.retrieve(from: .userDefaults, with: senderStorageKey) {
      return sender
    }

    // Store the sender from cache and then return
    let sender = User.defaultValues.randomElement()

    sender?.store(in: .userDefaults, at: senderStorageKey)

    return sender
  }
}

extension User: Defaultable {
  static var defaultValue: User {
    return User(uuid: "", firstName: nil, lastName: nil, designation: nil, avatarImageName: nil)
  }

  static var defaultValues: [User] {
    return  [
      User(uuid: "user-1", firstName: "Funky", lastName: "Monkey",
           designation: "Technical Specialist", avatarImageName: "avatar_Funky-Monkey"),
      User(uuid: "user-2", firstName: "Parrot", lastName: "Arra",
           designation: "Personal Assistant", avatarImageName: "avatar_Parrot-Arra"),
      User(uuid: "user-3", firstName: "Happy", lastName: "Turtle",
           designation: "Account Manager", avatarImageName: "avatar_Happy-Turtle"),
      User(uuid: "user-4", firstName: "Sleeping", lastName: "Chetah",
           designation: "Product Manager", avatarImageName: "avatar_Sleeping-Chetah"),
      User(uuid: "user-5", firstName: "Happy", lastName: "Chimpunk",
           designation: "Dev-Ops Engineer", avatarImageName: "avatar_Happy-Chimpunk"),
      User(uuid: "user-6", firstName: "Long", lastName: "Giraffe",
           designation: "Technical Specialist", avatarImageName: "avatar_Long-Giraffe"),
      User(uuid: "user-7", firstName: "Little", lastName: "Elephant",
           designation: "Sales Director", avatarImageName: "avatar_Little-Elephant"),
      User(uuid: "user-8", firstName: "Blue", lastName: "Bird",
           designation: "VP Marketing", avatarImageName: "avatar_Blue-Bird"),
      User(uuid: "user-9", firstName: "Colorful", lastName: "Rooster",
           designation: "Network Engineer", avatarImageName: "avatar_Colorful-Rooster"),
      User(uuid: "user-10", firstName: "Tropical", lastName: "Toucan",
           designation: "Sales Manager", avatarImageName: "avatar_Tropical-Toucan"),
      User(uuid: "user-11", firstName: "Cute", lastName: "Bear",
           designation: "Designer", avatarImageName: "avatar_Cute-Bear"),
      User(uuid: "user-12", firstName: "White", lastName: "Rabbit",
           designation: "Network Engineer", avatarImageName: "avatar_White-Rabbit"),
      User(uuid: "user-13", firstName: "King", lastName: "Lion",
           designation: "Co-Founder", avatarImageName: "avatar_King-Lion"),
      User(uuid: "user-14", firstName: "Night", lastName: "Owl",
           designation: "VP Finance", avatarImageName: "avatar_Night-Owl"),
      User(uuid: "user-15", firstName: "Forest", lastName: "Cat",
           designation: "Designer", avatarImageName: "avatar_Forest-Cat"),
      User(uuid: "user-16", firstName: "Striped", lastName: "Zebra",
           designation: "VP Sales", avatarImageName: "avatar_Striped-Zebra"),
      User(uuid: "user-17", firstName: "Jungle", lastName: "Tiger",
           designation: "CEO", avatarImageName: "avatar_Jungle-Tiger"),
      User(uuid: "user-18", firstName: "Baby", lastName: "Deer",
           designation: "Marketing Specialist", avatarImageName: "avatar_Baby-Deer"),
      User(uuid: "user-19", firstName: "Wild", lastName: "Eagle",
           designation: "Support Rep", avatarImageName: "avatar_Wild-Eagle"),
      User(uuid: "user-20", firstName: "Safari", lastName: "Camel",
           designation: "Solution Architect", avatarImageName: "vSafari-Camel"),
      User(uuid: "user-21", firstName: "Honey", lastName: "Bee",
           designation: "Co-Founder", avatarImageName: "avatar_Honey-Bee"),
      User(uuid: "user-22", firstName: "Angry", lastName: "Crocodile",
           designation: "Solution Architect", avatarImageName: "avatar_Angry-Crocodile"),
      User(uuid: "user-23", firstName: "Mountain", lastName: "Kangaroo",
           designation: "Product Manager", avatarImageName: "avatar_Mountain-Kangaroo"),
      User(uuid: "user-24", firstName: "Scary", lastName: "Snake",
           designation: "Engineer", avatarImageName: "avatar_Scary-Snake"),
      User(uuid: "user-25", firstName: "Greenland", lastName: "Reindeer",
           designation: "Technician", avatarImageName: "avatar_Greenland-Reindeer"),
      User(uuid: "user-26", firstName: "Crazy", lastName: "Frog",
           designation: "Receptionist", avatarImageName: "avatar_Crazy-Frog"),
      User(uuid: "user-27", firstName: "Black", lastName: "Pig",
           designation: "Account Manager", avatarImageName: "avatar_Black-Pig"),
      User(uuid: "user-28", firstName: "Red", lastName: "Fox",
           designation: "Support Rep", avatarImageName: "avatar_Red-Fox"),
      User(uuid: "user-29", firstName: "Bamboo", lastName: "Panda",
           designation: "Dev-Ops Engineer", avatarImageName: "avatar_Bamboo-Panda"),
      User(uuid: "user-30", firstName: "Cuddly", lastName: "Koala",
           designation: "Network Engineer", avatarImageName: "avatar_Cuddly-Koala"),
      User(uuid: "user-31", firstName: "Fast", lastName: "Ostrich",
           designation: "Technician", avatarImageName: "avatar_Fast-Ostrich"),
      User(uuid: "user-32", firstName: "Brown", lastName: "Meerkat",
           designation: "Solution Architect", avatarImageName: "avatar_Brown-Meerkat")
    ]
  }
}
