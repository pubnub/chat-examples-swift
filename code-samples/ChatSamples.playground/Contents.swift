// Code Samples //////////////////////////////////////////////////////////////////////////////////////
/*:
 * Callout(NOTE):
 This is just a work-in-progress example of a Playground, and does not represent the final code sample product!
 */
/*:
 **Include PubNub SDK**
 */
import PubNub

class PubNubClient: NSObject {
  let client: PubNub

  init(with config: PNConfiguration) {
    // Initialize and configure PubNub client instance
    self.client = PubNub.clientWithConfiguration(config)

    super.init()

    self.client.addListener(self)
    startIndefiniteExecution()
  }

  deinit {
    self.client.removeListener(self)
    finishExecution()
  }
}

extension PubNubClient: PNObjectEventListener {
  // Handle new message from one of channels on which client has been subscribed.
  func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
    print("Received Message \(message)")
  }

  func client(_ client: PubNub, didReceive status: PNStatus) {
    print("Status Change Received: \(status)")
  }

  func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
    print("Presence Event Received: \(event.data)")
  }
}

/*:
 **Instantiate a new Pubnub instance**
 */
let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
let pubnub = PubNubClient(with: configuration)

// Wrapping functionality
func executeCodeSamples() {
/*:
 **Joining a Chat**
 */
  print("Example: Joining a Chat")
  pubnub.client.subscribeToChannels(["room-1"], withPresence: false)

/*:
 **Joining Multiple Chatrooms**
 */
  print("Example: Joining Multiple Chatrooms")
  pubnub.client.subscribeToChannels(["room-1", "room-2", "room-3"], withPresence: false)

  // Sleep to ensure that the subscription occurs before publishing,
  // so we can receive the message we're about to send
  sleep(1)

/*:
 **Sending a Message**
 */
  print("Example: Sending a Message")
  pubnub.client.publish("Hello Channel", toChannel: "room-1") { (status) in
    print("I published with: \(status)")
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

// Uncomment the next line to execute code inside playground
executeCodeSamples()
