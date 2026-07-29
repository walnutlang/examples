import UIKit
import WalnutUIKit

// The entire native surface of a Walnut app. Everything else — model,
// update, view — lives in ../src/*.walnut and runs on the Walnut
// interpreter, rendered through UIKit.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = WalnutApp.bootstrapOrShowError()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
