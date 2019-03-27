//
//  Presence.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

import PubNub

class Presence: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Displaying online/offline status for users
   */
  func testDisplayingOnlineOfflineStatus() {
    // tag::PRE-1[]
    print("Displaying online/offline status for users")
    // end::PRE-1[]
  }

  /**
   Showing occupancy of members
   */
  func testShowingOccupancyOfMembers() {
    // tag::PRE-2[]
    print("Showing occupancy of members")
    // end::PRE-2[]
  }

  /**
   Showing last online timestamp for a user
   */
  func testShowingLastOnlineTimestamp() {
    // tag::PRE-3[]
    print("Showing last online timestamp for a user")
    // end::PRE-3[]
  }

  /**
   Presence webhooks
   */
  func testPresenceWebhooks() {
    // tag::PRE-4[]
    print("Presence webhooks")
    // end::PRE-4[]
  }
}
