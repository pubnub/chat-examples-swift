//
//  ChatViewModel.swift
//  RCDemo
//
//  Created by Craig Lane on 4/4/19.
//

import UIKit

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
  private let maxTimeBetweenMesssages: TimeInterval = 60 * 60 // 1 Hour
  private let chatDateFormatter = DateFormatter()

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

    // tag::ignore[]
    // Configure Message Date Formatter
    self.chatDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    // end::ignore[]
  }
// end::CVM-1[]

  // MARK: Listeners
// tag::SUB-2[]
  private var chatListener: ChatRoomService.Listener {
    return { (chatEvent) in
      switch chatEvent {
      case .messages:
        self.listener?(.messages)
      case .users:
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
            break
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
      case .unknown:
        break
      case .notReachable:
        self.chatService.stop()
      case .reachable:
        self.chatService.start()
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
  func start() {
    reachabilityService?.listener = reachabilityListener
    reachabilityService?.start()

    appStateService.listener = appStateListener
    appStateService.start()

    chatService.listener = chatListener
    chatService.start()
  }

  /// Stops listening for changes managed by this view model.
  func stop() {
    self.reachabilityService?.stop()
    self.appStateService.stop()
    self.chatService.stop()
  }

  // MARK: Chat Data Source
  /// The user sending messages
  var sender: User {
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
  func publish(_ message: String, completion: @escaping (Result<Message, NSError>) -> Void) {
    _ = chatService.publish(message) { (result) in
      completion(result)
    }
  }

  // MARK: Presentation
  /// View model that can be used to provide data about chat room details
  var chatRoomDetailVieModel: ChatRoomDetailsViewModel {
    return ChatRoomDetailsViewModel(with: chatService)
  }

  /// The attributed string representing the chat room's name
  var chatRoomAttributedTitle: NSAttributedString {
    // Format the displayname
    let displayname = NSMutableAttributedString(string: "\(chatRoom.name)\n",
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

  func messageBackgroundColor(at index: Int) -> UIColor {
    if messages[index].senderId == sender.uuid {
      return UIColor.messageSender
    }

    return UIColor.messageReceiver
  }

  func messageAvatarImage(at index: Int) -> UIImage? {
    if let imageName = messages[index].user?.avatarName {
      return UIImage(named: imageName)
    }

    return nil
  }

  func isMessageAvatarHidden(at index: Int) -> Bool {
    return isPreviousMessageSameSender(at: index)
  }

  private func shouldDisplayMessageSender(at index: Int) -> Bool {
    return !isPreviousMessageSameSender(at: index)
  }

  func messageSenderDisplay(at index: Int) -> NSAttributedString? {
    if shouldDisplayMessageSender(at: index), let sender = messages[index].user {
      // Format the displayname
      let displayname = NSAttributedString(string: sender.displayName,
                                           attributes: messageStringAttributes(with: UIColor.black))
      return displayname
    }

    return nil
  }

  func messageSenderHeight(at index: Int) -> CGFloat {
    return shouldDisplayMessageSender(at: index) ? 16 : 0
  }

  private func shouldDisplayMessageTime(at index: Int) -> Bool {
    return !isNextMessageSameSender(at: index) || shouldDisplayTime(between: messages[index],
                                                                    and: nextMessage(of: index))
  }

  func messageTimeDisplay(at index: Int) -> NSAttributedString? {
    if shouldDisplayMessageTime(at: index) {
      return NSAttributedString(string: displayFormattedTime(for: messages[index].sentDate, on: .message),
                                attributes: messageStringAttributes(with: UIColor.gray))
    }

    return nil
  }

  func messageTimeHeight(at index: Int) -> CGFloat {
    return shouldDisplayMessageTime(at: index) ? 16 : 0
  }

  private func shouldDisplayTimeGap(at index: Int) -> Bool {
    return shouldDisplayTime(between: previousMessage(of: index), and: messages[index])
  }

  func messageTimeGapDisplay(at index: Int) -> NSAttributedString? {
    if shouldDisplayTimeGap(at: index) {
      return NSAttributedString(string: displayFormattedTime(for: messages[index].sentDate, on: .header),
                                attributes: messageStringAttributes(with: UIColor.gray))
    }

    return nil
  }

  func messageTimeGapHeight(at index: Int) -> CGFloat {
    return shouldDisplayTimeGap(at: index) ? 18 : 0
  }

  private func shouldDisplayTime(between previous: Message?, and next: Message?) -> Bool {
    // If the last message sent is older than an hour display the time text
    if let previous = previous,
      let next = next, next.sentDate.timeIntervalSince(previous.sentDate) > maxTimeBetweenMesssages {
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

  private func messageStringAttributes(with color: UIColor) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: color]
  }

  private func titleStringAttributes(with size: CGFloat) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: size),
            NSAttributedString.Key.foregroundColor: UIColor.black]
  }

  private func displayFormattedTime(for date: Date, on area: DateDisplayArea) -> String {
    switch area {
    case .header:
      return formattedHeaderTime(for: date)
    case .message:
      return formattedMessageTime(for: date)
    }
  }

  private func formattedMessageTime(for date: Date) -> String {
    chatDateFormatter.doesRelativeDateFormatting = false
    chatDateFormatter.dateFormat = "h:mm a"

    return chatDateFormatter.string(from: date)
  }

  private func formattedHeaderTime(for date: Date) -> String {
    switch true {
    case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
      chatDateFormatter.doesRelativeDateFormatting = true
      chatDateFormatter.dateStyle = .short
      chatDateFormatter.timeStyle = .short
    case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
      chatDateFormatter.dateFormat = "EEEE h:mm a"
    case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
      chatDateFormatter.dateFormat = "E, d MMM, h:mm a"
    default:
      chatDateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
    }

    return chatDateFormatter.string(from: date)
  }
}
