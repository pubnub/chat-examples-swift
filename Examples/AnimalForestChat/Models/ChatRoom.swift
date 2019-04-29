//
//  ChatRoom.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/27/19.
//

import UIKit

struct ChatRoom: Codable, Hashable {
  /// Unique identifier for the room
  var uuid: String
  /// Human readable name for the room
  var name: String
  /// Human readable description for the room
  var description: String?
  /// Resource Bundle identifier for avatar image
  var avatarName: String?
}

extension ChatRoom {
  /// UIImage representation of `avatarName`
  var avatar: UIImage? {
    guard let image = avatarName else {
      return nil
    }

    return UIImage(named: image)
  }
}

extension ChatRoom: Defaultable {
  /// Default room when no custom room is specified
  static var defaultValue: ChatRoom {
    return ChatRoom(uuid: "demo-animal-forest",
                    name: "Animal Forest",
                    description: "A chat group to talk to all your fuzzy friends in the animal kingdom.",
                    avatarName: "avatar_animal_forest")
  }
}
