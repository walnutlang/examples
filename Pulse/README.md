# Pulse

Minimal TEA demo: `Time.every` clock + `Http.get`.

```sh
walnut simulator  # from Pulse/
```

- `Time.every 1000 Tick` — Posix ms once per second
- `Time.now Tick` on init
- Button → `Http.get "https://httpbin.org/get" GotBody`
