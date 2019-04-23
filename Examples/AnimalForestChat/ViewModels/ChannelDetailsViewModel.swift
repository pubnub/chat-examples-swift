//
//  ChannelDetailsViewModel.swift
//  RCDemo
//
//  Created by Craig Lane on 4/15/19.
//

import Foundation

struct ChannelDetailsViewModel {

  var channel: String

  var chatroomTitle = "Animal Forest"
  var chatroomDescription = "A chat group to talk to all your fuzzy friends in the animal kingdom."
  private(set) var channelAvatarName = "avatar_animal_forest"

  var chatService: ChatService?

  var sender: User? = User.defaultSender

  typealias Listener = (ChangeType) -> Void

  enum ChangeType {
    case occupancy
  }

  init(with chatService: ChatService, on channel: String) {
    self.channel = channel

    self.chatService = chatService
  }

  func start(listener: Listener?) {
    self.chatService?.listener = { (event) in
      switch event {
      case .message:
        // This VM doesn't care about messages
        break
      case .presence:
        listener?(.occupancy)
      case .status:
        break
      }
    }
    self.chatService?.start()
    self.chatService?.getChannelOccupancy()
  }

  var activeMembers: [User] {
    guard let sender = sender else {
      return []
    }

    var members = chatService?.occupantUUIDs.compactMap { (uuid) in
      User.firstStored(with: { $0.uuid == uuid })
    }

    members?.sort { (first, second) -> Bool in
      // We want the 'sender' to be the top of the list
      if first.uuid == sender.uuid {
        return true
      } else if second.uuid == sender.uuid {
        return false
      }

      // Otherwise sort alphabetically 
      return first.displayName < second.displayName
    }

    return members ?? []
  }

  func activeMember(at indexPath: IndexPath) -> User? {
    guard indexPath.row < activeMembers.count else {
      return nil
    }

    return activeMembers[indexPath.row]
  }

  func occupantDisplayName(for user: User?) -> String? {
    guard let user = user else {
      return nil
    }

    let displayName = user.displayName

    if let sender = sender, user.uuid == sender.uuid {
      return "\(displayName) (You)"
    } else {
      return displayName
    }

  }

  func occupantDesignation(for user: User?) -> String? {
    return user?.designation
  }

  func occupantAvatarImageName(for user: User?) -> String? {
    return user?.avatarImageName
  }
}
