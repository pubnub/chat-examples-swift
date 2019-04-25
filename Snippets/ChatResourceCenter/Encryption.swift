//
//  Encryption.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class Encryption: PNTestCase {

  /**
   * Enabling SSL/TLS encryption.
   */
  func testEnablingSSL_TLS_Encryption() {
    let uuid = UUID().uuidString

    // tag::ENCR-1[]
    let configuration = PNConfiguration(publishKey: publishKey,
                                        subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    configuration.TLSEnabled = true
    configuration.uuid = uuid
    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::ENCR-1[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid())
    XCTAssertEqual(pubnub.uuid(), uuid)
  }

  /**
   * Encrypting message payloads (using AES-256).
   */
  func testEncryptingMessagePayloadsUsingAES() {
    // tag::ENCR-2[]
    let configuration = PNConfiguration(publishKey: publishKey,
                                        subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    configuration.cipherKey = "myCipherKey"
    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::ENCR-2[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid())
  }
}
