//
//  UserDetailViewModel.swift
//  RCDemo
//
//  Created by Craig Lane on 4/15/19.
//

import Foundation

struct UserDetailViewModel {
  var user: User

  init(with user: User = User.defaultSender) {
    self.user = user
  }
}
