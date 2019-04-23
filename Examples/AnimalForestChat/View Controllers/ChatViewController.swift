//
//  ViewController.swift
//  chat-example
//
//  Created by Craig Lane on 3/12/19.
//

import UIKit

import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

  var viewModel: ChatViewModel!
  var titleView: UILabel?

  let channelDetailSegue = "ChatViewShowChannelDetailSegue"

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set Delegates
    self.messagesCollectionView.messagesDataSource = self
    self.messagesCollectionView.messagesLayoutDelegate = self
    self.messagesCollectionView.messagesDisplayDelegate = self
    self.messageInputBar.delegate = self

    // Title Bar
    self.setTitleView()

    // Set Custom Send Icon
    messageInputBar.sendButton.image = UIImage(named: "ic_send_arrow")
    messageInputBar.sendButton.title = nil
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.listener = { [weak self] (changeType) in
      DispatchQueue.main.async {
        switch changeType {
        case .messages:
          self?.messagesCollectionView.reloadData()
          self?.messagesCollectionView.scrollToBottom(animated: true)
        case .occupancy:
          self?.setTitleView()
        }
      }
    }
    self.viewModel.start()

    // Reload our dynamic values
    self.setTitleView()
    self.messagesCollectionView.reloadData()
  }

  func setTitleView() {
    if titleView == nil {
      // Create a Multiline Title Label
      titleView = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 35.0))
      titleView?.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
      titleView?.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
      titleView?.backgroundColor = UIColor.clear
      titleView?.numberOfLines = 0
      titleView?.textAlignment = NSTextAlignment.left

      // Add Channel Avatar to Title Bar
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
      imageView.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
      imageView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
      imageView.image = UIImage(named: viewModel.channelAvatarName)

      let stackView = UIStackView(arrangedSubviews: [imageView, titleView!])
      stackView.distribution = .fill
      stackView.alignment = .center
      stackView.spacing = 15

      self.navigationItem.titleView = stackView
    }

    titleView?.attributedText = viewModel.attributedChannelTitle
  }

  func nextMessage(of indexPath: IndexPath) -> Message? {
    guard indexPath.section + 1 < viewModel.messages.count else { return nil }
    return viewModel.messages[indexPath.section + 1]
  }

  func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
    guard indexPath.section - 1 >= 0 else { return false }
    return viewModel.messages[indexPath.section].senderId == viewModel.messages[indexPath.section - 1].senderId
  }

  func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
    guard indexPath.section + 1 < viewModel.messages.count else { return false }
    return viewModel.messages[indexPath.section].senderId == viewModel.messages[indexPath.section + 1].senderId
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case channelDetailSegue:
        let destination = segue.destination as? ChannelDetailsViewController
        destination?.viewModel = self.viewModel.channelDetailVieModel
      default:
        break
      }
    }
  }
}

// MARK: MessagesDataSource
extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
  func currentSender() -> SenderType {
    return viewModel.sender ?? User.defaultValue
  }

  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                       in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? UIColor.messageSender : UIColor.messageReceiver
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return viewModel.messages[indexPath.section]
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return viewModel.messages.count
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) {

    if let message = message as? Message, let avatarImageName = message.user?.avatarImageName {
      avatarView.image = UIImage(named: avatarImageName)
      avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
    }
  }

  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if viewModel.shouldDisplayTime(between: message as? Message, and: nextMessage(of: indexPath)) {
      return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                                             NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    return nil
  }

  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                          in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    if viewModel.shouldDisplayTime(between: message as? Message, and: nextMessage(of: indexPath)) {
      return 18
    }
    return 0
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return isPreviousMessageSameSender(at: indexPath) ? CGFloat.leastNonzeroMagnitude : 16
  }

  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return isPreviousMessageSameSender(at: indexPath) ? nil : viewModel.messageName(for: message as? Message)
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath,
                                in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return isNextMessageSameSender(at: indexPath) ? CGFloat.leastNonzeroMagnitude : 16
  }

  func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return isNextMessageSameSender(at: indexPath) ? nil : viewModel.messageDate(for: message as? Message)
  }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

    for component in inputBar.inputTextView.components {
      if let message = component as? String {
        viewModel.publish(message) { (_) in
          DispatchQueue.main.async { [weak self] in
            self?.messagesCollectionView.reloadData()
          }
        }
      }
    }
    DispatchQueue.main.async { [weak self] in
      self?.messagesCollectionView.reloadData()
      inputBar.inputTextView.text = String()
      self?.messagesCollectionView.scrollToBottom(animated: true)
    }
  }
}
