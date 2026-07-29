# Counter

A [Walnut](https://github.com/walnutlang/examples) app.

## Project layout

- `src/` — your Walnut sources (`Main.walnut` holds `main`)
- `ios/` — the thin native shell (generated Xcode project)
- `walnut.json` — project manifest

## Everyday commands

```sh
walnut check          # parse + validate the sources
walnut build          # generate the Xcode project and build for the simulator
walnut simulator      # build, install, and launch in an iOS Simulator
```

Or open the generated `ios/Counter.xcodeproj` in Xcode and hit Run.
