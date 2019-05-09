//
//  ChatRoomServiceTests.swift
//  AnimalForestChatTests
//
//  Created by Craig Lane on 4/25/19.
//

import XCTest

@testable import AnimalForestChat

class ChatServiceTests: XCTestCase { // swiftlint:disable:this type_body_length

  let maxWait = 10.0
  let maxInvertedWait =  0.01

  let testUser = User(uuid: "TestUser", firstName: nil,
                      lastName: nil, designation: nil, avatarName: nil)
  let testRoom = ChatRoom(uuid: "TestChatRoom", name: "TestChatRoom", description: nil, avatarName: nil)
  var testMessage: Message!

  let testMessageId = "MessageID"
  let testMessageText = "TestText"

  let endDate = Date().timeIntervalAsImpreciseToken
  let startDate = Date.distantPast.timeIntervalAsImpreciseToken

  var mock: MockChatProvider!
  var service: ChatRoomService!

// tag::TEST-1[]
// ChatRoomServiceTests.swift
  override func setUp() {

    mock = MockChatProvider()
    mock.senderIdValue = testUser.uuid

    testMessage = Message(uuid: testMessageId, text: testMessageText,
                          sentAt: endDate, senderId: testUser.uuid,
                          roomId: testRoom.uuid)

    service = ChatRoomService(for: testRoom, with: mock)
  }

  override func tearDown() {
    mock.eventEmitter.listener = nil
    mock = nil
    service = nil
  }
// end::TEST-1[]
  func testChatRoomJoinChatRoom() {
    service.start()
    XCTAssertTrue(mock.subscribedRoomId == testRoom.uuid)

    // Ensure that we don't subscribe if we're already subscribed
    service.start()
    XCTAssertTrue(mock.subscribedRoomId == testRoom.uuid)
  }

  func testChatRoomLeaveChatRoom() {
    service.start()
    XCTAssertTrue(mock.subscribedRoomId == testRoom.uuid)

    service.stop()
    XCTAssertNil(mock.subscribedRoomId)
  }

  func testSender_Exists() {
    mock.senderIdValue = User.defaultValue.uuid

    guard let sender = service.sender else {
      XCTFail("User was expected to exist")
      return
    }

    XCTAssert(sender.uuid == mock.senderID,
              "SenderID expected to be \(mock.senderIdValue), but was \(sender.uuid)")
  }

// tag::TEST-2[]
// ChatRoomServiceTests.swift
  func testPublish_Successful() {
    let publishExpectation = XCTestExpectation(description: "testPublish_Successful body")
    let listenerExpectation = XCTestExpectation(description: "testPublish_Successful listener")

    mock.messageEvent = MockMessageEvent(roomId: self.testMessage.roomId, message: testMessage)

    self.service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          // Ensure that the message sent is being received
          XCTAssertTrue(messages.first == self.testMessage)
          // Test granular changes
          XCTAssertTrue(messages.count == 1)
          // Test overall changes
          XCTAssertTrue(self.service.messages.count == 1)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Received error instead of message event")
        }
      default:
        break
      }
    }

    self.service.send(self.testMessage.text) { (result) in
      switch result {
      case .success(let message):
        XCTAssertNotNil(message)
        publishExpectation.fulfill()
      case .failure:
        XCTFail("Publish Response Contained Error")
      }
    }

    wait(for: [publishExpectation, listenerExpectation], timeout: self.maxWait)
  }
// end::TEST-2[]

  func testPublish_Failure() {
    let publishExpectation = XCTestExpectation(description: "testPublish_Failure body")
    mock.publishError = NSError(domain: "", code: 400, userInfo: nil)

    service.listener = { (event) in
      XCTFail("Received event other than message error")
    }

    service.send(testMessageText) { (result) in
      switch result {
      case .success:
        XCTFail("Publish Response Did Not Contain An Error")
      case .failure(let error):
        XCTAssertNotNil(error)
        publishExpectation.fulfill()
      }
    }

    wait(for: [publishExpectation], timeout: maxWait)
  }

  func testChatRoomHistory_Success() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomHistory_Success listener")
    listenerExpectation.expectedFulfillmentCount = 2

    mock.roomHistoryResponse = MockRoomHistoryResponse(start: startDate,
                                                       end: endDate,
                                                       messages: [testMessage])

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          // Test granular changes
          if messages.count == 1 {
            XCTAssertTrue(messages.contains(self.testMessage))
            // Test overall changes
            XCTAssertTrue(self.service.messages.count == 1)
            XCTAssertTrue(self.service.messages.contains(self.testMessage))

            let messageOne = Message(uuid: "messageOne", text: "messageOne",
                                     sentAt: Date().timeIntervalAsImpreciseToken,
                                     senderId: self.testUser.uuid, roomId: self.testRoom.uuid)
            let messageTwo = Message(uuid: "messageTwo", text: "messageTwo",
                                     sentAt: Date().timeIntervalAsImpreciseToken,
                                     senderId: self.testUser.uuid, roomId: self.testRoom.uuid)

            self.mock.roomHistoryResponse = MockRoomHistoryResponse(start: self.endDate,
                                                                    end: Date().timeIntervalAsImpreciseToken,
                                                                    messages: [messageOne, messageTwo])

            self.service.fetchMessageHistory()
            listenerExpectation.fulfill()
          } else {
            // Test pulling additional messages
            XCTAssertTrue(messages.count == 2)
            // Test overall changes
            XCTAssertTrue(self.service.messages.count == 3,
                          "Message count should be 3 was \(self.service.messages.count)")
            for message in messages {
              XCTAssertTrue(self.service.messages.contains(message))
            }
            listenerExpectation.fulfill()
          }
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        break
      }
    }

    service.fetchMessageHistory()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomHistory_EmptyResponse() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomHistory_EmptyResponse listener")

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          // Test granular changes
          XCTAssertTrue(messages.count == 0)
          // Test overall changes
          XCTAssertTrue(self.service.messages.count == 0)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        break
      }
    }

    service.fetchMessageHistory()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomHistory_Failure() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomHistory_Failure listener")

    mock.roomHistoryError = NSError(domain: "", code: 0, userInfo: nil)

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success:
          XCTFail("Messages Event Succeeded")
        case .failure(let error):
          XCTAssertNotNil(error)
          // Test overall changes
          XCTAssert(self.service.messages.count == 0)
          listenerExpectation.fulfill()
        }
      default:
        break
      }
    }

    service.fetchMessageHistory()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomOccupancy_Success() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomOccupancy_Success listener")

    let occupancy = 1

    mock.roomPresenceResponse = MockRoomPresenceResponse(occupancy: occupancy, uuids: [testUser.uuid])

    service.listener = { [unowned self] (event) in
      switch event {
      case .presence(let event):
        switch event {
        case .success(let joined, let left):
          // Test granular changes
          XCTAssert(joined.count == occupancy)
          XCTAssert(joined.contains(self.testUser.uuid))
          XCTAssert(left.count == 0)
          // Test overall changes
          XCTAssert(self.service.occupancy == occupancy)
          XCTAssertTrue(self.service.occupantUUIDs.contains(self.testUser.uuid))
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Users Event Failed")
        }
      default:
        break
      }
    }

    service.fetchCurrentUsers()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomOccupancy_EmptyResponse() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomOccupancy_EmptyResponse listener")

    service.listener = { [unowned self] (event) in
      switch event {
      case .presence(let result):
        switch result {
        case .success(let event):
          switch event {
          case (let joined, let left):
            // Test granular changes
            XCTAssert(joined.count == 0)
            XCTAssert(left.count == 0)
            // Test overall changes
            XCTAssert(self.service.occupancy == 0)
            XCTAssertTrue(self.service.occupantUUIDs.isEmpty)
            listenerExpectation.fulfill()
          }
        case .failure:
          XCTFail("Users Event Failed")
        }
      default:
        break
      }
    }

    service.fetchCurrentUsers()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomOccupancy_Failure() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomOccupancy_Failure listener")

    mock.roomPresenceError = NSError(domain: "", code: 0, userInfo: nil)

    service.listener = { [unowned self] (event) in
      switch event {
      case .presence(let result):
        switch result {
        case .success:
          XCTFail("Users Event Succeeded")
        case .failure(let error):
          XCTAssertNotNil(error)
          // Test overall changes
          XCTAssert(self.service.occupancy == 0)
          XCTAssertTrue(self.service.occupantUUIDs.isEmpty)
          listenerExpectation.fulfill()
        }
      default:
        break
      }
    }

    service.fetchCurrentUsers()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveMessage_Success() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage_Success listener")

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          // Test granular changes
          XCTAssertTrue(messages.count == 1)
          // Test overall changes
          XCTAssertTrue(self.service.messages.count == 1)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        break
      }
    }

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: testMessage)

    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveMessage_NilBody() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage_NilBody listener")
    listenerExpectation.isInverted = true

    service.listener = { (event) in
      switch event {
      case .messages:
        XCTFail("No Event Should Be Received")
        listenerExpectation.fulfill()
      default:
        break
      }
    }

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: nil)

    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxInvertedWait)
  }

  func testDidReceiveMessage_RepeatMessage() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage_RepeatMessage listener")

    service.listener = { (event) in
      switch event {
      case .messages(let event):
        switch event {
        case .success(let messages):
          XCTAssert(self.service.messages.count == 1,
                    "Expected count of 1 got \(self.service.messages.count)")
          XCTAssert(messages[0] == self.testMessage)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        break
      }
    }

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: testMessage)

    mock.eventEmitter.listener?(.message(messageEvent))
    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_Connected() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveStatus_Connected listener")

    let statusEvent = MockStatusEvent(status: "Connected", request: "Subscription")

    service.listener = { (event) in
      switch event {
      case .status(let event):
        switch event {
        case .success(let status):
          XCTAssert(status == .connected)
          XCTAssert(self.service.state == .connected)

          XCTAssertTrue(self.service.occupantUUIDs.contains(self.testUser.uuid))
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Status Event Failed")
        }
      default:
        break
      }
    }

    service.start()
    mock.eventEmitter.listener?(.status(.success(statusEvent)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_NotConnected() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveStatus_NotConnected listener")

    let statusEvent = MockStatusEvent(status: "Expected Disconnect", request: "Subscription")

    service.listener = { (event) in
      switch event {
      case .status(let event):
        switch event {
        case .success(let status):
          XCTAssert(status == .notConnected)
          XCTAssert(self.service.state == .notConnected)

          XCTAssertTrue(self.service.occupantUUIDs.isEmpty)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Status Event Failed")
        }
      default:
        break
      }
    }

    mock.eventEmitter.listener?(.status(.success(statusEvent)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_Other() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveStatus_Other listener")
    listenerExpectation.isInverted = true

    let statusEvent = MockStatusEvent(status: "Something", request: "Subscription")

    service.listener = { (_) in
      XCTFail("No Event Should Be Received")
      listenerExpectation.fulfill()
    }

    mock.eventEmitter.listener?(.status(.success(statusEvent)))

    wait(for: [listenerExpectation], timeout: maxInvertedWait)
  }

  func testDidReceiveStatus_Error() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveStatus_Error listener")

    let error = NSError(domain: "", code: 0, userInfo: nil)

    service.listener = { (event) in
      switch event {
      case .status(let event):
        switch event {
        case .success:
          XCTFail("Status Event Did Not Contain An Error")
        case .failure(let error):
          XCTAssertNotNil(error)
          listenerExpectation.fulfill()
        }
      default:
        break
      }
    }

    mock.eventEmitter.listener?(.status(.failure(error)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceivePresence_Success() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceivePresence_Success listener")

    let leftUserID = "leftUser"
    let timedOutUserID = "timedOut"

    let testJoined = [testUser.uuid, leftUserID, timedOutUserID]
    let testTimedOut = [timedOutUserID]
    let testLeft = [leftUserID]
    let occupancy = testJoined.count - (testTimedOut.count + testLeft.count)

    service.listener = { (event) in
      switch event {
      case .presence(let result):
        switch result {
        case .success(let event):
          switch event {
          case (let joined, let left):
            // Test granular changes
            XCTAssert(joined == testJoined,
                      "Joined group return does not equal expected")
            XCTAssert(left.count == testTimedOut.count + testLeft.count,
                      "Left group count returned does not equal expected")
            // Test overall changes
            XCTAssert(self.service.occupancy == occupancy)
            XCTAssertTrue(self.service.occupantUUIDs == [self.testUser.uuid])
          }
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Publish Response Did Not Contain An Error")
        }
      default:
        break
      }
    }

    let presenceEvent = MockPresenceEvent(roomId: testRoom.uuid, occupancy: occupancy,
                                          joined: testJoined,
                                          timedout: testTimedOut,
                                          left: testLeft)

    mock.eventEmitter.listener?(.presence(presenceEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }
} // swiftlint:disable:this file_length
