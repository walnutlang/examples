# Todo (tabbed)

A multi-module Walnut demo with a **system `tabBar`** and a compositional update router. Uses **`Walnut.element`** with **Core Data** + Notifications — see [docs/effects.md](https://docs.walnutlang.com/).

```
src/
  Main.walnut                 # Walnut.element wiring
  Model/
    Types.walnut              # Tab, BrowseFocus, Item, Model
    Init.walnut
    Query.walnut              # filters + default area/project for new tasks
  Update/
    Msg.walnut                # nested Msg: Auth | Nav | Compose | Tasks | Persist
    App.walnut                # thin dispatcher only
    Auth.walnut
    Nav.walnut
    Compose.walnut
    Tasks.walnut
    Persist.walnut            # Core Data
  Pages/
    Welcome.walnut            # mock auth gate
    Today.walnut
    Detail.walnut
    Calendar.walnut
    Lists.walnut
    Settings.walnut
  View/
    Shell.walnut              # tabBar root; per-tab navStack + fab + sheets
    Chrome.walnut             # headers, FAB, compose, delete
    Task.walnut
    Theme.walnut
```

```bash
walnut simulator  # from Todo/
```

### Architecture

- **Shared domain state** (`items`, `nextId`, prefs) lives on the root `Model`.
- **Pages own views only** (no nested TEA — tag msgs with `nav` / `tasks` / `compose` helpers).
- **`Update.App`** uses `dispatch [ Auth.update, Nav.update, … ]` — the compiler expands that to an exhaustive `case`.
- **UIKit chrome:** `tabBar` is the root; each tab embeds its own `navStack`. Task detail (and Lists browse) push on that tab’s stack.

### Tabs

| Tab | Content |
|---|---|
| Today | Greeting, progress, segments, morning/afternoon/evening |
| Calendar | Upcoming |
| Lists | Named lists + areas |
| Settings | Mock account |

### Also

- Folder open flags + tasks **persisted** via Core Data (`dovetail.*`)  
- FAB `+` floats above the tab bar  
- `Notifications.onReceive` fills the draft (`WalnutNotifications.deliver`)
