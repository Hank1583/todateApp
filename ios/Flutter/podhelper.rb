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

# 內部：安裝 plugins（搜尋 ios/、darwin/、root；優先 :podspec）
def flutter_install_ios_plugin_pods
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  data = JSON.parse(File.read(plugins_json))
  ios_plugins  = (data.dig('plugins', 'ios') || [])
  project_root = File.expand_path('../..', __dir__)

  ios_plugins.each do |p|
    name = p['name']
    raw_path = p['path']
    plugin_path = Pathname.new(raw_path).absolute? ? raw_path : File.expand_path(raw_path, project_root)

    ios_dir    = File.join(plugin_path, 'ios')
    darwin_dir = File.join(plugin_path, 'darwin')

    candidates = [
      File.join(ios_dir,    "#{name}.podspec"),
      File.join(ios_dir,    "#{name}.podspec.json"),
      File.join(darwin_dir, "#{name}.podspec"),
      File.join(darwin_dir, "#{name}.podspec.json"),
      File.join(plugin_path, "#{name}.podspec"),
      File.join(plugin_path, "#{name}.podspec.json")
    ]

    spec_file = candidates.find { |f| File.exist?(f) }
    spec_file ||= Dir.glob(File.join(plugin_path, '**', "#{name}.podspec{,.json}")).first

    if spec_file
      puts "→ Installing #{name} via :podspec #{spec_file}"
      pod name, :podspec => spec_file
    elsif Dir.exist?(ios_dir)
      puts "→ Installing #{name} via :path #{ios_dir}"
      pod name, :path => ios_dir
    elsif Dir.exist?(darwin_dir)
      puts "→ Installing #{name} via :path #{darwin_dir}"
      pod name, :path => darwin_dir
    else
      raise "No podspec for #{name} in #{plugin_path} (checked ios/, darwin/, root)"
    end
  end
end

# 外部入口：與官方模板相容
def flutter_install_all_ios_pods(_app_path = nil)
  flutter_install_ios_plugin_pods
end
