//
//  ChannelDetailsViewController.swift
//  RCDemo
//
//  Created by Craig Lane on 4/8/19.
//

import UIKit

class ChannelDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var channelDescriptionLabel: UILabel!
  @IBOutlet weak var activeMemberTableView: UITableView!
  @IBOutlet weak var channelAvatarImageView: UIImageView!

  var viewModel: ChannelDetailsViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    activeMemberTableView.register(UINib(nibName: "UserDetailTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "UserDetailTableViewCell")

    //self.activeMemberTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserDetailTableViewCell")

    // Name of chatroom
    self.title = viewModel.chatroomTitle

    // Description of chatroom
    channelDescriptionLabel.text = viewModel.chatroomDescription
    channelAvatarImageView.image = UIImage(named: viewModel.channelAvatarName)

    activeMemberTableView.dataSource = self
    activeMemberTableView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel?.start { (changeEvent) in
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
      userDetailCell.displayNameLabel.text = viewModel.occupantDisplayName(for: user)
      userDetailCell.designationLabel.text = viewModel.occupantDesignation(for: user)

      if let avatarName = viewModel.occupantAvatarImageName(for: user) {
        userDetailCell.avatarImageView.image = UIImage(named: avatarName)
      }

      return userDetailCell
    } else {
      cell.textLabel?.text = viewModel.activeMember(at: indexPath)?.displayName

      return cell
    }
  }
}
