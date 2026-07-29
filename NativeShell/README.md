# NativeShell

Demo of **UIKit-by-class-name** — strip the curated view sugar and host real controls:

```walnut
native "UISwitch" [ propBool "on" model.lit, onNativeBool "valueChanged" SetLit ]
native "UISlider" [ propFloat "value" model.volume, onNativeFloat "valueChanged" "value" SetVolume ]
```

Not a textbook `tabBar` / `sheet` shell (that’s Todo / Ledger). Not the four naming layers for one switch (that’s [Beacon](../Beacon)). This app is a **control catalog**: switch, slider, stepper, progress, text field, button, spinner, date picker — all via `native "UI…"`.

Layout still uses `scroll` / `column` / `row` / `el` / `text` spacers. Everything interactive is a UIKit class.

```bash
walnut simulator  # from NativeShell/
./.build/release/walnut test Examples/NativeShell
```

## Files

```
src/
  Main.walnut
  Types.walnut
  Update.walnut
  View.walnut     # native "UI…" catalog
```

See [docs/uikit-interop.md](https://docs.walnutlang.com/).
