# chat-examples-swift

[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

Source files for Swift based chat example apps and document code samples live here.

## Requirements

* iOS 9.0+
* Xcode 10.2+
* Swift 5.0+

## Prerequisites

**Cocoapods** is required to install the PubNub SDK, and other dependencies

* Follow this [guide](https://guides.cocoapods.org/using/getting-started.html) if you have any questions getting started.
* After installing, inside the root project folder run:

  ```$ pod install```

[**Xcode 10.2**](https://developer.apple.com/xcode/) or higher is required

**Sign Up for a PubNub Account** to use PubNub's Data Stream Network. If you don't already have an account, you can create one for free [here](https://dashboard.pubnub.com/).

1. Login to your PubNub Account
2. Select Your Project > Your Key. Click on Key Info and copy your `Publish Key` and `Subscribe Key`. You'll need these keys later to include in your project.
3. Enable the following add-on features on your key from the Key Info page: Presence, Storage & Playback, Stream Controller.

![PubNub Admin Dashboard](https://i.ibb.co/YBJdHNp/2.png "PubNub Admin Dashboard")

## Building the project

1. Set the follow ENV variables inside your terminal config (i.e. .bash_profile) file
```bash
export ANIMALFORESTCHAT_PUB_KEY="<Enter Your PubNub Publish Key Here>"
export ANIMALFORESTCHAT_SUB_KEY="<Enter Your PubNub Subscribe Key Here>"
```

1. Open the workspace by running: `$ open chat-examples-swift.xcworkspace`
1. Inside Xcode `Run` the `AnimalForestChat` scheme
