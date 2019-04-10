//
//  MessageHistory.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//
import XCTest
import PubNub

class MessageHistory: PNTestCase {

  /**
   * Retrieving message counts.
   */
  func testRetrievingMessageCounts() {
    let countExpectation = expectation(description: "Waiting for channels messages count.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString]
    let pubnub: PubNub! = pubNubClient
    var timetoken: NSNumber!

    let fetchMessagesCount = { () -> Void in
      // tag::HIST-1[]
      pubnub.messageCounts()
        // tag::ignore[]
        .channels(expectedChannels)
        .timetokens([timetoken])
        /**
        // end::ignore[]
        .channels(["channel-1", "channel-2"])
        .timetokens([NSNumber.init(value: 15518041524300251)])
        // tag::ignore[]
         */
        // end::ignore[]
        .performWithCompletion({ (result, status) in
          // handle status, response
          // tag::ignore[]
          XCTAssertNil(status)
          XCTAssertNotNil(result)

          // end::ignore[]
          if let errorStatus = status {
            print(errorStatus)
          }

          if let countResult = result {
            print(countResult)
            // tag::ignore[]

            XCTAssertEqual(countResult.data.channels[expectedChannels[0]], NSNumber.init(value: 1))
            XCTAssertEqual(countResult.data.channels[expectedChannels[1]], NSNumber.init(value: 1))
          } else {
            XCTAssert(false, "Unable to check message count 'result'")
            // end::ignore[]
          }
          // tag::ignore[]

          countExpectation.fulfill()
          // end::ignore[]
        })
      // end::HIST-1[]
    }

    publishMessage(pubnub, channel: expectedChannels[0], completion: { messageTimetoken in
      timetoken = NSNumber.init(value: messageTimetoken.intValue - 1)

      self.publishMessage(pubnub, channel: expectedChannels[1], completion: { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          fetchMessagesCount()
        }
      })
    })

    wait(for: [countExpectation], timeout: 10)
  }

  /**
   * Retrieving past messages from history.
   */
  func testRetrievingPastMessages() {
    let historyExpectation = expectation(description: "Waiting for channel history fetch.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    var timetoken: NSNumber!

    let fetchMessagesHistory = { () -> Void in
      // tag::HIST-2[]
      pubnub.history()
        // tag::ignore[]
        .channel(expectedChannel)
        .end(timetoken)
        /**
        // end::ignore[]
        .channel("room-1")
        .limit(50) // how many items to fetch
        .end(NSNumber.init(value: 13827485876355504)) // timetoken of the last message
        // tag::ignore[]
         */
        // end::ignore[]
        .reverse(false)
        .performWithCompletion({ (result, status) in
          // handle status, response
          // tag::ignore[]

          XCTAssertNil(status)
          XCTAssertNotNil(result)
          XCTAssertNotNil(result?.data.messages)
          XCTAssertEqual(result?.data.messages.count, 2)

          historyExpectation.fulfill()
          // end::ignore[]
        })
      // end::HIST-2[]
    }

    publishMessage(pubnub, channel: expectedChannel, completion: { _ in
      self.publishMessage(pubnub, channel: expectedChannel, completion: { messageTimetoken in
        timetoken = NSNumber(value: messageTimetoken.intValue - 1)

        self.publishMessage(pubnub, channel: expectedChannel, completion: { _ in
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            fetchMessagesHistory()
          }
        })
      })
    })

    wait(for: [historyExpectation], timeout: 10)
  }

  /**
   * Retrieving more than 100 messages from history.
   */
  func testRetrievingMoreThan100Messages() {
    let historyExpectation = expectation(description: "Waiting for channel history fetch.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    var historyCallsCount = 0

    // tag::HIST-3[]
    var getAllMessages: ((NSNumber?) -> Void)!
    getAllMessages = { timetoken in
      var builder = pubnub.history()
        // tag::ignore[]
        .channel(expectedChannel)
        /**
        // end::ignore[]
        .channel("room-1")
        // tag::ignore[]
         */
        // end::ignore[]
        .reverse(false)

      if let startTimetoken = timetoken {
        builder = builder.start(startTimetoken)  // start time token to fetch
      }

      builder
        .performWithCompletion({ (result, status) in
          // tag::ignore[]
          XCTAssertNil(status)
          XCTAssertNotNil(result)
          XCTAssertNotNil(result?.data.messages)

          // end::ignore[]
          if let historyResult = result {
            let messages = historyResult.data.messages
            let start = historyResult.data.start
            let end = historyResult.data.end

            if messages.count > 0 {
              print("count: \(messages.count)")
              print("start: \(start)")
              print("end: \(end)")
            }

            if messages.count == 100 {
              getAllMessages(start)
            }
          }
          // tag::ignore[]

          historyCallsCount += 1
          if historyCallsCount == 2 {
            print("fullfill")
            historyExpectation.fulfill()
          }
          // end::ignore[]
        })
    }

    // Usage examples:
    // getAllMessages(nil);
    // end::HIST-3[]

    publishMultipleMessages(pubnub, channel: expectedChannel, count: 150, completion: { _ in
      getAllMessages(nil)
    })

    wait(for: [historyExpectation], timeout: 120)
  }

  /**
   * Retrieving messages on multiple chat rooms.
   */
  func testRetrievingPastMessagesForMultipleChannels() {
    let historyExpectation = expectation(description: "Waiting for channels history fetch.")
    let expectedChannels = [UUID().uuidString, UUID().uuidString, UUID().uuidString]
    var timetokens: [String: [NSNumber]] = [:]
    let pubnub: PubNub! = pubNubClient

    let fetchMultipleHistory = {
      let startTimetokens = timetokens[expectedChannels[0]]!
      let endTimetokens = timetokens[expectedChannels[1]]!
      let startTokenIdx = Int((Double(startTimetokens.count) * 0.1).rounded())
      let endTokenIdx = Int((Double(endTimetokens.count) * 0.8).rounded())

      // tag::HIST-4[]
      pubnub.history()
        // tag::ignore[]
        .channels(expectedChannels)
        .start(startTimetokens[startTokenIdx])
        .end(endTimetokens[endTokenIdx])
        /**
        // end::ignore[]
        .channels(["ch1", "ch2", "ch3"])
        .start(NSNumber.init(value: 15343325214676133))
        .end(NSNumber.init(value: 15343325004275466))
        // tag::ignore[]
         */
        // end::ignore[]
        .limit(15)
        .performWithCompletion({ (result, status) in
          // handle status, response
          // tag::ignore[]

          XCTAssertNil(status)
          XCTAssertNotNil(result)

          if let historyResult = result {
            for(_, messages) in historyResult.data.channels {
              XCTAssertGreaterThan(messages.count, 10)
            }
          } else {
            XCTAssert(false, "Unable to check history fetch 'result'")
          }

          historyExpectation.fulfill()
          // end::ignore[]
        })
      // end::HIST-4[]
    }

    let handleMessagesPublish: ((String, [NSNumber]) -> Void) = { (channel, messageTimetokens) in
      timetokens[channel] = messageTimetokens

      if timetokens.count == 3 {
        fetchMultipleHistory()
      }
    }

    publishMultipleMessages(pubnub, channel: expectedChannels[0], count: 40,
                            completion: { messageTimetokens in

      handleMessagesPublish(expectedChannels[0], messageTimetokens)
    })

    publishMultipleMessages(pubnub, channel: expectedChannels[1], count: 40,
                            completion: { messageTimetokens in

      handleMessagesPublish(expectedChannels[1], messageTimetokens)
    })

    publishMultipleMessages(pubnub, channel: expectedChannels[2], count: 40,
                            completion: { messageTimetokens in

      handleMessagesPublish(expectedChannels[2], messageTimetokens)
    })

    wait(for: [historyExpectation], timeout: 120)
  }
}
