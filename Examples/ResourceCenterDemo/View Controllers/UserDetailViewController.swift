//
//  UserDetailViewController.swift
//  RCDemo
//
//  Created by Craig Lane on 4/1/19.
//

import UIKit

class UserDetailViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!

  var viewModel: UserDetailViewModel?

  override func viewDidLoad() {
    super.viewDidLoad()

    if self.viewModel == nil {
      NSLog("UserDetailView using default view model")
    }

    // Do any additional setup after loading the view.
    self.title = viewModel?.user.displayName
    if let avatarImageName = viewModel?.user.avatarImageName {
      self.avatarImageView.image = UIImage(named: avatarImageName)
    }

    self.tableView.dataSource = self
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserDetailTableCell", for: indexPath)

    switch indexPath.row {
    case 0:
      cell.textLabel?.text = "UUID"
      cell.detailTextLabel?.text = viewModel?.user.uuid
    case 1:
      cell.textLabel?.text = "First Name"
      cell.detailTextLabel?.text = viewModel?.user.firstName
    case 2:
      cell.textLabel?.text = "Last Name"
      cell.detailTextLabel?.text = viewModel?.user.lastName
    default:
      cell.textLabel?.text = ""
      cell.detailTextLabel?.text = ""
    }

    return cell
  }
}
