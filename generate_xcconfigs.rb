#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

def generate_xcconfigs(options)
  # Get project directory. Used when running from inside Xcode
  curr_dir = File.expand_path File.dirname(__FILE__)

  # Path to the stored examples and the git ignored supporting files
  template_filename = "target.template.xcconfig"

  target_name = options[:target_name]
  template_file = "#{curr_dir}/#{options[:template_path]}/#{template_filename}"
  export_dir = "#{curr_dir}/#{options[:export_path]}"

  target_replace = "<TARGET>"
  target_env_replace = "<TARGET_ENV>"
  config_replace = "<Config>"
  pub_key_replace = "<PUB_KEY>"
  sub_key_replace = "<SUB_KEY>"

  # Lowercase name of the xcode configurations
  configurations = ["debug", "release"]

  return_bool = true

  if !File.file?(template_file)
    puts "Could not find .xcconfig template at #{template_file}"
    return false
  end

  if !Dir.exists?(export_dir)
    FileUtils.mkdir_p(export_dir)
    return false unless Dir.exists?(export_dir)
  end

  for config in configurations
    config_file = "#{export_dir}/#{target_name}.#{config}.xcconfig"
    if !File.file?(config_file)
      # Copy over file
      FileUtils.cp(template_file, config_file)

      # Read keys from ENV Variables
      # ex. <TARGET>_<CONFIG>_PUB_KEY or <TARGET>_SUB_KEY
      pub_key = ENV["#{target_name.upcase}_#{config.upcase}_PUB_KEY"] ||= ENV["#{target_name.upcase}_PUB_KEY"]
      sub_key = ENV["#{target_name.upcase}_#{config.upcase}_SUB_KEY"] ||= ENV["#{target_name.upcase}_SUB_KEY"]

      # Read example config file
      text = File.read("#{export_dir}/#{target_name}.#{config}.xcconfig")

      # Insert Target Name
      text = text.gsub(target_replace, target_name)
      text = text.gsub(target_env_replace, target_name.upcase)

      # Insert Config Name
      text = text.gsub(config_replace, config)

      # Insert Keys
      text = text.gsub(pub_key_replace, pub_key)
      text = text.gsub(sub_key_replace, sub_key)

      # Write changes to new file in the supporting files dir
      File.open(config_file, "w") {|file| file.puts text }
    else
      puts "Config for #{config} already exists"
    end

    return_bool = return_bool && File.file?(config_file)
  end

  return return_bool
end

options = {}
OptionParser.new do |opt|
  opt.on('-n TARGETNAME', '--target TARGETNAME') { |target|
    options[:target_name] = target
    #generate_xcconfigs(options[:target_name])
  }
  opt.on('-t PATHNAME', '--template_path PATHNAME') { |path|
    options[:template_path] = path
  }
  opt.on('-e PATHNAME', '--export_path PATHNAME') { |path|
    options[:export_path] = path
  }
end.parse!

generate_xcconfigs(options)
