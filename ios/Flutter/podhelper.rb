require 'json'
require 'pathname'

def flutter_install_ios_plugin_pods
  plugins_json = File.expand_path(File.join(__dir__, '../../.flutter-plugins-dependencies'))
  raise "Missing #{plugins_json}. Run `flutter pub get`." unless File.exist?(plugins_json)

  data = JSON.parse(File.read(plugins_json))
  ios_plugins = (data.dig('plugins','ios') || [])
  project_root = File.expand_path('../..', __dir__)

  ios_plugins.each do |p|
    name = p['name']
    raw_path = p['path']
    plugin_path = Pathname.new(raw_path).absolute? ? raw_path : File.expand_path(raw_path, project_root)
    ios_dir = File.join(plugin_path, 'ios')

    ios_podspec      = File.join(ios_dir,   "#{name}.podspec")
    ios_podspec_json = File.join(ios_dir,   "#{name}.podspec.json")
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
      # 後備：讓 CocoaPods 自己在 ios/ 目錄找
      puts "→ Installing #{name} via :path #{ios_dir}"
      pod name, :path => ios_dir
    else
      # 最後退路：root 目錄
      puts "→ Installing #{name} via :path #{plugin_path}"
      pod name, :path => plugin_path
    end
  end
end

def flutter_install_all_ios_pods(_app_path = nil)
  flutter_install_ios_plugin_pods
end
