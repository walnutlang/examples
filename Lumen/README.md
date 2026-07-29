# Lumen

Metabolic health showcase for Walnut — **Today**, **Progress**, **Learn**, **Circle**, **Plan**.

Educational demo. **Not a medical device.** Not medical advice.

## What’s in the demo

- **Today** — orient + act: greeting, one next action, daily goals, notes, capture FAB, coach
- **Progress** — understand over time: kept days, 7-day trends, weekly check-in
- **Learn** — condition-filtered lessons + four coaches with live (demo) chat
- **Circle** — Joined vs Discover forums, compose via + FAB, emoji reactions
- **Plan** — conditions, HealthKit, Fitbit demo toggle
- **App Intents** — “Log my day in Lumen” saves a **Note**; on-device triage (`lumen.triage`). Also “Log glucose in Lumen”.

Seeded profile starts **past onboarding** with all conditions on. Uninstall (or bump `lumen.profile.v3`) to reset prefs.

## Design

See [DESIGN.md](DESIGN.md). Soft sage paper + deep teal. Light-locked.

## Run

```bash
swift build -c release
./.build/release/walnut check Examples/Lumen
./.build/release/walnut test Examples/Lumen
walnut simulator  # from Lumen/
./.build/release/walnut simulator Examples/Lumen
```

## Notes + triage

Siri / URL capture appends a **pending Note** only. Host port `lumen.triage` labels kind / coach / commitment.

Simulator smoke (app already running):

```bash
xcrun simctl openurl booted 'walnut-lumen://tellLumen?text=I%20went%20for%20a%20walk'
xcrun simctl openurl booted 'walnut-lumen://tellLumen?text=I%20just%20had%20Greek%20yogurt'
```

Details: [`docs/lumen.md`](https://docs.walnutlang.com/).

## Ports

| Port | Role |
|------|------|
| `healthkit.authorize` / `healthkit.query` | HealthKit (stub in Simulator) |
| `fitbit.sync` | Demo vitals by default |
| `fitbit.oauth.start` / `fitbit.disconnect` | Connect / wipe |
| `lumen.triage` | On-device note routing |
| `appIntent` (sub) | Siri / URL capture inbound |

## Architecture

Todo-shaped TEA: nested `Msg`, `dispatch`, Core Data `lumen.profile.v3`, host ports outside WalnutRT.
