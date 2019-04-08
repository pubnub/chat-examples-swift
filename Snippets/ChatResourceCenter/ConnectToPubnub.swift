//
//  ConnectToPubnub.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class ConnectToPubnub: PNTestCase {

  /**
   * PubNub integration.
   */
  func testSetup() {
    /**
    // tag::CON-1[]
    // Create Podfile in project root directory with following content:
    platform :ios, '9.0'
    use_frameworks!
    
    pod 'PubNub', '~> 4.0'
    
    target 'TargetName' do
    end
     
     
    /**
     * Make sure to replace 'TargetName' with your project target name before
     * running following command with Terminal from project root directory:
     */
    pod install
    
     
    /**
     * CocoaPods will create .xcworkspace file in project root directory which
     * you should use from now on.
     */
    // end::CON-1[]
    */
  }

  /**
   * Initializing PubNub.
   */
  func testInitializePubNub() {
    // tag::CON-2[]
    let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::CON-2[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid)
  }

  /**
   * Setting a unique ID for each user
   */
  func testSettingUniqueID() {
    // tag::CON-3[]
    let uuid = UUID().uuidString

    let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    configuration.uuid = uuid

    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::CON-3[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid)
    XCTAssert(pubnub.uuid() == uuid)
  }

  /**
   * Setting state for a user
   */
  func testSetStateForUser() {
    let stateExpectation = expectation(description: "Waiting for state get completion.")
    let expectedState = [ "mood": "grumpy" ]
    let pubnub: PubNub! = pubNubClient

    // tag::CON-4[]
    pubnub.state().set()
      .state([ "mood": "grumpy" ])
      .channels(["room-1"])
      .performWithCompletion({ status in
        // handle state setting response
        // tag::ignore[]

        XCTAssertNotNil(status)
        XCTAssertFalse(status.isError)

        if let status = status.data.state as? [String: String] {
          XCTAssertTrue(status == expectedState)
        } else {
          XCTAssert(false, "Unable to check 'state' value")
        }
        // end::ignore[]
      })
    // end::CON-4[]

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      // tag::CON-5[]
      pubnub.state().audit()
        .channels(["room-1"])
        .performWithCompletion({ (result, status) in
          // handle state getting response
          // tag::ignore[]

          XCTAssertNil(status)
          XCTAssertNotNil(result)

          if let status = result?.data.channels["room-1"] as? [String: Any] {
            XCTAssertTrue(status["mood"] as? String == expectedState["mood"])
          } else {
            XCTAssert(false, "Unable to check 'state' value")
          }

          stateExpectation.fulfill()
          // end::ignore[]
      })
      // end::CON-5[]
    }

    wait(for: [stateExpectation], timeout: 20)
  }

  /**
   * Disconnecting from PubNub.
   */
  func testDisconnectFromPubNub() {
    let leaveExpectation = expectation(description: "Waiting second user to leave chat.")
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels(["room-1"])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        pubnub.subscribe()
          .channels(["room-1"])
          .withPresence(true)
          .perform()
      }
    })

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          // tag::CON-6[]
          pubnub.unsubscribeFromAll()
          // end::CON-6[]
        }
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presenceEvent == "leave" && event.data.presence.uuid == pubnub.uuid() {
        leaveExpectation.fulfill()
      }
    })

    wait(for: [leaveExpectation], timeout: 10)
  }

  /**
   * Reconnecting Manually.
   */
  func testManualReconnect() {
    let pubnub: PubNub! = pubNubClient

    // tag::CON-7[]
    pubnub.subscribe().perform()
    // end::CON-7[]
  }
}
