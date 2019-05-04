//
//  ChatRoomDetailsViewModel.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/15/19.
//

import Foundation

struct ChatRoomDetailsViewModel {

  var chatService: ChatRoomService

  typealias Listener = (ChangeType) -> Void

  enum ChangeType {
    case occupancy
  }

  init(with chatService: ChatRoomService) {
    self.chatService = chatService
  }

  func bind(listener: Listener?) {
    chatService.listener = { (event) in
      switch event {
      case .messages:
        break
      case .presence:
        listener?(.occupancy)
      case .status(let event):
        switch event {
        case .success(let statusEvent):
          switch statusEvent {
          case .connected:
            // Get chat room Info
            self.chatService.fetchCurrentUsers()
          case .notConnected:
            break
          }
        case .failure:
          break
        }
      }
    }
    chatService.start()
  }

  var activeMembers: [User] {
    var members = chatService.occupantUUIDs.compactMap { (uuid) in
      User.firstStored(with: { $0.uuid == uuid })
    }

    members.sort { (first, second) -> Bool in
      // We want the 'sender' to be the top of the list
      if first == chatService.sender {
        return true
      } else if second == chatService.sender {
        return false
      }

      // Otherwise sort alphabetically 
      return first.displayName < second.displayName
    }

    return members
  }

  func activeMember(at indexPath: IndexPath) -> User? {
    guard indexPath.row < activeMembers.count else {
      return nil
    }

    return activeMembers[indexPath.row]
  }

  var chatRoom: ChatRoom {
    return chatService.room
  }
}
