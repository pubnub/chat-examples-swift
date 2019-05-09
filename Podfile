# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

# Implicit abstract_target dependencies
pod 'PubNub', '~> 4.0'
pod 'SwiftLint', '~> 0.30'

target 'AnimalForestChat' do
  pod 'MessageKit', :git => 'https://github.com/MessageKit/MessageKit.git', :branch => '3.0.0-swift5'
end

target 'AnimalForestChatTests' do
  pod 'MessageKit', :git => 'https://github.com/MessageKit/MessageKit.git', :branch => '3.0.0-swift5'
end

target 'Snippets' do
end

pre_install do |installer|
  puts "Creating .xcconfigs"
  # Execute script to export PubNub pub/sub keys inside .xcconfig(s)
  system("ruby generate_xcconfigs.rb \\
    -n AnimalForestChat \\
    -t Examples/AnimalForestChat/BuildConfig \\
    -e \"Examples/AnimalForestChat/Supporting Files\"")
end
