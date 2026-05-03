#!/usr/bin/env bash
# adapters/codex/sync.sh — generate AGENTS.md for OpenAI Codex CLI
#
# Codex reads a single AGENTS.md at the repo root containing the team's
# personas, skills, and rules. We concatenate the team/ source-of-truth
# into AGENTS.md with a table of contents.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

OUT="AGENTS.md"

{
  echo "# AGENTS.md"
  echo
  echo "> Generated from \`team/\` by \`adapters/codex/sync.sh\`. Do not hand-edit."
  echo "> Last sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "## Table of contents"
  echo
  echo "- [Roles](#roles)"
  echo "- [Skills](#skills)"
  echo "- [Rules](#rules)"
  echo "- [Commands](#commands)"
  echo "- [Workflows](#workflows)"
  echo
  echo "---"

  echo
  echo "## Roles"
  echo
  for f in team/roles/*.md; do
    echo
    echo "<!-- BEGIN: $f -->"
    echo
    cat "$f"
    echo
    echo "<!-- END: $f -->"
  done

  echo
  echo "---"
  echo
  echo "## Skills"
  echo
  echo "Skills below are organized by domain. Each skill has its own SKILL.md;"
  echo "the source path is shown so you can reference auxiliary files (scripts, examples)."
  echo
  find team/skills -name "SKILL.md" | sort | while read -r skill; do
    echo
    echo "<!-- BEGIN: $skill -->"
    echo
    cat "$skill"
    echo
    echo "<!-- END: $skill -->"
  done

  echo
  echo "---"
  echo
  echo "## Rules"
  echo
  for f in team/rules/common/*.md; do
    echo
    echo "<!-- BEGIN: $f -->"
    echo
    cat "$f"
    echo
    echo "<!-- END: $f -->"
  done

  echo
  echo "### Language-specific rules"
  echo
  for f in team/rules/languages/*.md; do
    echo
    echo "<!-- BEGIN: $f -->"
    echo
    cat "$f"
    echo
    echo "<!-- END: $f -->"
  done

  echo
  echo "---"
  echo
  echo "## Commands"
  echo
  for f in team/commands/*.md; do
    echo
    echo "<!-- BEGIN: $f -->"
    echo
    cat "$f"
    echo
    echo "<!-- END: $f -->"
  done

  echo
  echo "---"
  echo
  echo "## Workflows"
  echo
  for f in team/workflows/*.md; do
    echo
    echo "<!-- BEGIN: $f -->"
    echo
    cat "$f"
    echo
    echo "<!-- END: $f -->"
  done

} > "$OUT"

echo "✅ AGENTS.md generated"
echo "   $(wc -l < "$OUT") lines, $(du -h "$OUT" | cut -f1)"
