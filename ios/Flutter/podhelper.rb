#!/usr/bin/env ruby
require 'json'

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  return [] unless File.exist?(file_abs_path)
  pods_ary = []
  skip_line_start_symbols = ["#", "/"]
  File.foreach(file_abs_path) do |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
    plugin = line.split(separator)
    if plugin.length == 2
      pods_ary.push({ name: plugin[0].strip, path: plugin[1].strip })
    end
  end
  pods_ary
end

def flutter_root
  generated = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __dir__)
  raise "#{generated} must exist. Run `flutter pub get` first" unless File.exist?(generated)
  File.foreach(generated) do |line|
    m = line.match(/FLUTTER_ROOT\=(.*)/)
    return m[1].strip if m
  end
  raise "FLUTTER_ROOT not found in #{generated}"
end

def flutter_additional_ios_build_settings(installer)
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

def flutter_install_ios_plugin_pods(_ios_application_path = nil)
  # 專案根目錄的 .flutter-plugins-dependencies
  plugins_file = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_file}. Run `flutter pub get` first." unless File.exist?(plugins_file)

  plugin_pods = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
  plugin_pods.each do |plugin|
    pod plugin["name"], path: File.expand_path(plugin["path"], File.expand_path('../..', __dir__))
  end
end

def flutter_install_all_ios_pods(_ios_application_path = nil)
  flutter_install_ios_plugin_pods
end
