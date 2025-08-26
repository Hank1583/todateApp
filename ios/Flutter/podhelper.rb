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
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  ios_plugins = JSON.parse(File.read(plugins_json)).dig("plugins","ios") || []
  project_root = File.expand_path('../..', __dir__)

  ios_plugins.each do |p|
    name = p["name"]
    # `path` 會是套件根（例如 ~/.pub-cache/.../webview_flutter_wkwebview-3.22.0）
    plugin_root = File.expand_path(p["path"], project_root)
    root_spec   = File.join(plugin_root, "#{name}.podspec")
    ios_dir     = File.join(plugin_root, 'ios')
    ios_spec    = File.join(ios_dir, "#{name}.podspec")

    if File.exist?(ios_spec)
      puts "→ Using iOS podspec for #{name}: #{ios_dir}"
      pod name, :path => ios_dir
    elsif File.exist?(root_spec)
      puts "→ Using root podspec for #{name}: #{plugin_root}"
      pod name, :path => plugin_root
    else
      # 印出更清楚的錯誤，方便你我對照
      raise "No podspec for #{name}. Tried:\n - #{ios_spec}\n - #{root_spec}"
    end
  end
end

def flutter_install_all_ios_pods(_ = nil)
  flutter_install_ios_plugin_pods
end
