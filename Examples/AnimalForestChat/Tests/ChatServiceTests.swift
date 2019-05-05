//
//  ChatServiceTests.swift
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

  let testMessageId = "MessageID"
  let testMessageText = "TestText"

  let endDate = Date().timeIntervalAsImpreciseToken
  let startDate = Date.distantPast.timeIntervalAsImpreciseToken

  var mock: MockChatProvider!
  var service: ChatRoomService!

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mock = MockChatProvider()
    mock.senderIdValue = testUser.uuid

    service = ChatRoomService(for: testRoom, with: mock)
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    mock = nil
    service = nil
  }

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

  // tag::TEST-1[]
  func testPublish_Successful() {
    let publishExpectation = XCTestExpectation(description: "testPublish_Successful body")
    let listenerExpectation = XCTestExpectation(description: "testPublish_Successful listener")

    let testMessage = Message(uuid: UUID().uuidString,
                          text: testMessageText,
                          sentAt: Date().timeIntervalAsImpreciseToken,
                          senderId: testUser.uuid,
                          roomId: testRoom.uuid)
    mock.messageEvent = MockMessageEvent(roomId: testMessage.roomId, message: testMessage)

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          XCTAssertTrue(messages.first?.text == testMessage.text)
          // Test granular changes
          XCTAssertTrue(messages.count == 1)
          // Test overall changes
          XCTAssertTrue(self.service.messages.count == 1)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Received error instead of message event")
        }
      default:
        XCTFail("Received event other than message")
      }
    }

    service.send(testMessage.text) { (result) in
      switch result {
      case .success(let message):
        XCTAssertNotNil(message)
        publishExpectation.fulfill()
      case .failure:
        XCTFail("Publish Response Contained Error")
      }
    }

    wait(for: [publishExpectation, listenerExpectation], timeout: maxWait)
  }
  // end::TEST-1[]

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
      }
      publishExpectation.fulfill()
    }

    wait(for: [publishExpectation], timeout: maxWait)
  }

  func testChatRoomHistory_Success() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomHistory_Success listener")
    listenerExpectation.expectedFulfillmentCount = 2

    let testMessage = Message(uuid: testMessageId, text: testMessageText,
                              sentAt: endDate, senderId: testUser.uuid,
                              roomId: testRoom.uuid)

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
            XCTAssertTrue(messages.contains(testMessage))
            // Test overall changes
            XCTAssertTrue(self.service.messages.count == 1)
            XCTAssertTrue(self.service.messages.contains(testMessage))

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
          } else {
            // Test pulling additional messages
            XCTAssertTrue(messages.count == 2)
            // Test overall changes
            XCTAssertTrue(self.service.messages.count == 3,
                          "Message count should be 3 was \(self.service.messages.count)")
            for message in messages {
              XCTAssertTrue(self.service.messages.contains(message))
            }
          }
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        XCTFail("Received event other than messages")
      }

      listenerExpectation.fulfill()
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
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        XCTFail("Received event other than messages")
      }
      listenerExpectation.fulfill()
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
        }
      default:
        XCTFail("Received event other than messages")
      }
      listenerExpectation.fulfill()
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
        case .failure:
          XCTFail("Users Event Failed")
        }
      default:
        XCTFail("Received event other than users")
      }
      listenerExpectation.fulfill()
    }

    service.fetchCurrentUsers()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testChatRoomOccupancy_EmptyResponse() {
    let listenerExpectation = XCTestExpectation(description: "testChatRoomOccupancy_Failure listener")

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
          }
        case .failure:
          XCTFail("Users Event Failed")
        }
      default:
        XCTFail("Received event other than users")
      }
      listenerExpectation.fulfill()
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
        }
      default:
        XCTFail("Received event other than users")
      }
      listenerExpectation.fulfill()
    }

    service.fetchCurrentUsers()

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveMessage_Success() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

    service.listener = { [unowned self] (event) in
      switch event {
      case .messages(let messageEvent):
        switch messageEvent {
        case .success(let messages):
          // Test granular changes
          XCTAssertTrue(messages.count == 1)
          // Test overall changes
          XCTAssertTrue(self.service.messages.count == 1)
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        XCTFail("Received event other than messages")
      }
      listenerExpectation.fulfill()
    }

    let testMessage = Message(uuid: testMessageId, text: testMessageText,
                              sentAt: endDate, senderId: testUser.uuid, roomId: testRoom.uuid)

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: testMessage)

    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveMessage_NilBody() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")
    listenerExpectation.isInverted = true

    service.listener = { (_) in
      XCTFail("No Event Should Be Received")
      listenerExpectation.fulfill()
    }

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: nil)

    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxInvertedWait)
  }

  func testDidReceiveMessage_RepeatMessage() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

    let testMessage = Message(uuid: testMessageId, text: testMessageText,
                              sentAt: endDate, senderId: testUser.uuid, roomId: testRoom.uuid)

    service.listener = { (event) in
      switch event {
      case .messages(let event):
        switch event {
        case .success(let messages):
          XCTAssert(self.service.messages.count == 1,
                    "Expected count of 1 got \(self.service.messages.count)")
          XCTAssert(messages[0] == testMessage)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Messages Event Failed")
        }
      default:
        XCTFail("Received event other than messages")
      }
    }

    let messageEvent = MockMessageEvent(roomId: testRoom.uuid, message: testMessage)

    mock.eventEmitter.listener?(.message(messageEvent))
    mock.eventEmitter.listener?(.message(messageEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_Connected() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

    let statusEvent = MockStatusEvent(status: "Connected", request: "Subscription")

    service.listener = { (event) in
      switch event {
      case .status(let event):
        switch event {
        case .success(let status):
          XCTAssert(status == .connected)
          XCTAssert(self.service.state == .connected)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Status Event Failed")
        }
      default:
        XCTFail("Received event other than status")
      }
    }

    service.start()
    mock.eventEmitter.listener?(.status(.success(statusEvent)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_NotConnected() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

    let statusEvent = MockStatusEvent(status: "Expected Disconnect", request: "Subscription")

    service.listener = { (event) in
      switch event {
      case .status(let event):
        switch event {
        case .success(let status):
          XCTAssert(status == .notConnected)
          XCTAssert(self.service.state == .notConnected)
          listenerExpectation.fulfill()
        case .failure:
          XCTFail("Status Event Failed")
        }
      default:
        XCTFail("Received event other than status")
      }
    }

    mock.eventEmitter.listener?(.status(.success(statusEvent)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceiveStatus_Other() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")
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
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

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
        XCTFail("Received event other than status")
      }
    }

    mock.eventEmitter.listener?(.status(.failure(error)))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testDidReceivePresence_Success() {
    let listenerExpectation = XCTestExpectation(description: "testDidReceiveMessage")

    let leftUserID = "leftUser"
    let timedOutUserID = "timedOut"

    let testJoined = [testUser.uuid, leftUserID, timedOutUserID]
    let testTimedOut = [timedOutUserID]
    let testLeft = [leftUserID]
    let occupancy = testJoined.count - (testTimedOut.count + testLeft.count)

    service.listener = { (event) in
      switch event {
      case .messages:
        XCTFail("Publish Response Contained Error")
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
      case .status:
        XCTFail("Publish Response Contained Error")
      }
    }

    let presenceEvent = MockPresenceEvent(roomId: testRoom.uuid, occupancy: occupancy,
                                          joined: testJoined,
                                          timedout: testTimedOut,
                                          left: testLeft)

    mock.eventEmitter.listener?(.presence(presenceEvent))

    wait(for: [listenerExpectation], timeout: maxWait)
  }

  func testAddMessage_NilSelf() {
    let listenerExpectation = XCTestExpectation(description: "testAddMessage_Failure_NilSelf listener")
    listenerExpectation.isInverted = true

    let testMessage = Message(uuid: UUID().uuidString,
                              text: testMessageText,
                              sentAt: Date().timeIntervalAsImpreciseToken,
                              senderId: testUser.uuid,
                              roomId: testRoom.uuid)
    let messageEvent = MockMessageEvent(roomId: testMessage.roomId, message: testMessage)

    service.listener = { (event) in
      XCTFail("Received event other than message")
    }

    mock.eventEmitter.listener?(.message(messageEvent))
    service = nil

    wait(for: [listenerExpectation], timeout: maxInvertedWait)
  }
} // swiftlint:disable:this file_length
