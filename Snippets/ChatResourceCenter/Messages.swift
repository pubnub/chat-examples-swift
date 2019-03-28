//
//  Messages.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

import PubNub

class Messages: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Sending messages
   */
  func testSendingMessages() {
    // tag::MSG-1[]
    print("Sending messages")
    // end::MSG-1[]
  }

  /**
   Receiving messages
   */
  func testReceivingMessages() {
    // tag::MSG-2[]
    print("Receiving messages")
    // end::MSG-2[]
  }

  /**
   Sending images and files
   */
  func testSendingImagesAndFiles() {
    // tag::MSG-3[]
    print("Sending images and files")
    // end::MSG-3[]
  }

  /**
   Sending typing indicators
   */
  func testSendingTypingIndicators() {
    // tag::MSG-4[]
    print("Sending typing indicators")
    // end::MSG-4[]
  }

  /**
   Sending read receipts
   */
  func testSendingReadReceipts() {
    // tag::MSG-5[]
    print("Sending read receipts")
    // end::MSG-5[]
  }

  /**
   Sending reactions on messages
   */
  func testSendingReactionsOnMessages() {
    // tag::MSG-6[]
    print("Sending reactions on messages")
    // end::MSG-6[]
  }

  /**
   Showing sender details and timestamp in the message
   */
  func testShowingSenderDetailsAndTimestamps() {
    // tag::MSG-7[]
    print("Showing sender details and timestamp in the message")
    // end::MSG-7[]
  }

  /**
   Updating messages
   */
  func testUpdatingMessages() {
    // tag::MSG-8[]
    print("Updating messages")
    // end::MSG-8[]
  }

  /**
   Deleting messages
   */
  func testDeletingMessages() {
    // tag::MSG-9[]
    print("Deleting messages")
    // end::MSG-9[]
  }

  /**
   Sending announcements to all users
   */
  func testSendingAnnouncementsToAllUsers() {
    // tag::MSG-10[]
    print("Sending announcements to all users")
    // end::MSG-10[]
  }
}
