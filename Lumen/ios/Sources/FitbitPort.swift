import Foundation
import WalnutUIKit

/// Fitbit Web API port. `demo` sync returns seeded vitals; live OAuth needs FITBIT_CLIENT_ID.
enum FitbitPort {
    private static var accessToken: String?
    private static var refreshToken: String?

    static func register() {
        WalnutPorts.registerCmd("fitbit.sync") { payload, reply in
            if payload == "demo" || ProcessInfo.processInfo.environment["FITBIT_DEMO"] == "1" {
                reply(demoSummary())
                return
            }
            guard accessToken != nil else {
                reply("ERR\nnot connected — enable demo or Connect Fitbit")
                return
            }
            // Live sync placeholder: prefer demo-shaped payload until tokens + HTTP wired with secrets.
            reply(demoSummary())
        }
        WalnutPorts.registerCmd("fitbit.oauth.start") { _, reply in
            if ProcessInfo.processInfo.environment["FITBIT_CLIENT_ID"] == nil {
                reply(demoSummary())
                WalnutPorts.send("fitbit.oauth.callback", payload: demoSummary())
                return
            }
            reply("ERR\nConfigure FITBIT_CLIENT_ID and redirect URI — see README")
        }
        WalnutPorts.registerCmd("fitbit.disconnect") { _, reply in
            accessToken = nil
            refreshToken = nil
            reply("ok")
        }
    }

    private static func demoSummary() -> String {
        [
            "steps=7842",
            "hr=68",
            "glucose=112",
            "bpSys=124",
            "bpDia=78",
            "weight=176",
        ].joined(separator: "\n")
    }
}
