# VendorDemo — committed lock + vendored packages

Showcase for [docs/packages.md](https://docs.walnutlang.com/): the app **ships**
`walnut.lock` and `vendor/walnut/` so `walnut install` / `check` work **without**
the registry on the network.

| Dep | Origin in lock | On disk |
|-----|----------------|---------|
| Greeter 0.1.0 | registry `https://packages.walnutlang.com` | `vendor/walnut/Greeter/` |
| LocalTip | path `packages/LocalTip` | `vendor/walnut/LocalTip/` (+ source under `packages/`) |

```bash
swift build -c release
# No registry required — uses committed vendor + lock:
./.build/release/walnut install Examples/VendorDemo
./.build/release/walnut check Examples/VendorDemo
walnut simulator  # from VendorDemo/
```

To refresh Greeter from a running registry: `walnut update Examples/VendorDemo Greeter`
(then re-commit lock + vendor).
