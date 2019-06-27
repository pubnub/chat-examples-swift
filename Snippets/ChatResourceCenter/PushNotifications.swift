//
//  PushNotifications.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class PushNotifications: PNTestCase {

  /**
   * Adding a device token to channels.
   */
  func testAddingDeviceTokenToChannels() {
    let addExpectation = expectation(description: "Waiting for push notification enable.")
    if ProcessInfo.processInfo.environment["CI"] == nil {
        addExpectation.fulfill()
    }
    let expectedDeviceToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedDevice = expectedDeviceToken.data(using: .utf8)!
    let pubnub: PubNub! = pubNubClient

    let handleChannelsAdd = {
      pubnub.push().audit()
        .token(expectedDevice)
        .performWithCompletion({ (result, status) in
          XCTAssertNil(status)
          XCTAssertEqual(result?.data.channels.sorted(), expectedChannels.sorted())

          addExpectation.fulfill()
        })
    }

    // tag::PUSH-1[]
    pubnub.push().enable()
      // tag::ignore[]
      .channels(expectedChannels)
      .token(expectedDevice)
      /**
      // end::ignore[]
      .channels(["room-1", "room-2"])
      .token(deviceToken)
      // tag::ignore[]
       */
      // end::ignore[]
      .performWithCompletion({ status in
        // tag::ignore[]
        XCTAssertFalse(status.isError)
        handleChannelsAdd()

        // end::ignore[]
        if status.isError {
          print("operation failed w/ error: \(status.errorData.information)")
        } else {
          print("operation done!")
        }
      })
    // end::PUSH-1[]

    wait(for: [addExpectation], timeout: 10)
  }

  /**
   * Removing a device token from channels.
   */
  func testRemovingDeviceTokenFromChannels() {
    let removeExpectation = expectation(description: "Waiting for push notification disable.")
    if ProcessInfo.processInfo.environment["CI"] == nil {
        removeExpectation.fulfill()
    }
    let expectedDeviceToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedDevice = expectedDeviceToken.data(using: .utf8)!
    let pubnub: PubNub! = pubNubClient

    let handleChannelsRemove = {
      pubnub.push().audit()
        .token(expectedDevice)
        .performWithCompletion({ (result, status) in
          XCTAssertNil(status)
          XCTAssertEqual(result?.data.channels.sorted(), [])

          removeExpectation.fulfill()
        })
    }

    pubnub.push().enable()
      .channels(expectedChannels)
      .token(expectedDevice)
      .performWithCompletion({ status in
        XCTAssertFalse(status.isError)
        // tag::PUSH-2[]
        pubnub.push().disable()
          // tag::ignore[]
          .channels(expectedChannels)
          .token(expectedDevice)
          /**
          // end::ignore[]
          .channels(["room-1", "room-2"])
          .token(deviceToken)
          // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ status in
            // tag::ignore[]
            XCTAssertFalse(status.isError)
            handleChannelsRemove()

            // end::ignore[]
            if status.isError {
              print("operation failed w/ error: \(status.errorData.information)")
            } else {
              print("operation done!")
            }
          })
        // end::PUSH-2[]
      })

    wait(for: [removeExpectation], timeout: 10)
  }

  /**
   * Formatting your message payload for APNS and FCM.
   */
  func testFormattingMessagePayloadForAPNSandGCM() {
    let publishExpectation = expectation(description: "Waiting for published message.")
    if ProcessInfo.processInfo.environment["CI"] == nil {
        publishExpectation.fulfill()
    }
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    // tag::PUSH-3.1[]
    let messagePayload = [
      "pn_apns": [
        "aps": [
          "alert": "hi",
          "badge": 2,
          "sound": "melody"
        ],
        "c": "3"
      ],
      "pn_gcm": [
        "data": [ "summary": "Game update 49ers touchdown" ]
      ],
      "text": "Hello, hoomans!"
      ] as [String: Any]

    // end::PUSH-3.1[]

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::PUSH-3.2[]
        pubnub.publish()
          .message(messagePayload)
          // tag::ignore[]
          .channel(expectedChannel)
          /**
          // end::ignore[]
          .channel("room-1")
          // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ status in
            // handle status
            // tag::ignore[]

            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
            // end::ignore[]
          })
        // end::PUSH-3.2[]
      }
    })

    registerMessageHandler(observerPubNubClient, handler: { result in
      if let message = result.data.message as? [String: Any] {
        XCTAssertTrue(NSDictionary(dictionary: message).isEqual(to: messagePayload))
      } else {
        XCTAssert(false, "Unable to check message 'result'")
      }

      publishExpectation.fulfill()
    })

    wait(for: [publishExpectation], timeout: 10)
  }
}
