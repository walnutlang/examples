#!/usr/bin/env bash
# Rewrite __WALNUT_RUNTIME__ in ios/project.yml to the local Walnut runtime.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -n "${WALNUT_HOME:-}" ]]; then
  RUNTIME="$WALNUT_HOME"
elif command -v brew >/dev/null 2>&1 && brew --prefix walnut >/dev/null 2>&1; then
  RUNTIME="$(brew --prefix walnut)/share/walnut/runtime"
else
  echo "error: set WALNUT_HOME or install walnut via Homebrew" >&2
  exit 1
fi
if [[ ! -f "$RUNTIME/Package.swift" ]]; then
  echo "error: no Package.swift under $RUNTIME" >&2
  exit 1
fi
find "$ROOT" -name project.yml -print0 | while IFS= read -r -d '' f; do
  sed -i '' "s|__WALNUT_RUNTIME__|$RUNTIME|g" "$f"
  echo "→ $f"
done
echo "✓ Runtime → $RUNTIME"
