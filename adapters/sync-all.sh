#!/usr/bin/env bash
# adapters/sync-all.sh — refresh all provider configs from the team/ source-of-truth
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "→ Syncing Claude Code…"
./adapters/claude-code/sync.sh

echo "→ Syncing Codex…"
./adapters/codex/sync.sh

echo "→ Syncing Gemini…"
./adapters/gemini/sync.sh

echo
echo "✅ All providers synced."
echo "   .claude/  ← Claude Code"
echo "   AGENTS.md ← Codex"
echo "   .gemini/  ← Gemini CLI"
