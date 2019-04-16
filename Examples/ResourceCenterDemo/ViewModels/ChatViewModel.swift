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
  let chatChannel = "demo-animal-chat-swift"
  let sender: User
  var listener: Listener?

  // Services
  private var reachabilityService: ReachabilityService?
  private var appStateService: AppStateService
  private var chatService: ChatService

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

  func detailText(for message: Message?) -> NSAttributedString? {
    guard let message = message else {
      return nil
    }

    // Format the displayname
    let displayname = NSMutableAttributedString(string: message.user.displayName,
                                            attributes: messageHeaderStringAttributes(with: UIColor.black))

    // Note: We're using string interpolation to add a single buffering space between the
    let messageTime = NSAttributedString(string: " \(chatDateFormatter.string(from: message.sentDate))",
                                            attributes: messageHeaderStringAttributes(with: UIColor.gray))

    displayname.append(messageTime)

    return displayname
  }

  private func messageHeaderStringAttributes(with color: UIColor) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: color]
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

  var channelTitle: String {
    switch chatService.state {
    case .connected:
      if chatService.occupancy <= 0 {
        return "Animal Chat"
      } else if chatService.occupancy == 1 {
        return "Animal Chat\n1 Member Online"
      }

      return String(format: "Animal Chat\n%i Members Online", chatService.occupancy)
    case .notConnected:
      return String(format: "Animal Chat\n%Not Connected", chatService.occupancy)
    }
  }
}
