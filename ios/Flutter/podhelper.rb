#!/usr/bin/env ruby
require 'json'
require 'pathname'

def flutter_additional_ios_build_settings(installer)
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

def flutter_install_ios_plugin_pods
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  data = JSON.parse(File.read(plugins_json))
  ios_plugins = (data.dig('plugins', 'ios') || [])
  project_root = File.expand_path('../..', __dir__)

  ios_plugins.each do |p|
    name = p['name']
    raw_path = p['path']
    plugin_path = Pathname.new(raw_path).absolute? ? raw_path : File.expand_path(raw_path, project_root)
    ios_dir = File.join(plugin_path, 'ios')

    ios_podspec       = File.join(ios_dir,   "#{name}.podspec")
    ios_podspec_json  = File.join(ios_dir,   "#{name}.podspec.json")
    root_podspec      = File.join(plugin_path, "#{name}.podspec")
    root_podspec_json = File.join(plugin_path, "#{name}.podspec.json")

    if File.exist?(ios_podspec)
      puts "→ Installing #{name} via :podspec #{ios_podspec}"
      pod name, :podspec => ios_podspec
    elsif File.exist?(ios_podspec_json)
      puts "→ Installing #{name} via :podspec #{ios_podspec_json}"
      pod name, :podspec => ios_podspec_json
    elsif File.exist?(root_podspec)
      puts "→ Installing #{name} via :podspec #{root_podspec}"
      pod name, :podspec => root_podspec
    elsif File.exist?(root_podspec_json)
      puts "→ Installing #{name} via :podspec #{root_podspec_json}"
      pod name, :podspec => root_podspec_json
    elsif Dir.exist?(ios_dir)
      puts "→ Installing #{name} via :path #{ios_dir}"
      pod name, :path => ios_dir
    else
      raise "No podspec for #{name} in #{plugin_path} (checked ios/ and root)"
    end
  end
end

# 與官方模板相容的入口：允許一個可忽略參數
def flutter_install_all_ios_pods(_app_path = nil)
  flutter_install_ios_plugin_pods
end
