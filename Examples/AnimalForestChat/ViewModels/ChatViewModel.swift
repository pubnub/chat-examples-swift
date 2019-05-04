//
//  ChatViewModel.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/4/19.
//

import Foundation

struct ChatViewModel {
  // MARK: Types

  /// Defines the different areas a `Date` can be displayed
  ///
  /// - header:  The area between two messages
  /// - message: The area directly above a message
  enum DateDisplayArea {
    /// The area between two messages
    case header
    /// The area directly above a message
    case message
  }

  /// Defines the type of change event emitted
  ///
  /// - messages:   A new message has been recieved
  /// - occupancy:  The occupancy of the chat room has increased or decreased
  enum ChangeType {
    /// A new message has been recieved
    case messages
    /// The occupancy of the chat room has increased or decreased
    case occupancy
  }

  typealias Listener = (ChangeType) -> Void

  // MARK: Public Properties
  /// A closure executed when the view model data changes. The closure takes a single argument: the
  /// chat event `ChangeType`.
  var listener: Listener?

  // MARK: Private Properties
  private let chatURLString = "https://ps.pndsn.com/time/0"
  private let maxTimeBetweenMesssages: Int64 = 60 * 60 // 1 Hour in seconds

  // MARK: Services
  private var reachabilityService: ReachabilityService?
  private var appStateService: AppStateService
  private var chatService: ChatRoomService

// tag::CVM-1[]
  init(with chatService: ChatRoomService,
       reachabilityService: ReachabilityService? = ReachabilityService(),
       appStateService: AppStateService = AppStateService()) {

    self.chatService = chatService
    self.reachabilityService = reachabilityService
    self.appStateService = appStateService
  }
// end::CVM-1[]

  // MARK: Listeners
// tag::SUB-2[]
  private var chatListener: ChatRoomService.Listener {
    return { (chatEvent) in
      switch chatEvent {
      case .messages:
        self.listener?(.messages)
      case .presence:
        self.listener?(.occupancy)
      case .status(let event):
        switch event {
        case .success(let statusEvent):
          switch statusEvent {
          case .connected:
            // Get chat room Info
            self.chatService.fetchMessageHistory()
            self.chatService.fetchCurrentUsers()
          case .notConnected:
            // Update UI
            self.listener?(.occupancy)
          }
        case .failure:
          break
        }
      }
    }
  }
// end::SUB-2[]

  private var reachabilityListener: ReachabilityService.Listener {
    return { (status) in
      switch status {
      case .reachable:
        self.chatService.start()
      case .notReachable:
        self.chatService.stop()
      case .unknown:
        break
      }
    }
  }

  private var appStateListener: AppStateService.Listener {
    return { (appState) in
      switch appState {
      case .didBecomeActive:
        // Start Subscribing
        self.chatService.start()
      case .willResignActive:
        // Stop Subscribing
        self.chatService.stop()
      case .didEnterBackground, .willEnterForeground:
        // We're not doing anything special outside of active/inactive
        break
      }
    }
  }

  /// Starts listening for changes managed by this view model.
  func bind() {
    reachabilityService?.listener = reachabilityListener
    reachabilityService?.start()

    appStateService.listener = appStateListener
    appStateService.start()

    chatService.listener = chatListener
    chatService.start()
  }

  // MARK: Chat Data Source
  /// The user sending messages
  var sender: User? {
    return chatService.sender
  }
  /// The room being tracked by the view model
  var chatRoom: ChatRoom {
    return chatService.room
  }

  /// List of `Message` values that are associted with the chat room
  var messages: [Message] {
    return chatService.messages
  }

  /// Publish a message to the service's chat room
  /// - parameter message: The text to be published
  func send(_ message: String, completion: @escaping (Result<Message, NSError>) -> Void) {
    _ = chatService.send(message) { (result) in
      completion(result)
    }
  }

  // MARK: Routing
  /// View model that can be used to provide data about chat room details
  var chatRoomDetailVieModel: ChatRoomDetailsViewModel {
    return ChatRoomDetailsViewModel(with: chatService)
  }

  // MARK: Presentation
  /// The attributed string representing the chat room's name
  var chatRoomAttributedTitle: NSAttributedString? {
    // Format the displayname
    switch chatService.state {
    case .connected:
      // Empty Room
      if chatService.occupancy <= 0 {
        return chatRoom.attributedTitle
      // Single users in room
      } else if chatService.occupancy == 1 {
        return chatRoom.attributedTitle(with: "1 Member Online", using: .systemFont(ofSize: 12))
      }
      // Multiple users in room
      return chatRoom.attributedTitle(with: "\(chatService.occupancy) Members Online", using: .systemFont(ofSize: 12))
    case .notConnected:
      return chatRoom.attributedTitle(with: "Not Connected", using: .systemFont(ofSize: 12))
    }
  }

  func isMessageAvatarHidden(at index: Int) -> Bool {
    return isPreviousMessageSameSender(at: index)
  }

  func shouldDisplayMessageSender(at index: Int) -> Bool {
    return !isPreviousMessageSameSender(at: index)
  }

  func shouldDisplayMessageTime(at index: Int) -> Bool {
    return !isNextMessageSameSender(at: index) || shouldDisplayTime(between: messages[index],
                                                                    and: nextMessage(of: index))
  }

  func shouldDisplayTimeGap(at index: Int) -> Bool {
    return shouldDisplayTime(between: previousMessage(of: index), and: messages[index])
  }

  private func shouldDisplayTime(between previous: Message?, and next: Message?) -> Bool {
    // If the last message sent is older than an hour display the time text
    if let previous = previous, let next = next,
      (next.sentAt - previous.sentAt) > maxTimeBetweenMesssages {
      return true
    }
    return false
  }

  private func previousMessage(of index: Int) -> Message? {
    guard index - 1 >= 0  else { return nil }
    return messages[index - 1]
  }

  private func nextMessage(of index: Int) -> Message? {
    guard index + 1 < messages.count else { return nil }
    return messages[index + 1]
  }

  private func isPreviousMessageSameSender(at index: Int) -> Bool {
    guard let message = previousMessage(of: index) else { return false }
    return messages[index].senderId == message.senderId
  }

  private func isNextMessageSameSender(at index: Int) -> Bool {
    guard let message = nextMessage(of: index) else { return false }
    return messages[index].senderId == message.senderId
  }
}
