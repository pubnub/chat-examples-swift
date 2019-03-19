//
//  Encryption.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest

class Encryption: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /**
   Enabling SSL/TLS encryption
   */
  func testEnablingSSL_TLS_Encryption() {
    // tag::ENCR-1[]
    print("Enabling SSL/TLS encryption")
    // end::ENCR-1[]
  }

  /**
   Encrypting message payloads (using AES-256)
   */
  func testEncryptingMessagePayloadsUsingAES() {
    // tag::ENCR-2[]
    print("Encrypting message payloads (using AES-256)")
    // end::ENCR-2[]
  }
}
