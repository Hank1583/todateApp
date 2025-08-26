#!/usr/bin/env ruby
require 'json'

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  if !File.exists? file_abs_path
    return [];
  end
  pods_ary = []
  skip_line_start_symbols = ["#", "/"]
  File.foreach(file_abs_path) do |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
    plugin = line.split(pattern=separator)
    if plugin.length == 2
      podname = plugin[0].strip()
      path = plugin[1].strip()
      pods_ary.push({:name => podname, :path => path});
    else
      puts "Invalid plugin specification: #{line}"
    end
  end
  return pods_ary
end

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __dir__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}"
end

def flutter_ios_engine_dir
  File.expand_path('Flutter/engine', flutter_root)
end

def flutter_additional_ios_build_settings(target)
  # Workaround https://github.com/flutter/flutter/issues/38059
  target.build_configurations.each do |config|
    config.build_settings['ENABLE_BITCODE'] = 'NO'
  end
end

def flutter_install_ios_plugin_pods(ios_application_path = nil)
  ios_application_path ||= File.dirname(__dir__)
  # defined in Generated.xcconfig
  generated_xcode_build_settings_path = File.expand_path(File.join('..','Flutter','Generated.xcconfig'), __dir__)
  plugins_file = File.join(ios_application_path, '.flutter-plugins-dependencies')
  plugin_pods = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
  plugin_pods.each do |plugin|
    pod plugin["name"], :path => File.expand_path(plugin["path"], ios_application_path)
  end
end

def flutter_install_all_ios_pods(ios_application_path = nil)
  flutter_install_ios_plugin_pods(ios_application_path)
end
