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

    spec_dir = Dir.exist?(ios_dir) ? ios_dir : plugin_path
    puts "→ Installing #{name} from #{spec_dir}"
    pod name, :path => spec_dir
  end
end
