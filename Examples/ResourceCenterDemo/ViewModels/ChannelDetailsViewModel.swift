//
//  ChannelDetailsViewModel.swift
//  RCDemo
//
//  Created by Craig Lane on 4/15/19.
//

import Foundation

struct ChannelDetailsViewModel {

  var channel: String

  var chatroomTitle = "Animal Chat"
  var chatroomDescription = "A chat group to talk to all your fuzzy friends in the animal kingdom."

  var chatService: ChatService?

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
    let members = chatService?.occupantUUIDs.compactMap { (uuid) in
      User.firstStored(with: { $0.uuid == uuid })
    }

    return members ?? []
  }
}
