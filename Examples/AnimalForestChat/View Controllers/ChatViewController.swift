//
//  ViewController.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 3/12/19.
//

import UIKit

import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

  var viewModel: ChatViewModel!
  var titleView: UILabel?

  let outgoingAvatarOverlap: CGFloat = 17.5
  let chatRoomDetailSegue = "ChatViewShowRoomDetailSegue"

  let messageDateFormatter = DateFormatter()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set Delegates
    self.messagesCollectionView.messagesDataSource = self
    self.messagesCollectionView.messagesLayoutDelegate = self
    self.messagesCollectionView.messagesDisplayDelegate = self
    self.messageInputBar.delegate = self

    // Configure Message Date Formatter
    messageDateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // Title Bar
    self.setTitleView()

    // Set Custom Send Icon
    messageInputBar.sendButton.image = UIImage(named: "ic_send_arrow")
    messageInputBar.sendButton.title = nil

    // Configure MessageKit to auto-scroll when keyboard is displayed
    scrollsToBottomOnKeyboardBeginsEditing = true
    maintainPositionOnKeyboardFrameChanged = true

    // Ensure the Avatar images are aligned with the bottom of the message
    let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout

    layout?.textMessageSizeCalculator.incomingAvatarPosition = AvatarPosition(vertical: .messageBottom)
    layout?.textMessageSizeCalculator.outgoingAvatarPosition = AvatarPosition(vertical: .messageBottom)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Bind to the View Model
    self.viewModel.listener = { [weak self] (changeType) in
      DispatchQueue.main.async {
        switch changeType {
        case .messages:
          self?.messagesCollectionView.reloadData()
          self?.messagesCollectionView.scrollToBottom(animated: true)
        case .occupancy:
          self?.setTitleView()
        case .connected(let isConnected):
          if isConnected {
            self?.messageInputBar.shouldManageSendButtonEnabledState = true
            // Enable the send button only if there is text entered
            if !(self?.messageInputBar.inputTextView.text.isEmpty ?? true) {
              self?.messageInputBar.sendButton.isEnabled = true
            }
          } else {
            self?.messageInputBar.shouldManageSendButtonEnabledState = false
            self?.messageInputBar.sendButton.isEnabled = false
          }
          self?.setTitleView()
        }
      }
    }
    self.viewModel.bind()

    // Reload our dynamic values and scroll to bottom
    self.setTitleView()
    self.messagesCollectionView.reloadData()
    self.messagesCollectionView.scrollToBottom(animated: true)
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

      // Add Chat Room Avatar to Title Bar
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
      imageView.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
      imageView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
      imageView.image = viewModel.chatRoom.avatar

      let stackView = UIStackView(arrangedSubviews: [imageView, titleView!])
      stackView.distribution = .fill
      stackView.alignment = .center
      stackView.spacing = 15

      self.navigationItem.titleView = stackView
    }

    titleView?.attributedText = viewModel.chatRoomAttributedTitle
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case chatRoomDetailSegue:
        let destination = segue.destination as? ChatRoomDetailsViewController
        destination?.viewModel = self.viewModel.chatRoomDetailViewModel
      default:
        break
      }
    }
  }
}

// MARK: MessagesDataSource
extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
  func currentSender() -> SenderType {
    // MessageKit requires a non-optional sender, so we just create an anonymous User
    return viewModel.sender ?? User(uuid: "Anonymous", altId: "Anonymous",
                                    firstName: "Not-A", lastName: "Moose",
                                    designation: nil, avatarName: nil)
  }

  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                       in messagesCollectionView: MessagesCollectionView) -> UIColor {

    return viewModel.messages[indexPath.section].defaultBackgroundColor
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return viewModel.messages[indexPath.section]
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return viewModel.messages.count
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) {
    avatarView.isHidden = viewModel.isMessageAvatarHidden(at: indexPath.section)
    avatarView.image = viewModel.messages[indexPath.section].user?.avatar
  }

  // MARK: Cell Top
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if viewModel.shouldDisplayTimeGap(at: indexPath.section) {
      return viewModel.messages[indexPath.section].attributedHeader(using: messageDateFormatter)
    }
    return nil
  }

  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                          in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return viewModel.shouldDisplayTimeGap(at: indexPath.section) ? 18 : 0
  }

  // MARK: Message Top
  func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if viewModel.shouldDisplayMessageSender(at: indexPath.section) {
      return viewModel.messages[indexPath.section].user?.attributedBodyHeader
    }
    return nil
  }

  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return viewModel.shouldDisplayMessageSender(at: indexPath.section) ? 16 : 0
  }

  // MARK: Message Bottom
  func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if viewModel.shouldDisplayMessageTime(at: indexPath.section) {
      return viewModel.messages[indexPath.section].attributedBodyHeader(using: messageDateFormatter)
    }
    return nil
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath,
                                in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return viewModel.shouldDisplayMessageTime(at: indexPath.section) ? 16 : 0
  }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

    for component in inputBar.inputTextView.components {
      if let message = component as? String {
        viewModel.send(message) { (_) in
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
