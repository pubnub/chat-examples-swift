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

  let userDetailSegue = "ChatViewShowUserDetailSegue"
  let channelDetailSegue = "ChatViewShowChannelDetailSegue"

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messagesCollectionView.messagesDataSource = self
    self.messagesCollectionView.messagesLayoutDelegate = self
    self.messagesCollectionView.messagesDisplayDelegate = self

    self.messageInputBar.delegate = self

    // Create a new button
    let button = UIButton(type: .custom)
    button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
    button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true

    if let imageName = viewModel.sender.avatarImageName {
      button.setImage(UIImage(named: imageName), for: .normal)
    }
    // Add function for button
    button.addTarget(self, action: #selector(userDetailButtonPressed), for: .touchUpInside)
    // Set frame
    button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    // Assign button to navigationbar
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

    // Title Bar
    self.setTitleView()
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

  @objc func userDetailButtonPressed() {
    self.performSegue(withIdentifier: userDetailSegue, sender: nil)
  }

  func setTitleView() {
    if titleView == nil {
      // Setting to 0 to force min-width
      titleView = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 44.0))
      titleView?.backgroundColor = UIColor.clear
      titleView?.numberOfLines = 0
      titleView?.textAlignment = NSTextAlignment.center
    }

    titleView?.text = viewModel.channelTitle
    navigationItem.titleView = titleView
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
      case userDetailSegue:
        let destination = segue.destination as? UserDetailViewController
        destination?.viewModel = UserDetailViewModel(with: self.viewModel.sender)
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
    return viewModel.sender
  }

  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return viewModel.messages[indexPath.section]
  }

  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return viewModel.messages.count
  }

  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) {

    if let message = message as? Message, let avatarImageName = message.user.avatarImageName {
      avatarView.image = UIImage(named: avatarImageName)
      avatarView.isHidden = isNextMessageSameSender(at: indexPath)
      avatarView.layer.borderWidth = 2
    }
  }

  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath,
                                in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    return isNextMessageSameSender(at: indexPath) ? CGFloat.leastNonzeroMagnitude : 16
  }

  func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    return isNextMessageSameSender(at: indexPath) ? nil : viewModel.detailText(for: message as? Message)
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
