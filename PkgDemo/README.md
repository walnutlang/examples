# PkgDemo

Smoke app for [docs/packages.md](https://docs.walnutlang.com/):

| Dep | Strategy |
|-----|----------|
| **Greeter** `0.1.0` | Registry → committed `vendor/walnut/Greeter` |
| **Shout** | In-app path `packages/Shout` (also copied into vendor on install) |

```bash
# Registry on :4001 with greeter published — docs/registry.md
swift build -c release
./.build/release/walnut install Examples/PkgDemo
./.build/release/walnut check Examples/PkgDemo
# Offline: install again uses vendor/ + lock hashes (no registry required)
walnut simulator  # from PkgDemo/
```

Commit **`walnut.lock`** and **`vendor/walnut/`**.
