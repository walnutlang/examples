# Walnut examples

Public demos for [Walnut](https://walnutlang.com) — a TEA language for native iOS.

## Install Walnut

```sh
brew install walnutlang/tap/walnut
walnut version
walnut login   # free packages.walnutlang.com account
```

Docs: [docs.walnutlang.com](https://docs.walnutlang.com/)

## Point each app at the Homebrew runtime

`ios/project.yml` uses the placeholder `__WALNUT_RUNTIME__` for the Walnut SPM package path. Fix once after clone:

```sh
./scripts/fix-runtime.sh
```

Or manually:

```sh
RUNTIME="$(brew --prefix walnut)/share/walnut/runtime"
# or: RUNTIME="$WALNUT_HOME"
find . -name project.yml -print0 | xargs -0 sed -i '' "s|__WALNUT_RUNTIME__|$RUNTIME|g"
```

## Run an example

```sh
cd Counter
walnut check
walnut test      # when tests/ exists
walnut simulator
```

## Examples

| Directory | Notes |
|-----------|-------|
| `Beacon/` | See `Beacon/README.md` |
| `Counter/` | See `Counter/README.md` |
| `EmbedPlay/` | See `EmbedPlay/README.md` |
| `Ledger/` | See `Ledger/README.md` |
| `Lumen/` | See `Lumen/README.md` |
| `NativeShell/` | See `NativeShell/README.md` |
| `PkgDemo/` | See `PkgDemo/README.md` |
| `PortsDemo/` | See `PortsDemo/README.md` |
| `Pulse/` | See `Pulse/README.md` |
| `Surfaces/` | See `Surfaces/README.md` |
| `Todo/` | See `Todo/README.md` |
| `VendorDemo/` | See `VendorDemo/README.md` |

## License

Example source in this repository is provided for learning and demos. Walnut the language/toolchain has its own license terms — see [walnutlang.com](https://walnutlang.com).
