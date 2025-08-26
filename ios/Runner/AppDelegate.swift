import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // （必要）先註冊所有 Flutter 原生插件
    GeneratedPluginRegistrant.register(with: self)

    // 其他原生 SDK 初始化可放在這裡（若有）

    // 保持在 super 之後或之前皆可；Flutter 預設在之後回傳
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
