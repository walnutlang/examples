import UIKit
import WalnutUIKit

// The entire native surface of a Walnut app. Everything else — model,
// update, view — lives in ../src/*.walnut and is compiled to Main.o,
// then rendered through UIKit.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        WalnutPorts.registerSub("deepLink")
        WalnutPorts.registerCmd("share") { payload, reply in
            Self.presentShare(payload: payload, reply: reply)
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        // Dovetail is a light cream palette — lock appearance so system Dark Mode
        // cannot paint adaptive UIKit backgrounds black under fixed ink colors.
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = WalnutApp.bootstrapOrShowError()
        window.makeKeyAndVisible()
        self.window = window

        if let url = launchOptions?[.url] as? URL {
            WalnutPorts.send("deepLink", payload: url.absoluteString)
        }
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        WalnutPorts.send("deepLink", payload: url.absoluteString)
        return true
    }

    private static func presentShare(payload: String, reply: @escaping (String) -> Void) {
        let present = {
            guard let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)?
                .rootViewController
            else {
                reply("no-window")
                return
            }
            var host = root
            while let presented = host.presentedViewController {
                host = presented
            }
            let sheet = UIActivityViewController(activityItems: [payload], applicationActivities: nil)
            sheet.completionWithItemsHandler = { _, _, _, _ in
                reply("shared")
            }
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = host.view
                pop.sourceRect = CGRect(x: host.view.bounds.midX, y: host.view.bounds.midY, width: 1, height: 1)
                pop.permittedArrowDirections = []
            }
            host.present(sheet, animated: true)
        }
        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }
}
