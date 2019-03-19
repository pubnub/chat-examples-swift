//
//  ConnectToPubnub.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

class ConnectToPubnub: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Setting a unique ID for each user
   */
  func testSettingUniqueID() {
    // tag::CON-1[]
    print("Setting a unique ID for each user")
    // end::CON-1[]
  }

  /**
   Connecting with a user
   */
  func testConnectingWithUser() {
    // tag::CON-2[]
    print("Connecting with a user")
    // end::CON-2[]
  }

  /**
   Set metadata for a user
   */
  func testSetMetadataForUser() {
    // tag::CON-3[]
    print("Set metadata for a user")
    // end::CON-3[]
  }

  /**
   Disconnecting from PubNub
   */
  func testDisconnectFromPubnub() {
    // tag::CON-4[]
    print("Disconnecting from PubNub")
    // end::CON-4[]
  }

  /**
   Reconnecting to PubNub
   */
  func testReconnectingToPubnub() {
    // tag::CON-5[]
    print("Reconnecting to PubNub")
    // end::CON-5[]
  }
}
