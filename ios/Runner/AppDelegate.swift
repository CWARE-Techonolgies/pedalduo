import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        setupMethodChannel()
        clearApplicationBadge()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupMethodChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        let badgeChannel = FlutterMethodChannel(
            name: "flutter.native/badge",
            binaryMessenger: controller.binaryMessenger
        )

        badgeChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "clearBadge":
                self?.clearApplicationBadge()
                result("Badge cleared")
            case "setBadge":
                if let args = call.arguments as? [String: Any],
                   let count = args["count"] as? Int {
                    self?.setApplicationBadge(count: count)
                    result("Badge set to \(count)")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid badge count", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func clearApplicationBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    private func setApplicationBadge(count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        clearApplicationBadge()
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        super.applicationWillEnterForeground(application)
        clearApplicationBadge()
    }
}