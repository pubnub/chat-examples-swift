# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

# Implicit abstract_target dependencies
pod 'PubNub', '~> 4.0'
pod 'SwiftLint', '~> 0.30'

target 'RCDemo' do

  pod 'MessageKit', :git => 'https://github.com/MessageKit/MessageKit.git', :branch => '3.0.0-swift5'

  # Pods for chat-example
  target 'RCDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'Snippets' do
end
