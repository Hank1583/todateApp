#!/usr/bin/env ruby
require 'json'
require 'pathname'

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
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  data = JSON.parse(File.read(plugins_json))
  ios_plugins = (data.dig('plugins','ios') || [])
  project_root = File.expand_path('../..', __dir__)

  ios_plugins.each do |p|
    name = p['name']
    raw_path = p['path'] # 可能是絕對或相對
    plugin_path =
      if Pathname.new(raw_path).absolute?
        raw_path
      else
        File.expand_path(raw_path, project_root)
      end

    root_spec = File.join(plugin_path, "#{name}.podspec")
    ios_dir   = File.join(plugin_path, 'ios')
    ios_spec  = File.join(ios_dir, "#{name}.podspec")

    if File.exist?(ios_spec)
      puts "→ Using iOS podspec for #{name}: #{ios_dir}"
      pod name, :path => ios_dir
    elsif File.exist?(root_spec)
      puts "→ Using root podspec for #{name}: #{plugin_path}"
      pod name, :path => plugin_path
    else
      raise "No podspec for #{name}. Tried:\n - #{ios_spec}\n - #{root_spec}"
    end
  end
end

def flutter_install_all_ios_pods(_ = nil)
  flutter_install_ios_plugin_pods
end
