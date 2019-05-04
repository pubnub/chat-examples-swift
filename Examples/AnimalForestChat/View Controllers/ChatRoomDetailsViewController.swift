//
//  ChatRoomDetailsViewController.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/8/19.
//

import UIKit

class ChatRoomDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var roomAvatarImageView: UIImageView!
  @IBOutlet weak var roomDescriptionLabel: UILabel!

  @IBOutlet weak var activeMemberTableView: UITableView!

  var viewModel: ChatRoomDetailsViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    activeMemberTableView.register(UINib(nibName: "UserDetailTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "UserDetailTableViewCell")

    // Name of chatroom
    self.title = viewModel.chatRoom.name

    // Description of chatroom
    roomDescriptionLabel.text = viewModel.chatRoom.description
    roomAvatarImageView.image = viewModel.chatRoom.avatar

    activeMemberTableView.dataSource = self
    activeMemberTableView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Bind to the View Model
    self.viewModel?.bind { (changeEvent) in
      switch changeEvent {
      case .occupancy:
        DispatchQueue.main.async { [weak self] in
          self?.activeMemberTableView.reloadData()
        }
      }
    }

    self.activeMemberTableView.reloadData()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.activeMembers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = activeMemberTableView.dequeueReusableCell(withIdentifier: "UserDetailTableViewCell", for: indexPath)

    if let userDetailCell = cell as? UserDetailTableViewCell, let user = viewModel.activeMember(at: indexPath) {
      userDetailCell.displayNameLabel.text = user.body
      userDetailCell.designationLabel.text = user.bodyFooter
      userDetailCell.avatarImageView.image = user.avatar

      return userDetailCell
    } else {
      cell.textLabel?.text = viewModel.activeMember(at: indexPath)?.body

      return cell
    }
  }
}
