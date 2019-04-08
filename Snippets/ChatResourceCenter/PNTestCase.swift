/**
 * Base clase for snippets integration tests.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
import XCTest
import PubNub

class PNTestCase: XCTestCase, PNObjectEventListener {
  fileprivate var presenceHandlers: [String: (_ status: PNPresenceEventResult) -> Void] = [:]
  fileprivate var messageHandlers: [String: (_ status: PNMessageResult) -> Void] = [:]
  fileprivate var statusHandlers: [String: (_ status: PNStatus) -> Void] = [:]
  var observerPubNubClient: PubNub!
  let subscribeKey = "demo-36"
  let publishKey = "demo-36"
  var pubNubClient: PubNub!

  override func setUp() {
    super.setUp()

    let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
    configuration.stripMobilePayload = false

    configuration.uuid = UUID().uuidString
    observerPubNubClient = PubNub.clientWithConfiguration(configuration, callbackQueue: DispatchQueue.global())
    observerPubNubClient.addListener(self)

    configuration.uuid = UUID().uuidString
    pubNubClient = PubNub.clientWithConfiguration(configuration, callbackQueue: DispatchQueue.global())
    pubNubClient.addListener(self)
  }

  override func tearDown() {
    presenceHandlers.removeAll()
    messageHandlers.removeAll()
    statusHandlers.removeAll()

    observerPubNubClient.removeListener(self)
    observerPubNubClient.unsubscribeFromAll()
    pubNubClient.removeListener(self)
    pubNubClient.unsubscribeFromAll()
  }

  public func publishMessage(_ client: PubNub, channel: String,
                             completion: @escaping (_ timetoken: NSNumber) -> Void) {
    let message = [
      "senderId": "user123",
      "text": "\(Date().timeIntervalSince1970) Hello, hoomans!"
    ]

    client.publish()
      .message(message)
      .channel(channel)
      .performWithCompletion({ status in
        XCTAssertFalse(status.isError)
        XCTAssertNotNil(status.data.timetoken)
        completion(status.data.timetoken)
    })
  }

  public func publishMultipleMessages(_ client: PubNub, channel: String, count: Int,
                                      completion: @escaping (_ timetokens: [NSNumber]) -> Void) {
    var timetokens: [NSNumber] = []
    var publishedMessages = 0

    var handleMessagePublish: ((_ timetoken: NSNumber) -> Void)!
    handleMessagePublish = { timetoken in
      timetokens.append(timetoken)
      publishedMessages += 1

      if publishedMessages < count {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.publishMessage(client, channel: channel, completion: handleMessagePublish)
        }
      } else {
        completion(timetokens)
      }
    }

    publishMessage(client, channel: channel, completion: handleMessagePublish)
  }

  public func registerStatusHandler(_ client: PubNub,
                                    handler: @escaping (_ status: PNStatus) -> Void) {
    statusHandlers[client.uuid()] = handler
  }

  public func registerPresenceHandler(_ client: PubNub,
                                      handler: @escaping (_ status: PNPresenceEventResult) -> Void) {
    presenceHandlers[client.uuid()] = handler
  }

  public func registerMessageHandler(_ client: PubNub,
                                     handler: @escaping (_ status: PNMessageResult) -> Void) {
    messageHandlers[client.uuid()] = handler
  }

  func client(_ client: PubNub, didReceive status: PNStatus) {
    if let handler = statusHandlers[client.uuid()] {
      handler(status)
    }
  }

  func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
    if let handler = presenceHandlers[client.uuid()] {
      handler(event)
    }
  }

  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    if let handler = messageHandlers[client.uuid()] {
      handler(message)
    }
  }
}
