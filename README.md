# chat-examples-swift

[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

Source files for Swift based chat example apps and document code samples live here.

## Requirements

* iOS 8.0+
* Xcode 10.2+
* Swift 5.0+

## Prerequisites

**Cocoapods** is required to install the PubNub SDK, and other dependencies

* Follow this [guide](https://guides.cocoapods.org/using/getting-started.html) if you have any questions getting started.
* After installing, inside the root project folder run:

  ```$ pod install```

[**Xcode 10.2**](https://developer.apple.com/xcode/) or higher is required to build Examples and Samples.

## Building the project

1. Open the workspace by running:

    ```$ open chat-examples-swift.xcworkspace```

1. Use Xcode's Scheme Selector to select and run the following:

| Name | App Name | Source Code Group | Description |
| -- | -- |-- | -- |
| ChatResourceDemo | RC Demo | Examples -> ResourceChatDemo | Example describing best practices for creating a chat app using the PubNub SDK. |
| Snippets | N/A | Snippets -> ChatResourceCenter | Code samples that are found inside the [Chat Resource Center](https://pubnub.github.io/chat-resource-center/). <br><br>**NOTE: You must execute this Scheme as a Test (CMD+U)** |

## Contributing

### Making a Pull Request

#### Before you Start

Before you work on a big new feature, get in touch to make sure that your work is inline with the direction of the project and get input on your architecture.

Please ensure that any work is initially branched off `master`, and rebased often.

#### Coding Standards

These projects follows [Google's Swift Style Guide](https://google.github.io/swift/). Please review your own code for adherence to the standard.

#### Pull Request Reviews

All pull requests, even by members who have repository write access need to be reviewed and marked as "LGTM" before they will be merged.
