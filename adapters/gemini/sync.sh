#!/usr/bin/env bash
# adapters/gemini/sync.sh — generate Gemini CLI config from team/
#
# Gemini CLI reads ~/.gemini/ and project-local .gemini/ for context,
# rules, and commands. The exact format varies by Gemini CLI version,
# so this is a starter that creates a single GEMINI.md and a .gemini/
# context dir referencing the team/ source-of-truth.
#
# Extend per the Gemini CLI version you use.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

mkdir -p .gemini

# 1. GEMINI.md at root — same format as AGENTS.md but Gemini-flavored
{
  echo "# GEMINI.md"
  echo
  echo "> Generated from \`team/\` by \`adapters/gemini/sync.sh\`. Do not hand-edit."
  echo "> Last sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "## Roles, skills, rules, commands, and workflows"
  echo
  echo "See [AGENTS.md](AGENTS.md) for the full canonical content (Codex format)."
  echo "Gemini CLI reads this file plus the [.gemini/](.gemini/) directory."
  echo
  echo "## Source-of-truth"
  echo
  echo "All content lives in [team/](team/). Adapters in [adapters/](adapters/) generate per-provider configs."
  echo
} > GEMINI.md

# 2. .gemini/context.md — reference index
{
  echo "# Gemini context index"
  echo
  echo "Roles:"
  for f in team/roles/*.md; do echo "- [$(basename "${f%.md}")](../$f)"; done
  echo
  echo "Skills:"
  find team/skills -name "SKILL.md" | sort | while read -r f; do
    echo "- [$(basename "$(dirname "$f")")](../$f)"
  done
  echo
  echo "Rules:"
  for f in team/rules/common/*.md; do echo "- [$(basename "${f%.md}")](../$f)"; done
} > .gemini/context.md

echo "✅ Gemini configs generated"
echo "   GEMINI.md"
echo "   .gemini/context.md"
echo
echo "Note: Gemini CLI integration is a starter. Extend this script per your version's"
echo "expected file layout (settings.json, system instructions, etc.)."
