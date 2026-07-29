import UIKit
import WalnutUIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        EmbedPort.register()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = WalnutApp.bootstrapOrShowError()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
