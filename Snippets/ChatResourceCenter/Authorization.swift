//
//  Authorization.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

class Authorization: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Setting up secure channels
   */
  func testSettingUpSecureChannels() {
    // tag::PAM-1[]
    print("Setting up secure channels")
    // end::PAM-1[]
  }

  /**
   Granting read/write access for users
   */
  func testGrantingReadWriteAccess() {
    // tag::PAM-2[]
    print("Granting read/write access for users")
    // end::PAM-2[]
  }

  /**
   Extending access for users
   */
  func testExtendingAccessForUsers() {
    // tag::PAM-3[]
    print("Extending access for users")
    // end::PAM-3[]
  }

  /**
   Revoking access for users
   */
  func testRevokingAccessForUsers() {
    // tag::PAM-4[]
    print("Revoking access for users")
    // end::PAM-4[]
  }

  /**
   Banning and kicking users
   */
  func testBanningAndKickingUsers() {
    // tag::PAM-5[]
    print("Banning and kicking users")
    // end::PAM-5[]
  }
}
