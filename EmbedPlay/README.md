# EmbedPlay

On-device **text embeddings** toy for Walnut — MLX + [MLXEmbedders](https://github.com/ml-explore/mlx-swift-lm) via a host `Port.cmd`, not inside WalnutRT.

Uses the smallest registered model: **`TaylorAI/bge-micro-v2`** (~17M params). First launch downloads weights from Hugging Face (~70MB).

## Why device only

MLX needs Apple Silicon + Metal. The Simulator is not a useful host for this demo.

```bash
swift build -c release
# once per machine if xcodebuild complains about `metal`:
#   xcodebuild -downloadComponent MetalToolchain
./.build/release/walnut device Examples/EmbedPlay --device f
```

First device build for bundle id `dev.walnut.embedplay` may need Xcode → Settings → Accounts (refresh) or open `ios/EmbedPlay.xcodeproj` once so Automatic signing creates a profile.

## What it does

1. Host loads BGE Micro in the background.
2. Walnut keeps a small **corpus** of phrases + a **query**.
3. `Port.cmd "mlx.rank"` embeds query + corpus and returns cosine ranks.
4. UI shows nearest neighbors as percent bars — poke the query, add your own lines, re-rank.

## Port protocol (line-oriented)

**Request** (`mlx.rank`):

```
query line
---
corpus line 1
corpus line 2
…
```

**Reply**:

```
OK
0.872	espresso shot
0.410	blizzard advisory
…
```

or `ERR\nmessage`. Status probe: empty payload → `READY` / `LOADING` / `ERR\n…`.

## Layout

| Path | Role |
|------|------|
| `src/Main.walnut` | TEA UI + `Port.cmd` |
| `ios/Sources/AppDelegate.swift` | Bootstrap |
| `ios/Sources/EmbedPort.swift` | MLX load + rank handler |

## Limits

- First download needs network; later launches use the Hub cache.
- Embedding runs off-main; reply always comes back on the main queue via `WalnutPorts`.
- Simulator builds may link but **inference will fail** — use a device.
