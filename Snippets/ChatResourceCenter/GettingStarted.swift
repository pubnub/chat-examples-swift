//
//  GettingStarted.swift
//  Snippets
//
//  Created by Craig Lane on 3/14/19.
//

import XCTest

import PubNub

class GettingStarted: XCTestCase {

  var pubnub: PubNubClient!

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
    pubnub = PubNubClient(with: configuration)
    XCTAssert(pubnub.client.uuid() == configuration.uuid)
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    pubnub.client.unsubscribeFromAll()
  }

  /**
   Hello World
   */
  func testHelloWorld() {
    // tag::helloWorld[]
    print("Hello World")
    // tag::ignore[]
    XCTAssertTrue(true)
    // end::ignore[]
    // end::helloWorld[]
  }

  /**
   Joining a Chat
   */
  func testInit() {
    let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
    let client = PubNub.clientWithConfiguration(configuration)

    XCTAssert(client.uuid() == configuration.uuid)
  }

  /**
   Joining a Chat
   */
  func testJoiningChannel() {

    pubnub.client.subscribeToChannels(["room-1"], withPresence: false)

    XCTAssertTrue(pubnub.client.isSubscribed(on: "room-1"))
  }

  /**
   Joining Multiple Channels
   */
  func testJoiningMultipleChannels() {

    pubnub.client.subscribeToChannels(["room-1", "room-2", "room-3"], withPresence: false)

    XCTAssertTrue(pubnub.client.isSubscribed(on: "room-1"))
    XCTAssertTrue(pubnub.client.isSubscribed(on: "room-2"))
    XCTAssertTrue(pubnub.client.isSubscribed(on: "room-3"))
  }

  /**
   Sending a Message
   */
  func testSendingMessage() {
    let expectation = XCTestExpectation(description: "Waiting for publish")

    pubnub.client.publish("Hello Channel", toChannel: "room-1") { (status) in

      // tag::ignore[]
      XCTAssertFalse(status.isError)
      expectation.fulfill()
      // end::ignore[]
    }
  }
}
