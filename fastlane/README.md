fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios lint_and_test
```
fastlane ios lint_and_test
```
This lane is used to lint and test all schemes in the workspace
### ios pull_request
```
fastlane ios pull_request
```

### ios nightly
```
fastlane ios nightly
```
This lane is ran as part of a nightly CI cron process
### ios weekly
```
fastlane ios weekly
```
This lane is ran as part of a weekly CI cron process

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
