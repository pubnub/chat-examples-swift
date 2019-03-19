//
//  Admin.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

class Admin: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Automated Content Moderation
   */
  func testAutomatedContentModeration() {
    // tag::ADMIN-1[]
    print("Automated Content Moderation")
    // end::ADMIN-1[]
  }

  /**
   Manual Moderation
   */
  func testManualModeration() {
    // tag::ADMIN-2[]
    print("Manual Moderation")
    // end::ADMIN-2[]
  }

  /**
   Preventing spam
   */
  func testPreventingSpam() {
    // tag::ADMIN-3[]
    print("Preventing spam")
    // end::ADMIN-3[]
  }

  /**
   Deleting messages for a user
   */
  func testDeletingMessagessForUser() {
    // tag::ADMIN-4[]
    print("Deleting messages for a user")
    // end::ADMIN-4[]
  }

  /**
   Exporting messages in bulk
   */
  func testExportingMessagesInBulk() {
    // tag::ADMIN-5[]
    print("Exporting messages in bulk")
    // end::ADMIN-5[]
  }
}
