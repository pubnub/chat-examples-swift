# Contributing to the Swift Chat Examples

Your contributions to this project are very much welcome! Here are a 
few tips to make things work efficiently.

## General information

All contributions — edits _and_ new content — should be in the form of
pull requests. This keeps everyone from stepping on each others' toes,
and allows us all to discuss the change and make suggestions for 
improvement.

When you create your PR, please tag _Craig Lane_ or 
_Serhii Mamontov_ as a reviewer.

> **NOTE** The pull request process makes things efficient, and allows 
the whole team to participate. If a pull request doesn’t work for you,
just email Craig or Serhii and they will create one for you.

## Additional Setup

In order to run the tests, fastlane and an additional set of PubNub keys are required.

To install fastlane:

1. In your terminal, run
    ```bash
    gem install bundler
    ```

1. After the installation has completed,

    ```bash
    bundler install
    ```

1. In XCode, open your `Preferences`, go to `Locations` and ensure that `Xcode 10.2.X` is selected for the Command Line Tools.

To setup your testing PubNub keys:

1. Login to your [admin dashboard](https://admin.pubnub.com) and create a _new_ app.

1. Click the app and create a _second_ keyset named `PAM`.

1. In XCode, create a property list named `keysset` in `Snippets/ChatResourceCenter/Resources/` to hold your keys and add children named `regular` and `pam` with type `dictionary`.

1. For the `PAM` keyset, enable Storage & Playback, Stream Controller, and Access Manager, then save the changes.
   Add `publish`, `subscribe`, and `secret` as children of `pam` with the Publish Key, Subscribe Key, and 
   Secret Key from the admin dashboard for values.

1. For the default `Demo Keyset`, enable Presence, Storage & Playback, and Stream Controller, then save the changes.
   Add `publish`, `subscribe`, and `secret` as children of `pam` with the Publish Key, Subscribe Key, and 
   Secret Key from the admin dashboard for values.

## Coding Standards

The repository is linted during the testing process with fastlane.

Make sure to resolve all serious violations before opening a pull request.

You can use one of the following commands to check your changes for errors with eslint at any time.

```
bundle exec fastlane lint_and_test_examples source_dir:Examples # lint and run tests for the app
bundle exec fastlane lint_and_test_snippets source_dir:Snippets # lint and run tests for the snippets
```

## Making a Pull Request

### Before you Start

Please ensure that any work is initially branched off `master`, and 
rebased often.

### After you're Done

Please, make sure to follow these [commit message guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
when committing changes as part of a pull request. 

If editing the snippets, make sure to [run the tests](#testing-snippets) before committing.

### Content

#### Snippets

Snippets are organized in the form of _integration tests_, where each example 
should be tested to work.  
Snippets are used by the Docusaurus `include` plugin, which will render them 
instead of placeholders. Each `include` directive relies on _tag_ names
which should be placed around snippet code:  

```js
// tag::WRAP-2[]
// ChatProvider.swift
/// Get the message history of a chat room
func history(_ request: ChatHistoryRequest, completion: @escaping  (Result<ChatHistoryResponse?, NSError>) -> Void)
// end::WRAP-2[]
```

If unwanted code or tests become part of the snippet, they can be removed by
enclosing them into a special `ignore` tag:  

```js
// tag::INIT-0[]
// AppDelegate.swift
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
// tag::ignore[]
// Set the Bar Button Text Color
UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.8117647059, green: 0.1294117647, blue: 0.1607843137, alpha: 1)
UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
// end::ignore[]

// Assign default values for initial view controller
if let navController = self.window?.rootViewController as? UINavigationController,
    let chatVC = navController.viewControllers.first as? ChatViewController {

    // Typically there would be user authentication flows prior to displaying
    // the default chat room view, but this app currently uses local values for
    // all users and rooms.
    chatVC.viewModel = ChatViewModel(with: ChatRoomService())
}

return true
}
// end::INIT-0[]
```

#### Testing Snippets

To test and lint the snippets, run

```bash
bundle exec fastlane lint_and_test_snippets source_dir:Snippets
```

When testing locally, tests for push notifications _will_ be skipped so that you do not have to provide push certificates. These tests will run normally on Travis when you make your pull request.

> **Note** There is a known issue where some tests unexpectedly fail after a timeout. When this occurs, re-running the tests should resolve the issue.