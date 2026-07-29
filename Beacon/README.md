# Beacon

Tiny demo of Walnut’s **native** story — one `UISwitch`, four names.

```sh
walnut simulator  # from Beacon/
```

## The shapes

| Shape | Code | Source |
| --- | --- | --- |
| **Curated** | `switch [ … ]` | Short stdlib helper |
| **Platform** | `uiSwitch [ … ]` | Generated SDK list (`platform-natives.json`) |
| **App alias** | `switch2 [ … ]` | Project `natives.json` |
| **Escape** | `native "UISwitch" [ … ]` | Raw class string |

Also uses platform `uiActivityIndicatorView` for the spinner.

## Regenerating the platform list

```sh
python3 scripts/generate-platform-natives.py
```

Scrapes **allowlisted** iOS SDK framework TBDs (UIKit, HealthKit, PassKit, CloudKit, MapKit, …), not every class in the SDK. Full notes: [docs/uikit-interop.md](https://docs.walnutlang.com/).

**Important:** `native` / these helpers only *host* `UIView` subclasses. Swift-only types like `LanguageModelSession` appear in the map so the name typechecks, but they need **ports/effects** to do real work — they are not views.

## App `natives.json`

```json
{ "aliases": { "switch2": "UISwitch" } }
```

Swift `typealias` alone does not register with `NSClassFromString`.
