# PubNub Swift Chat

[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

This repository contains sample code for the a chat application build using the Swift SDK.

## Repository structure

| Directory  | Description |
|:----------:| ----------- |
| `Examples/AnimalForestChat` | Source files for the Animal Forest Chat application.|

# Animal Forest Chat Application

## Prerequisites

* [Xcode version 10.2+](https://developer.apple.com/xcode/)
* Swift version 5.0+
* iOS version 9.0+

### Using your PubNub keys

Set the following environment variables inside your shell configuration file (such as `~/.bash_profile`). You will need to create a new PubNub Chat app from the [PubNub Dashboard](https://dashboard.pubnub.com/) and enter your app keys.

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

For more information about this project, or how to create your own chat app using PubNub, please check out the [PubNub Chat Documentation](https://www.pubnub.com/docs/chat/quickstart).
