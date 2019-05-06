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
    /**
     * First, run the following command from a Terminal window in your
     * project's root directory:
     */
    pod init


    /**
     * Next, edit the generated Podfile in your project root directory to be 
     * similar to the following:
     */
    //tag::CON-1[]
    # Uncomment the next line to define a global platform for your project
    platform :ios, '9.0'

    target 'AnimalForestChat' do
      # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
      use_frameworks!

      # Pods for AnimalForestChat
      pod 'PubNub'

      target 'AnimalForestChatTests' do
        inherit! :search_paths
        # Pods for testing
      end

      target 'AnimalForestChatUITests' do
        inherit! :search_paths
        # Pods for testing
      end

    end
    // end::CON-1[]
     
     
    /**
     * Make sure to replace 'AnimalForestChat' with your project target name
     * before running the following command from a Terminal window in your
     * project's root directory:
     */
    pod install
    
     
    /**
     * CocoaPods will create .xcworkspace file in project root
     * directory, which you should use from now on (instead of the
     * .xcodeproj created by Xcode).
     */
    */
  }

  /**
   * Initializing PubNub.
   */
  func testInitializePubNub() {
    // tag::CON-2[]
    let configuration = PNConfiguration(publishKey: publishKey,
                                        subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::CON-2[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid())
  }

  /**
   * Setting a unique ID for each user
   */
  func testSettingUniqueID() {
    let uuid = UUID().uuidString

    // tag::CON-3[]
    let configuration = PNConfiguration(publishKey: publishKey,
                                        subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false
    configuration.uuid = uuid

    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::CON-3[]

    XCTAssertNotNil(pubnub)
    XCTAssertNotNil(pubnub.uuid())
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
   * Reconnecting to PubNub.
   */
  func testReconnectToPubNub() {
    // tag::CON-7.1[]
    let configuration = PNConfiguration(publishKey: publishKey,
                                        subscribeKey: subscribeKey)
    // enable catchup on missed messages
    configuration.catchUpOnSubscriptionRestore = true
    configuration.stripMobilePayload = false
    let pubnub = PubNub.clientWithConfiguration(configuration)
    // end::CON-7.1[]

    // tag::CON-7.2[]
    /**
     * If connection availability check will be done in other way,
     * then use this  function to reconnect to PubNub.
     */
    pubnub.subscribe().perform()
    // end::CON-7.2[]

    XCTAssertNotNil(pubnub)
    XCTAssertTrue(pubnub.currentConfiguration().catchUpOnSubscriptionRestore)
  }
}
