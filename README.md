# PubNub Swift Chat

[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

This repository contains sample code from the [Chat Resource Center](https://www.pubnub.com/developers/chat-resource-center/).

## Repository structure

| Directory  | Description |
|:----------:| ----------- |
| `Examples` | Sample applications which show how to implement chat functionality using the PubNub SDK. |
| `Examples/AnimalForestChat` | Source files for the Animal Forest Chat application. The complete tutorial can be found [here](https://www.pubnub.com/developers/chat-resource-center/docs/getting-started/swift/)|
| `Snippets` | Verified and tested code snippets used in documentation.<br>Snippets from `chat-resource-center/` are used in the [Chat Resource Center](https://www.pubnub.com/developers/chat-resource-center/). |

# Animal Forest Chat Application

## Prerequisites

* [Xcode version 10.2 or higher](https://developer.apple.com/xcode/)
* Swift version 5.0 or higher
* iOS version 9.0 or higher

### Sign Up for a PubNub Account

If you don't already have an account, you can create one for free [here](https://dashboard.pubnub.com/).

1. Sign in to your PubNub [Admin Dashboard](https://dashboard.pubnub.com/), click Create New App, and give your app a name.

1. Select your new app, then click its keyset. Copy the Publish and Subscribe keys. You'll need these keys to include in this project.

1. Scroll down on the Key Options page and enable the [Presence](https://www.pubnub.com/products/presence/) and [Storage & Playback](https://www.pubnub.com/products/realtime-messaging/) add-on features.

1. Click Save Changes, and you're done!

### Using your PubNub keys

Set the following environment variables inside your shell configuration file (such as `~/.bash_profile`):

```bash
export ANIMALFORESTCHAT_PUB_KEY="<Enter Your PubNub Publish Key Here>"
export ANIMALFORESTCHAT_SUB_KEY="<Enter Your PubNub Subscribe Key Here>"
```

### CocoaPods

[CocoaPods](https://guides.cocoapods.org/using/getting-started.html) manages library dependencies for your Xcode projects. You can install it by running the following command:

```
sudo gem install cocoapods
```

## Building the project

1. Clone the repository. You can use GitHub's [Clone in Xcode](https://github.blog/2017-06-05-clone-in-xcode/) feature.

1. Run the following commands from a Terminal window in the root project folder:

    ```bash
    pod repo update
    pod install
    ```

1. When `pod install` has completed, run the following command in your Terminal window:

    ```
    open chat-examples-swift.xcworkspace
    ```

1. Use the Run command on the `AnimalForestChat` scheme to build and execute the application on your physical device or the iOS simulator.

## Further Information

For more information about this project, or how to create your own chat app using PubNub, please check out our [tutorial](https://www.pubnub.com/developers/chat-resource-center/docs/getting-started/swift/).
