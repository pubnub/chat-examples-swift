//
//  Presence.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class Presence: PNTestCase {

  /**
   * Receiving presence events
   */
  func testReceivingPresenceEvents() {
    let presenceExpectation = expectation(description: "Waiting for another user join.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    // tag::PRE-1[]
    pubnub.subscribe()
      // tag::ignore[]
      .channels([expectedChannel])
      /**
      // end::ignore[]
      .channels(["room-1"])
      // tag::ignore[]
       */
      // end::ignore[]
      .withPresence(true)
      .perform()
    // end::PRE-1[]

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        self.observerPubNubClient.subscribe()
          .channels([expectedChannel])
          .perform()
      }
    })

    registerPresenceHandler(pubnub, handler: { result in
      if result.data.presenceEvent == "join" &&
        result.data.presence.uuid == self.observerPubNubClient.uuid() {

        presenceExpectation.fulfill()
      }
    })

    wait(for: [presenceExpectation], timeout: 10)
  }

  /**
   * Requesting on-demand presence status
   */
  func testRequestPresenceStatus() {
    let presenceExpectation = expectation(description: "Waiting for another user join.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          // tag::PRE-2[]
          pubnub.presence().hereNow()
            // tag::ignore[]
            .channel(expectedChannel)
            /**
            // end::ignore[]
            .channel("room-1")
            // tag::ignore[]
             */
            // end::ignore[]
            .verbosity(.state)
            .performWithCompletion({ (result, status) in
              // handle state setting response
              // tag::ignore[]

              XCTAssertNil(status)
              XCTAssertNotNil(result)
              XCTAssertEqual(result?.data.occupancy.intValue, 1)

              XCTAssertNotNil(result?.data.uuids)

              if let uuids = result?.data.uuids as? [[String: Any]] {
                XCTAssertTrue(uuids[0]["uuid"] as? String == self.observerPubNubClient.uuid())
                XCTAssertNil(uuids[0]["state"])
              }

              presenceExpectation.fulfill()
              // end::ignore[]
            })
          // end::PRE-2[]
        }
      }
    })

    wait(for: [presenceExpectation], timeout: 10)
  }

  /**
   * Showing last online timestamp for a user.
   */
  func testShowingLastOnlineTimestamp() {
    // tag::PRE-3[]
    // TODO: need a sample here
    // end::PRE-3[]
  }
}
