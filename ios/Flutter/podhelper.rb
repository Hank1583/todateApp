#!/usr/bin/env ruby
require 'json'

def flutter_root
  gen = File.expand_path(File.join('..','Flutter','Generated.xcconfig'), __dir__)
  raise "#{gen} missing. Run `flutter pub get` first." unless File.exist?(gen)
  File.foreach(gen) { |l| m = l.match(/FLUTTER_ROOT\=(.*)/); return m[1].strip if m }
  raise "FLUTTER_ROOT not found in #{gen}"
end

def flutter_additional_ios_build_settings(installer)
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

def flutter_install_ios_plugin_pods
  # 專案根的 .flutter-plugins-dependencies
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  ios_plugins = JSON.parse(File.read(plugins_json)).dig("plugins","ios") || []
  ios_plugins.each do |p|
    plugin_name = p["name"]
    plugin_path = File.expand_path(p["path"], File.expand_path('../..', __dir__))

    # A. podspec 在套件根目錄？
    root_podspec = File.join(plugin_path, "#{plugin_name}.podspec")
    # B. 或在 ios 子目錄？
    ios_dir      = File.join(plugin_path, 'ios')
    ios_podspec  = File.join(ios_dir, "#{plugin_name}.podspec")

    if File.exist?(root_podspec)
      pod plugin_name, :path => plugin_path
    elsif File.exist?(ios_podspec)
      pod plugin_name, :path => ios_dir
    else
      raise "No podspec for #{plugin_name} under #{plugin_path} (tried root & ios/)."
    end
  end
end

def flutter_install_all_ios_pods(_ = nil)
  flutter_install_ios_plugin_pods
end
