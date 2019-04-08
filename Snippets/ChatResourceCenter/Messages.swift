//
//  Messages.swift
//  Snippets
//
//  Created by Craig Lane on 3/19/19.
//

import XCTest
import PubNub

class Messages: PNTestCase {

  /**
   * Sending messages.
   */
  func testSendingMessages() {
    let publishExpectation = expectation(description: "Waiting for publish completion.")
    let expectedChannel = UUID().uuidString
    let expectedUUID = pubNubClient.uuid()
    let expectedMessage = "Hello, hoomans!"
    let pubnub: PubNub! = pubNubClient
    let expectedSenderID = "user123"

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .withPresence(true)
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::MSG-1[]
        pubnub.publish()
          .message([
            "senderId": "user123",
            "text": "Hello, hoomans!"
          ])
          // tag::ignore[]
          .channel(expectedChannel)
          /**
          // end::ignore[]
          .channel("room-1")
          // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ status in
            // handle status, response
            // tag::ignore[]

            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
            // end::ignore[]
          })
        // end::MSG-1[]
      }
    })

    registerMessageHandler(observerPubNubClient, handler: { result in
      XCTAssertTrue(result.data.publisher == expectedUUID)
      XCTAssertTrue(result.data.channel == expectedChannel)

      if let message = result.data.message as? [String: String] {
        XCTAssertTrue(message["senderId"] == expectedSenderID)
        XCTAssertTrue(message["text"] == expectedMessage)
      } else {
        XCTAssert(false, "Unable to check message 'result'")
      }

      publishExpectation.fulfill()
    })

    wait(for: [publishExpectation], timeout: 10)
  }

  /**
   * Receiving messages.
   */
  func testReceivingMessages() {
    let messageExpectation = expectation(description: "Waiting for published message.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    var presenceReceived = false
    var messageReceived = false

    pubnub.subscribe()
      .channels([expectedChannel])
      .withPresence(true)
      .perform()

    let handleMessage = {
      messageReceived = true

      if messageReceived && presenceReceived {
        messageExpectation.fulfill()
      }
    }

    let handlePresence = {
      presenceReceived = true

      if messageReceived && presenceReceived {
        messageExpectation.fulfill()
      }
    }

    let publishSampleMessage = {
      pubnub.publish()
        .message([
          "senderId": "user123",
          "title": "Message",
          "description": "Testing message handling"
        ])
        .channel(expectedChannel)
        .performWithCompletion({ status in
          XCTAssertFalse(status.isError)
          XCTAssertNotNil(status.data.timetoken)
        })
    }

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        publishSampleMessage()
      }
    })

    registerMessageHandler(pubnub, handler: { result in
      XCTAssertTrue(result.data.publisher == pubnub.uuid())

      handleMessage()
    })

    registerPresenceHandler(pubnub, handler: { result in
      XCTAssertTrue(result.data.presenceEvent == "join")
      XCTAssertTrue(result.data.presence.uuid == pubnub.uuid())

      handlePresence()
    })

    /**
    // tag::MSG-2[]
    // Add 'PNObjectEventListener' protocol to class which would like to receive updates.
    class PNTestCase: XCTestCase, PNObjectEventListener {
      func client(_ client: PubNub, didReceive status: PNStatus) {
        if status.operation == .subscribeOperation {
          publishSampleMessage()
        }
      }
    
      func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if let receivedMessage = message.data.message as? [String: Any] {
          print("Title: \(receivedMessage["title"])")
          print("Description: \(receivedMessage["description"])")
        }
      }
    
      func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        // handle presence
      }
    }
     
    /**
     * When PubNub client will be ready, add class which adopt 'PNObjectEventListener'
     * protocol as listener.
     */
    pubnub.addListener(self)
    // end::MSG-2[]
     */

    wait(for: [messageExpectation], timeout: 10)
  }

  /**
   * Sending images and files.
   */
  func testSendingImagesAndFiles() {
    // tag::MSG-3[]
    // TODO: need a sample here
    // end::MSG-3[]
  }

  /**
   * Sending typing indicators.
   */
  func testSendingTypingIndicators() {
    let messageExpectation = expectation(description: "Waiting for published message.")
    let expectedChannel = UUID().uuidString
    let expectedUUID = pubNubClient.uuid()
    let pubnub: PubNub! = pubNubClient
    let expectedSenderID = "user123"

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .perform()

    let fetchHistory = {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.observerPubNubClient.history()
          .channel(expectedChannel)
          .performWithCompletion({ (result, status) in
            XCTAssertNil(status)
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.data.messages.count, 0)

            messageExpectation.fulfill()
          })
      }
    }

    let publishMessage = {
      // tag::MSG-4[]
      pubnub.publish()
        .message([
          "senderId": "user123",
          "isTyping": true
        ])
        // tag::ignore[]
        .channel(expectedChannel)
        /**
        // end::ignore[]
        .channel("room-1")
        // tag::ignore[]
         */
        // end::ignore[]
        .shouldStore(false)
        .performWithCompletion({ status in
          // handle status, response
          // tag::ignore[]

          XCTAssertFalse(status.isError)
          XCTAssertNotNil(status.data.timetoken)
          // end::ignore[]
        })
      // end::MSG-4[]
    }

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        publishMessage()
      }
    })

    registerMessageHandler(observerPubNubClient, handler: { result in
      XCTAssertTrue(result.data.publisher == expectedUUID)
      XCTAssertTrue(result.data.channel == expectedChannel)

      if let message = result.data.message as? [String: Any] {
        XCTAssertTrue(message["senderId"] as? String == expectedSenderID)
        XCTAssertNotNil(message["isTyping"])

        fetchHistory()
      } else {
        XCTAssert(false, "Unable to check received message 'result'")
      }
    })

    wait(for: [messageExpectation], timeout: 10)
  }

  /**
   * Showing timestamp in the message.
   */
  func testShowTimestampInMessage() {
    let messageExpectation = expectation(description: "Waiting for published message.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient

    pubnub.subscribe()
      .channels([expectedChannel])
      .perform()

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        pubnub.publish()
          .message([
            "senderId": "user123",
            "title": "Message"
          ])
          .channel(expectedChannel)
          .performWithCompletion({ status in
            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
          })
      }
    })

    registerMessageHandler(pubnub, handler: { message in
      /**
      // tag::MSG-5[]
      func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
      // tag::ignore[]
       */
      // end::ignore[]
        let unixTimestamp = Double(message.data.timetoken.uint64Value / 10000000)
        let gmtDate = Date.init(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let localeDateTime: String = dateFormatter.string(from: gmtDate)
        // tag::ignore[]
        XCTAssertNotNil(gmtDate)
        XCTAssertNotNil(localeDateTime)
        XCTAssertGreaterThan(localeDateTime.count, 0)
      /**
      // end::ignore[]
      }
      // end::MSG-5[]
       */

      messageExpectation.fulfill()
    })

    wait(for: [messageExpectation], timeout: 10)
  }

  /**
   * Updating and deleting messages.
   */
  func testSendingReactionsOnMessages() {
    let messageExpectation = expectation(description: "Waiting for published message.")
    var messagesList: [String: [String: PNMessageResult]] = [:]
    let expectedText = "Fixed. I had a typo earlier..."
    var messageIDs: [String: [String]] = [:]
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    var messageTimetoken: String?
    var messageUpdateSent = false

    let handleMessage: ((_ message: PNMessageResult) -> Void) = { message in
      let messageId: String = message.data.timetoken.stringValue

      if messagesList[message.data.channel] == nil {
        messagesList[message.data.channel] = [:]
      }

      if messageIDs[message.data.channel] == nil {
        messageIDs[message.data.channel] = []
      }

      if let messageBody = message.data.message as? [String: Any] {
        if !messageIDs[message.data.channel]!.contains(messageId) {
          messagesList[message.data.channel]![messageId] = message
          messageIDs[message.data.channel]!.append(messageId)
        } else if messageBody["deleted"] as? Bool ?? false {
          messagesList[message.data.channel]!.removeValue(forKey: messageId)

          if let channelIdx = messageIDs[message.data.channel]!.firstIndex(of: messageId) {
            messageIDs[message.data.channel]!.remove(at: channelIdx)
          } else {
            return
          }
        } else {
          messagesList[message.data.channel]![messageId] = message
        }
      }

      // update UI, update display content

      if !messageUpdateSent {
        messageTimetoken = messageId
        messageUpdateSent = true

        // tag::MSG-6.2[]
        pubnub.publish()
          // tag::ignore[]
          .channel(expectedChannel)
          /**
           // end::ignore[]
          .channel("room-1")
          // tag::ignore[]
           */
          // end::ignore[]
          .message([
            // tag::ignore[]
            "timetoken": messageTimetoken,
            /**
            // end::ignore[]
            timetoken: '15343325214676133', // original message timetoken
            // tag::ignore[]
             */
            // end::ignore[]
            "senderId": "user123",
            "text": "Fixed. I had a typo earlier..."
          ])
          .performWithCompletion({ status in
            // handle status, response
            // tag::ignore[]

            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
            // end::ignore[]
          })
        // end::MSG-6.2[]
      } else {
        let storedMessage = messagesList[message.data.channel]![messageId]
        XCTAssertNotNil(storedMessage)
        if let messageBody = storedMessage?.data.message as? [String: Any] {
          XCTAssertTrue(messageBody["timetoken"] as? String == messageTimetoken)
          XCTAssertTrue(messageBody["text"] as? String == expectedText)
          XCTAssertTrue(messageIDs[message.data.channel]!.contains(messageId))
        } else {
          XCTAssert(false, "Unable to check stored message body")
        }

        messageExpectation.fulfill()
      }
    }

    pubnub.subscribe()
      .channels([expectedChannel])
      .perform()

    registerStatusHandler(pubnub, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::MSG-6.1[]
        pubnub.publish()
          .message([
            "senderId": "user123",
            "title": "Hello, hoomans!"
            ])
          // tag::ignore[]
          .channel(expectedChannel)
          /**
          // end::ignore[]
          .channel("room-1")
          // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ status in
            // handle status, response
            // tag::ignore[]

            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
            // end::ignore[]
          })
        // end::MSG-6.1[]
      }
    })

    registerMessageHandler(pubnub, handler: { message in
      handleMessage(message)
    })

    wait(for: [messageExpectation], timeout: 60)
  }

  /**
   * Sending announcements to all users.
   */
  func testSendingAnnouncementsToAllUsers() {
    let messageExpectation = expectation(description: "Waiting for published message.")
    let expectedChannel = UUID().uuidString
    let pubnub: PubNub! = pubNubClient
    let expectedSenderID = "user123"

    observerPubNubClient.subscribe()
      .channels([expectedChannel])
      .perform()

    registerStatusHandler(observerPubNubClient, handler: { status in
      if status.operation == .subscribeOperation {
        // tag::MSG-7[]
        pubnub.publish()
          .message([
            "senderId": "user123",
            "text": "Hello, this is an announcement"
          ])
          // tag::ignore[]
          .channel(expectedChannel)
          /**
           // end::ignore[]
          .channel("room-1")
           // tag::ignore[]
           */
          // end::ignore[]
          .performWithCompletion({ status in
            // handle status, response
            // tag::ignore[]

            XCTAssertFalse(status.isError)
            XCTAssertNotNil(status.data.timetoken)
            // end::ignore[]
          })
        // end::MSG-7[]
      }
    })

    registerMessageHandler(observerPubNubClient, handler: { message in
      XCTAssertTrue(message.data.channel == expectedChannel)

      if let messageBody = message.data.message as? [String: Any] {
        XCTAssertTrue(messageBody["senderId"] as? String == expectedSenderID)
      } else {
        XCTAssert(false, "Unable to check message 'result'")
      }

      messageExpectation.fulfill()
    })

    wait(for: [messageExpectation], timeout: 60)
  }
}
