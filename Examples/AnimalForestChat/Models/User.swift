//
//  User.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/1/19.
//

import UIKit

struct User: Codable, Hashable {
  private static let senderStorageKey = "DefaultedSender"

  /// Unique identifier for the user
  var uuid: String
  /// Used to gracefull migrate away from uuid schema
  var altId: String
  /// First name
  var firstName: String?
  /// Last (Family) name
  var lastName: String?
  /// Occupation Title
  var designation: String?
  /// Resource Bundle identifier for avatar image
  var avatarName: String?
}

extension User {
  // The display name of the user
  public var displayName: String {
    return "\(firstName ?? "") \(lastName ?? "")"
  }

  /// UIImage representation of `avatarName`
  var avatar: UIImage? {
    guard let image = avatarName else {
      return nil
    }

    return UIImage(named: image)
  }

  /// Is this user the current sender
  var isCurrentUser: Bool {
    return User.defaultValue == self
  }
}

extension User: Equatable {
  /// Returns whether the two User values are equal.
  ///
  /// - parameter lhs: The left-hand side value to compare.
  /// - parameter rhs: The right-hand side value to compare.
  ///
  /// - returns: `true` if the two values are equal, `false` otherwise.
  static func == (lhs: User, rhs: User) -> Bool {
    return lhs.uuid == rhs.uuid || lhs.uuid == rhs.altId || rhs.uuid == lhs.altId
  }
}

extension User: Defaultable {
  /// User that has been flagged as the chat sender
  ///
  /// - Note: This `User` is cached in UserDefaults after initially selected
  /// - Attention: In our example this is random user, but would commonly be an authorized user
  static var defaultValue: User {
    // Retrieve the sender from cache
    if let sender = User.retrieve(from: .userDefaults, with: senderStorageKey) {
      return sender
    }

    // Store the sender from cache and then return
    let sender = User.defaultValues[Int.random(in: 0..<User.defaultValues.count)]
    sender.store(in: .userDefaults, at: senderStorageKey)

    return sender
  }

  /// All users that can connect to our chat application
  ///
  /// - Attention: In our example this is local, but would commonly link to a remote address book
  static var defaultValues: [User] {
    return  [
      User(uuid: "forest-animal-1", altId: "user-1", firstName: "Funky", lastName: "Monkey",
           designation: "Technical Specialist", avatarName: "avatar_Funky-Monkey"),
      User(uuid: "forest-animal-2", altId: "user-2", firstName: "Parrot", lastName: "Arra",
           designation: "Personal Assistant", avatarName: "avatar_Parrot-Arra"),
      User(uuid: "forest-animal-3", altId: "user-3", firstName: "Happy", lastName: "Turtle",
           designation: "Account Manager", avatarName: "avatar_Happy-Turtle"),
      User(uuid: "forest-animal-4", altId: "user-4", firstName: "Sleeping", lastName: "Chetah",
           designation: "Product Manager", avatarName: "avatar_Sleeping-Chetah"),
      User(uuid: "forest-animal-5", altId: "user-5", firstName: "Happy", lastName: "Chimpunk",
           designation: "Dev-Ops Engineer", avatarName: "avatar_Happy-Chimpunk"),
      User(uuid: "forest-animal-6", altId: "user-6", firstName: "Long", lastName: "Giraffe",
           designation: "Technical Specialist", avatarName: "avatar_Long-Giraffe"),
      User(uuid: "forest-animal-7", altId: "user-7", firstName: "Little", lastName: "Elephant",
           designation: "Sales Director", avatarName: "avatar_Little-Elephant"),
      User(uuid: "forest-animal-8", altId: "user-8", firstName: "Blue", lastName: "Bird",
           designation: "VP Marketing", avatarName: "avatar_Blue-Bird"),
      User(uuid: "forest-animal-9", altId: "user-9", firstName: "Colorful", lastName: "Rooster",
           designation: "Network Engineer", avatarName: "avatar_Colorful-Rooster"),
      User(uuid: "forest-animal-10", altId: "user-10", firstName: "Tropical", lastName: "Toucan",
           designation: "Sales Manager", avatarName: "avatar_Tropical-Toucan"),
      User(uuid: "forest-animal-11", altId: "user-11", firstName: "Cute", lastName: "Bear",
           designation: "Designer", avatarName: "avatar_Cute-Bear"),
      User(uuid: "forest-animal-12", altId: "user-12", firstName: "White", lastName: "Rabbit",
           designation: "Network Engineer", avatarName: "avatar_White-Rabbit"),
      User(uuid: "forest-animal-13", altId: "user-13", firstName: "King", lastName: "Lion",
           designation: "Co-Founder", avatarName: "avatar_King-Lion"),
      User(uuid: "forest-animal-14", altId: "user-14", firstName: "Night", lastName: "Owl",
           designation: "VP Finance", avatarName: "avatar_Night-Owl"),
      User(uuid: "forest-animal-15", altId: "user-15", firstName: "Forest", lastName: "Cat",
           designation: "Designer", avatarName: "avatar_Forest-Cat"),
      User(uuid: "forest-animal-16", altId: "user-16", firstName: "Striped", lastName: "Zebra",
           designation: "VP Sales", avatarName: "avatar_Striped-Zebra"),
      User(uuid: "forest-animal-17", altId: "user-17", firstName: "Jungle", lastName: "Tiger",
           designation: "CEO", avatarName: "avatar_Jungle-Tiger"),
      User(uuid: "forest-animal-18", altId: "user-18", firstName: "Baby", lastName: "Deer",
           designation: "Marketing Specialist", avatarName: "avatar_Baby-Deer"),
      User(uuid: "forest-animal-19", altId: "user-19", firstName: "Wild", lastName: "Eagle",
           designation: "Support Rep", avatarName: "avatar_Wild-Eagle"),
      User(uuid: "forest-animal-20", altId: "user-20", firstName: "Safari", lastName: "Camel",
           designation: "Solution Architect", avatarName: "avatar_Safari-Camel"),
      User(uuid: "forest-animal-21", altId: "user-21", firstName: "Honey", lastName: "Bee",
           designation: "Co-Founder", avatarName: "avatar_Honey-Bee"),
      User(uuid: "forest-animal-22", altId: "user-22", firstName: "Angry", lastName: "Crocodile",
           designation: "Solution Architect", avatarName: "avatar_Angry-Crocodile"),
      User(uuid: "forest-animal-23", altId: "user-23", firstName: "Mountain", lastName: "Kangaroo",
           designation: "Product Manager", avatarName: "avatar_Mountain-Kangaroo"),
      User(uuid: "forest-animal-24", altId: "user-24", firstName: "Scary", lastName: "Snake",
           designation: "Engineer", avatarName: "avatar_Scary-Snake"),
      User(uuid: "forest-animal-25", altId: "user-25", firstName: "Greenland", lastName: "Reindeer",
           designation: "Technician", avatarName: "avatar_Greenland-Reindeer"),
      User(uuid: "forest-animal-26", altId: "user-26", firstName: "Crazy", lastName: "Frog",
           designation: "Receptionist", avatarName: "avatar_Crazy-Frog"),
      User(uuid: "forest-animal-27", altId: "user-27", firstName: "Black", lastName: "Pig",
           designation: "Account Manager", avatarName: "avatar_Black-Pig"),
      User(uuid: "forest-animal-28", altId: "user-28", firstName: "Red", lastName: "Fox",
           designation: "Support Rep", avatarName: "avatar_Red-Fox"),
      User(uuid: "forest-animal-29", altId: "user-29", firstName: "Bamboo", lastName: "Panda",
           designation: "Dev-Ops Engineer", avatarName: "avatar_Bamboo-Panda"),
      User(uuid: "forest-animal-30", altId: "user-30", firstName: "Cuddly", lastName: "Koala",
           designation: "Network Engineer", avatarName: "avatar_Cuddly-Koala"),
      User(uuid: "forest-animal-31", altId: "user-31", firstName: "Fast", lastName: "Ostrich",
           designation: "Technician", avatarName: "avatar_Fast-Ostrich"),
      User(uuid: "forest-animal-32", altId: "user-32", firstName: "Brown", lastName: "Meerkat",
           designation: "Solution Architect", avatarName: "avatar_Brown-Meerkat")
    ]
  }
}
