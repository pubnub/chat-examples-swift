//
//  ManageChannels.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class ManageChannels: PNTestCase {

  /**
   * Subscribing to channels.
   */
  func testSubscribingToChannels() {
    let joinExpectation = expectation(description: "Waiting second user to join chat.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::CHAN-1[]
        pubnub.subscribe()
          // tag::ignore[]
          .channels([expectedChannel])
          /**
          // end::ignore[]
          .channels(["room-1"])
          // tag::ignore[]
           */
          // end::ignore[]
          .perform()
        // end::CHAN-1[]
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presenceEvent == "join" && event.data.presence.uuid == pubnub.uuid() {
        joinExpectation.fulfill()
      }
    })

    wait(for: [joinExpectation], timeout: 10)
  }

  /**
   * Joining multiple channels.
   */
  func testSubscribingToMultipleChannels() {
    let joinExpectation = expectation(description: "Waiting second user to join chat.")
    var channelsToJoin = [UUID().uuidString, UUID().uuidString, UUID().uuidString]
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels(channelsToJoin)
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::CHAN-2[]
        pubnub.subscribe()
          // tag::ignore[]
          .channels(channelsToJoin)
          /**
          // end::ignore[]
          .channels(["room-1", "room-2", "room-3"])
          // tag::ignore[]
           */
          // end::ignore[]
          .perform()
        // end::CHAN-2[]
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presenceEvent == "join" && event.data.presence.uuid == pubnub.uuid() {
        if let channelIdx = channelsToJoin.firstIndex(of: event.data.channel) {
          channelsToJoin.remove(at: channelIdx)
        }

        if channelsToJoin.count == 0 {
          joinExpectation.fulfill()
        }
      }
    })

    wait(for: [joinExpectation], timeout: 10)
  }

  /**
   * Leaving a channel.
   */
  func testUnsubscribingFromChannels() {
    let leaveExpectation = expectation(description: "Waiting second user to leave chat.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        pubnub.subscribe()
          .channels([expectedChannel])
          .perform()
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presenceEvent == "leave" && event.data.presence.uuid == pubnub.uuid() {
        leaveExpectation.fulfill()
      }
    })

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          // tag::CHAN-3[]
          pubnub.unsubscribe()
            // tag::ignore[]
            .channels([expectedChannel])
            /**
            // end::ignore[]
            .channels(["room-1"])
            // tag::ignore[]
             */
            // end::ignore[]
            .perform()
          // end::CHAN-3[]
        }
      }
    })

    wait(for: [leaveExpectation], timeout: 10)
  }

  /**
   * Joining a channel group.
   */
  func testSubscribingToChannelGroups() {
    let joinExpectation = expectation(description: "Waiting second user to join chat.")
    var expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedGroup = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels([expectedChannels[0]])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        pubnub.stream().add()
          .channels(expectedChannels)
          .channelGroup(expectedGroup)
          .performWithCompletion({ status in
            XCTAssertFalse(status.isError)

            // tag::CHAN-4[]
            pubnub.subscribe()
              // tag::ignore[]
              .channelGroups([expectedGroup])
              /**
              // end::ignore[]
              .channelGroups(["family"])
              // tag::ignore[]
               */
              // end::ignore[]
              .perform()
            // end::CHAN-4[]
          })
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presenceEvent == "join" && event.data.presence.uuid == pubnub.uuid() {
        joinExpectation.fulfill()
      }
    })

    wait(for: [joinExpectation], timeout: 10)
  }

  /**
   * Adding channels to channel groups.
   */
  func testAddingChannelsToGroup() {
    let addExpectation = expectation(description: "Waiting for channels addition to group.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedGroup = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    // tag::CHAN-5[]
    pubnub.stream().add()
      // tag::ignore[]
      .channels(expectedChannels)
      .channelGroup(expectedGroup)
      /**
      // end::ignore[]
      .channels(["son", "daughter"])
      .channelGroup("family")
      // tag::ignore[]
       */
      // end::ignore[]
      .performWithCompletion({ status in
        // tag::ignore[]
        XCTAssertFalse(status.isError)

        // end::ignore[]
        if status.isError {
          print("operation failed w/ error: \(status.errorData.information)")
        } else {
          print("operation done!")
        }
        // tag::ignore[]

        addExpectation.fulfill()
        // end::ignore[]
      })
    // end::CHAN-5[]

    wait(for: [addExpectation], timeout: 10)
  }

  /**
   * Removing channels from channel groups.
   */
  func testRemovingChannelsFromGroup() {
    let removeExpectation = expectation(description: "Waiting for channels removal from group.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedGroup = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    // tag::CHAN-6[]
    pubnub.stream().remove()
      // tag::ignore[]
      .channels([expectedChannels[0]])
      .channelGroup(expectedGroup)
      /**
      // end::ignore[]
      .channels(["son"])
      .channelGroup("family")
      // tag::ignore[]
       */
      // end::ignore[]
      .performWithCompletion({ status in
        // tag::ignore[]
        XCTAssertFalse(status.isError)

        // end::ignore[]
        if status.isError {
          print("operation failed w/ error: \(status.errorData.information)")
        } else {
          print("operation done!")
        }
        // tag::ignore[]

        removeExpectation.fulfill()
        // end::ignore[]
      })
    // end::CHAN-6[]

    wait(for: [removeExpectation], timeout: 10)
  }

  /**
   * Listing channels in a channel group.
   */
  func testChannelGroupAudit() {
    let auditExpectation = expectation(description: "Waiting for channel group audit.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedGroup = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    pubnub.stream().add()
      .channels(expectedChannels)
      .channelGroup(expectedGroup)
      .performWithCompletion({ addStatus in
        XCTAssertFalse(addStatus.isError)

        // tag::CHAN-7[]
        pubnub.stream().audit()
          // tag::ignore[]
          .channelGroup(expectedGroup)
          /**
          // end::ignore[]
          .channelGroup("family")
          // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ (result, status) in
          if let errorStatus = status {
            print("operation failed w/ error: \(errorStatus.errorData.information)")
            return
          }

          if let auditResults = result {
            // tag::ignore[]
            XCTAssertTrue(auditResults.data.channels.contains(expectedChannels[0]))
            XCTAssertTrue(auditResults.data.channels.contains(expectedChannels[1]))

            // end::ignore[]
            print("listing push channel for device")
            for channel in auditResults.data.channels {
              print(channel)
            }
            // tag::ignore[]
          } else {
            XCTAssert(false, "Unable to check channel group audit 'result'")
            // end::ignore[]
          }
          // tag::ignore[]

          auditExpectation.fulfill()
          // end::ignore[]
        })
        // end::CHAN-7[]
      })

    wait(for: [auditExpectation], timeout: 10)
  }

  /**
   * Leaving a channel group.
   */
  func testUnsubscribeFromChannelGroup() {
    let leaveExpectation = expectation(description: "Waiting second user to leave chat.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let expectedGroup = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    observerPubNubClient.subscribe()
      .channels([expectedChannels[1]])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        pubnub.stream().add()
          .channels(expectedChannels)
          .channelGroup(expectedGroup)
          .performWithCompletion({ status in
            XCTAssertFalse(status.isError)

            pubnub.subscribe()
              .channelGroups([expectedGroup])
              .perform()
          })
      }
    })

    registerPresenceHandler(observerPubNubClient, handler: { event in
      if event.data.presence.uuid == pubnub.uuid() {
        if event.data.presenceEvent == "join" {
          // tag::CHAN-8[]
          pubnub.unsubscribe()
            // tag::ignore[]
            .channelGroups([expectedGroup])
            /**
            // end::ignore[]
            .channelGroups(["family"])
            // tag::ignore[]
             */
            // end::ignore[]
            .perform()
          // end::CHAN-8[]
        } else if event.data.presenceEvent == "leave" {
          leaveExpectation.fulfill()
        }
      }
    })

    wait(for: [leaveExpectation], timeout: 10)
  }
}
