import AppIntents
import WalnutUIKit

/// Siri / Shortcuts → Lumen via `Port.sub "appIntent"` (queued until TEA is ready).
enum LumenIntentBridge {
    static let portName = "appIntent"

    static func register() {
        WalnutPorts.registerSub(portName)
        LumenAppShortcuts.updateAppShortcutParameters()
    }

    static func send(action: String, fields: [String: String]) {
        var lines = ["action=\(action)"]
        for (key, value) in fields.sorted(by: { $0.key < $1.key }) {
            let cleaned = value
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { continue }
            lines.append("\(key)=\(cleaned)")
        }
        WalnutPorts.send(portName, payload: lines.joined(separator: "\n"))
    }

    /// `walnut-lumen://tellLumen?text=...` (or legacy `update=` / had+activity).
    static func handleOpenURL(_ url: URL) {
        guard url.scheme == "walnut-lumen" else { return }
        let action = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !action.isEmpty else { return }
        var fields: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .forEach { item in
                if let value = item.value {
                    fields[item.name] = value
                }
            }
        if action == "tellLumen" {
            if fields["text"] == nil {
                if let update = fields["update"] {
                    fields["text"] = update
                    fields.removeValue(forKey: "update")
                } else if let had = fields["had"] {
                    let activity = fields["activity"] ?? ""
                    fields["text"] = activity.isEmpty ? had : "\(had) and \(activity)"
                }
            }
        }
        send(action: action, fields: fields)
    }
}


/// Primary capture → pending Note; on-device triage routes later.
struct TellLumenIntent: AppIntent {
    static var title: LocalizedStringResource = "Log my day"
    static var description = IntentDescription(
        "Save a note to Lumen. On-device triage sorts food, activity, and coaches when you open the app."
    )
    static var openAppWhenRun = true

    @Parameter(
        title: "Update",
        requestValueDialog: IntentDialog(
            "What happened? Say something like: I just had Greek yogurt and did a ten minute walk."
        )
    )
    var update: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log my day in Lumen: \(\.$update)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        LumenIntentBridge.send(
            action: "tellLumen",
            fields: ["text": update]
        )
        return .result(dialog: "Got it — note saved in Lumen.")
    }
}


struct LogGlucoseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log glucose"
    static var description = IntentDescription("Save a manual glucose reading in Lumen.")
    static var openAppWhenRun = true

    @Parameter(title: "mg/dL", requestValueDialog: "What is the reading?")
    var mgdl: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$mgdl) mg/dL in Lumen")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        LumenIntentBridge.send(
            action: "logGlucose",
            fields: ["mgdl": String(mgdl)]
        )
        return .result(dialog: "Saved \(mgdl) mg/dL.")
    }
}


struct LumenAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TellLumenIntent(),
            phrases: [
                "Log my day in \(.applicationName)",
                "Check in with \(.applicationName)",
                "Add an update in \(.applicationName)",
                "Capture my day in \(.applicationName)",
            ],
            shortTitle: "Log my day",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: LogGlucoseIntent(),
            phrases: [
                "Log glucose in \(.applicationName)",
            ],
            shortTitle: "Log glucose",
            systemImageName: "drop"
        )
    }
}
