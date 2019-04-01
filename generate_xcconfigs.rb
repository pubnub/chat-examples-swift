require 'fileutils'

def generate_xcconfigs()
  # Get project directory. Used when running from inside Xcode
  curr_dir = File.expand_path File.dirname(__FILE__)

  # Path to the stored examples and the git ignored supporting files
  examples_dir = "#{curr_dir}/Examples/ResourceCenterDemo/BuildConfig"
  supporting_files_dir = "#{curr_dir}/Examples/ResourceCenterDemo/Supporting Files"

  # Lowercase name of the xcode configurations
  configurations = ["debug", "release"]

  # Name of the target that is having keys generated
  target_name = "RCDemo"

  return_bool = true

  for config in configurations
    if !File.file?("#{supporting_files_dir}/#{target_name}.#{config}.xcconfig")
      # Copy over file
      FileUtils.cp("#{examples_dir}/#{target_name}.#{config}.example.xcconfig",
        "#{supporting_files_dir}/#{target_name}.#{config}.xcconfig")

      # Attempt to replace empty string with stored ENV vars
      # ex. RCDEMO_DEBUG_PUB_KEY or RCDEMO_PUB_KEY
      pub_key = ENV["#{target_name.upcase}_#{config.upcase}_PUB_KEY"] ||= ENV["#{target_name.upcase}_PUB_KEY"]
      sub_key = ENV["#{target_name.upcase}_#{config.upcase}_SUB_KEY"] ||= ENV["#{target_name.upcase}_SUB_KEY"]

      # Read example config file
      text = File.read("#{supporting_files_dir}/#{target_name}.#{config}.xcconfig")

      # Attempt to replace the PubNub keys inside the file
      new_contents = text.gsub(/^(#{target_name.upcase}_PUBLISH_KEY=)(.*)$/, "#{target_name.upcase}_PUBLISH_KEY=\"#{pub_key}\"")
      new_contents = new_contents.gsub(/^(#{target_name.upcase}_SUBSCRIBE_KEY=)(.*)$/, "#{target_name.upcase}_SUBSCRIBE_KEY=\"#{sub_key}\"")

      # Write changes to new file in the supporting files dir
      File.open("#{supporting_files_dir}/#{target_name}.#{config}.xcconfig", "w") {|file| file.puts new_contents }
    end

    return_bool = return_bool && File.file?("#{supporting_files_dir}/#{target_name}.#{config}.xcconfig")
  end

  return return_bool
end

generate_xcconfigs()
