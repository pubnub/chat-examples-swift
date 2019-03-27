//
//  PushNotifications.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

import PubNub

class PushNotifications: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Sending push notifications via FCM
   */
  func testSendingPushNotificationViaFCM() {
    // tag::PUSH-1[]
    print("Sending push notifications via FCM")
    // end::PUSH-1[]
  }

  /**
   Sending push notifications via APNS
   */
  func testSendingPushNotificationViaAPNS() {
    // tag::PUSH-2[]
    print("Sending push notifications via APNS")
    // end::PUSH-2[]
  }
}
