# App Store store kit

Batteries for shipping this Walnut app:

| Path | Role |
|------|------|
| `screenshots/raw/<slot>/` | Simulator captures from `walnut screenshots capture` |
| `screenshots/framed/<slot>/` | Optional marketing frames (status bar polish, device chrome) |
| `metadata/` | Draft App Store copy |

## Git

- **Commit** `metadata/*.txt` and this README.
- **Do not commit** screenshot images — `**/store/screenshots/**/*.{png,jpg,…}` is gitignored
  in walnutlang. Regenerate with `walnut screenshots capture`.
- **Publish:** `walnut store upload` pushes metadata + local PNGs to App Store Connect.

Commands: `walnut screenshots --help` · `walnut store upload` · Docs: `docs/screenshots.md`.
