import UIKit
import WalnutUIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        HealthKitPort.register()
        FitbitPort.register()
        TriagePort.register()
        LumenIntentBridge.register()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light
        window.backgroundColor = UIColor(red: 247 / 255, green: 245 / 255, blue: 240 / 255, alpha: 1)
        window.rootViewController = WalnutApp.bootstrapOrShowError()
        window.makeKeyAndVisible()
        self.window = window

        if let url = launchOptions?[.url] as? URL {
            LumenIntentBridge.handleOpenURL(url)
        }
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        LumenIntentBridge.handleOpenURL(url)
        return true
    }
}
