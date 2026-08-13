import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let appGroup = "group.com.sasogu.faselunar"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.sasogu.faselunar/widget",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "updateMoonWidget":
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      case "setSelectedDate":
        guard let args = call.arguments as? [String: Any],
              let ts = args["date"] as? NSNumber
        else {
          result(FlutterError(code: "bad_args", message: "date missing", details: nil))
          return
        }
        UserDefaults(suiteName: self?.appGroup ?? "group.com.sasogu.faselunar")?
          .set(ts.doubleValue, forKey: "selectedDate")
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      case "clearSelectedDate":
        UserDefaults(suiteName: self?.appGroup ?? "group.com.sasogu.faselunar")?
          .removeObject(forKey: "selectedDate")
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
