# chat-examples-swift

[![Build Status](https://travis-ci.com/pubnub/chat-examples-swift.svg?token=ey6rVJnpqsBKpxXy2fYF&branch=master)](https://travis-ci.com/pubnub/chat-examples-swift)

Source files for Swift based chat example apps and document code samples live here.

## Requirements

* [Xcode version 10.2 and above](https://developer.apple.com/xcode/)
* Swift version 5.0 and above
* iOS version 9.0 and above

## Prerequisites

[**Cocoapods**](https://guides.cocoapods.org/using/getting-started.html) manages library dependencies for your Xcode projects. You can install it by running:

```
$ sudo gem install cocoapods
```

Add PubNub to your project by specifying it in your `Podfile`:

```
platform :ios, '9.0'
target 'AnimalForestChat' do
  use_frameworks!
  pod 'PubNub'
end
```

After installing, run the following command inside the root project folder:
```
$ pod install
```

**Sign Up for a PubNub Account**
If you don't already have an account, you can create one for free [here](https://dashboard.pubnub.com/).

* Login to your PubNub Account
* Select Your Project > Your Key. Click on Key Info and copy your `Publish Key` and `Subscribe Key`
* Enable the following add-on features on your key: Presence, Storage & Playback, Stream Controller

## Building the project

1. Clone the repo. You can use GitHub's [Clone in Xcode](https://github.blog/2017-06-05-clone-in-xcode/) feature.
2. Set the follow ENV variables inside your terminal config (i.e. .bash_profile) file

```bash
export ANIMALFORESTCHAT_PUB_KEY="<Enter Your PubNub Publish Key Here>"
export ANIMALFORESTCHAT_SUB_KEY="<Enter Your PubNub Subscribe Key Here>"
```

3. Open the workspace by running: `$ open chat-examples-swift.xcworkspace`
4. Inside Xcode `Run` the `AnimalForestChat` scheme

## Further Information

For more information about this project, or how to create your own chat app using PubNub, please check out our [tutorial](https://www.pubnub.com/chat-resource-center/docs/tutorials/tutorial-swift/).
