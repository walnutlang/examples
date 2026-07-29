import UIKit

// MARK: - Native aliases (documentation / Swift-side intent)
//
// A Swift `typealias` does **not** register a name with `NSClassFromString`.
// Walnut’s source of truth for renames is `natives.json` at the project root:
//
//   { "aliases": { "switch2": "UISwitch" } }
//
// That makes `switch2 […]` a real Walnut helper that expands to
// `native "UISwitch" […]` at compile time — same multi-shape story as
// curated `switch` and the raw `native` escape hatch.

typealias UISwitch2 = UISwitch
