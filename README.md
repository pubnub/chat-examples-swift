# chat-examples-swift
[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

Source files for Swift based chat example apps and document code samples live here.

## Requirements
* iOS 8.0+
* Xcode 10.1+
* Swift 4.2+

## Building

1. Prerequisites:
  - Cocoapods is required to install the PubNub SDK, and other dependencies
    - You can follow this [guide](https://guides.cocoapods.org/using/getting-started.html) if you have any questions getting started.
    - After installing, inside the root project folder run: ```$ pod install```
  - Building Examples and Samples requires [Xcode 10.x](https://developer.apple.com/xcode/).

2. Open the ```chat-examples-swift.xcworkspace``` workspace
  - Run: ```$ open chat-examples-swift.xcworkspace```

3. Using the Scheme Selector inside of Xcode you can select and run the following:

Name | App Name | Source Code Group | Description
--|---
ChatResourceDemo | RC Demo | Examples -> ResourceChatDemo | Example describing best practices for creating a chat app using the PubNub SDK.
Snippets | N/A | Snippets -> ChatResourceCenter | Code samples that are found inside the [Chat Resource Center](https://pubnub.github.io/chat-resource-center/). <br><br>```NOTE: You must execute this Scheme as a Test (CMD+U)```
