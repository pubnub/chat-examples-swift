//
//  ChannelDetailsViewController.swift
//  RCDemo
//
//  Created by Craig Lane on 4/8/19.
//

import UIKit

class ChannelDetailsViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var channelDescriptionLabel: UILabel!
  @IBOutlet weak var activeMemberTableView: UITableView!

  var viewModel: ChannelDetailsViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Name of chatroom
    self.title = self.viewModel.chatroomTitle
    // Description of chatroom
    self.channelDescriptionLabel.text = self.viewModel?.chatroomDescription

    self.activeMemberTableView.dataSource = self
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

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.activeMembers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.activeMemberTableView.dequeueReusableCell(withIdentifier: "MemberStatusCell", for: indexPath)

    cell.textLabel?.text = self.viewModel.activeMembers[indexPath.row].displayName

    return cell
  }
}
