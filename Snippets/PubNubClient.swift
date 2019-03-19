//
//  PubNubClient.swift
//  Snippets
//
//  Created by Craig Lane on 3/14/19.
//

import PubNub

class PubNubClient: NSObject {
    let client: PubNub

  init(with config: PNConfiguration) {
    // Initialize and configure PubNub client instance
    self.client = PubNub.clientWithConfiguration(config)

    super.init()

    self.client.addListener(self)
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
