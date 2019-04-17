//
//  ChatViewModel.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import UIKit

struct ChatViewModel {

  enum ChangeType {
    case messages
    case occupancy
  }

  typealias Listener = (ChangeType) -> Void

  // Public Vars
  let chatChannel = "demo-animal-chat"
  let sender: User
  let channelDisplayName = "Animal Forest"
  var listener: Listener?

  // Services
  private var reachabilityService: ReachabilityService?
  private var appStateService: AppStateService
  private var chatService: ChatService

  private let maxTimeBetweenMesssages: TimeInterval = 60 * 60 // 1 Hour
  private let chatDateFormatter = DateFormatter()

  init(chatProvider: ChatProvider) {
    self.sender = User.defaultSender

    self.chatService = ChatService(with: chatProvider, on: chatChannel)
    self.reachabilityService = ReachabilityService(host: "https://ps.pndsn.com/time/0")
    self.appStateService = AppStateService()

    // Configure Chat Date Formatter
    self.chatDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    self.chatDateFormatter.dateFormat = "h:mm a"
  }

  var channelDetailVieModel: ChannelDetailsViewModel {
    return ChannelDetailsViewModel(with: chatService, on: chatChannel)
  }

  func start() {
    reachabilityService?.listener = { (status) in
      switch status {
      case .unknown:
        break
      case .notReachable:
        self.chatService.leaveChannel()
      case .reachable:
        self.chatService.joinChannel()
      }
    }
    reachabilityService?.start()

    appStateService.start { (appState) in
      switch appState {
      case .didBecomeActive:
        // Start Subscribing
        self.chatService.joinChannel()
      case .willResignActive:
        // Stop Subscribing
        self.chatService.leaveChannel()
      case .didEnterBackground, .willEnterForeground:
        // We're not doing anything special outside of active/inactive
        break
      }
    }

    chatService.listener = { (chatEvent) in
      switch chatEvent {
      case .message:
        self.listener?(.messages)
      case .presence:
        self.listener?(.occupancy)
      case .status:
        break
      }
    }
    chatService.start()
  }

  func stop() {
    self.reachabilityService?.stop()
    self.appStateService.stop()
    self.chatService.stop()  }

  var messages: [Message] {
    return chatService.messages
  }

  func messageName(for message: Message?) -> NSAttributedString? {
    guard let message = message else {
      return nil
    }

    // Format the displayname
    let displayname = NSAttributedString(string: message.user.displayName,
                                         attributes: messageStringAttributes(with: UIColor.black))
    return displayname
  }

  func messageDate(for message: Message?) -> NSAttributedString? {
    guard let message = message else {
      return nil
    }

    let messageTime = NSAttributedString(string: chatDateFormatter.string(from: message.sentDate),
                                         attributes: messageStringAttributes(with: UIColor.gray))

    return messageTime
  }

  private func messageStringAttributes(with color: UIColor) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: color]
  }

  private func titleStringAttributes(with size: CGFloat) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size),
            NSAttributedString.Key.foregroundColor: UIColor.black]
  }

  func history() {
    chatService.getChannelHistory()
  }

  func publish(_ message: String, completion: @escaping (Result<Message, NSError>) -> Void) {
    _ = chatService.publish(message) { (_) in

    }
  }

  func getChannelOccupancy() {
    chatService.getChannelOccupancy()
  }

  func shouldDisplayTime(between previous: Message?, and next: Message?) -> Bool {
    // If the last message sent is older than an hour display the time text
    if let previous = previous,
      let next = next, next.sentDate.timeIntervalSince(previous.sentDate) > maxTimeBetweenMesssages {
      return true
    }

    return false
  }

  var attributedChannelTitle: NSAttributedString {
    // Format the displayname
    let displayname = NSMutableAttributedString(string: "\(channelDisplayName)\n",
                                                attributes: titleStringAttributes(with: 17))

    switch chatService.state {
    case .connected:
      if chatService.occupancy <= 0 {
        return displayname
      } else if chatService.occupancy == 1 {
        let subtitle = NSAttributedString(string: "1 Member Online",
                                          attributes: titleStringAttributes(with: 12))
        displayname.append(subtitle)
        return displayname
      }
      let subtitle = NSAttributedString(string: "\(chatService.occupancy) Members Online",
        attributes: titleStringAttributes(with: 12))
      displayname.append(subtitle)
      return displayname
    case .notConnected:
      let subtitle = NSAttributedString(string: "Not Connected", attributes: titleStringAttributes(with: 12))
      displayname.append(subtitle)
      return displayname
    }
  }
}
