#!/usr/bin/env bash
# adapters/claude-code/sync.sh — symlink team/ into .claude/ for Claude Code
#
# Claude Code reads agents from .claude/agents/, skills from .claude/skills/,
# commands from .claude/commands/. We symlink the team/ source-of-truth into
# the right places so editing team/<file>.md is immediately picked up.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

CLAUDE=".claude"
mkdir -p "$CLAUDE"

# Wipe and re-link (symlinks are cheap)
rm -rf "$CLAUDE/agents" "$CLAUDE/skills" "$CLAUDE/commands" "$CLAUDE/rules"

# 1. Agents = our 11 roles + the agents-extra specialists
mkdir -p "$CLAUDE/agents"
for f in team/roles/*.md; do
  ln -s "../../$f" "$CLAUDE/agents/$(basename "$f")"
done
for f in team/agents-extra/*.md; do
  [ -f "$f" ] && ln -s "../../$f" "$CLAUDE/agents/$(basename "$f")"
done

# 2. Skills — flatten our nested taxonomy into .claude/skills/<name>/SKILL.md
#    Claude Code expects each skill to be a directory with SKILL.md inside.
mkdir -p "$CLAUDE/skills"
find team/skills -name "SKILL.md" -print0 | while IFS= read -r -d '' skill; do
  skill_dir="$(dirname "$skill")"
  skill_name="$(basename "$skill_dir")"
  # Avoid name collisions by prefixing with the parent category (e.g., engineering-tdd)
  parent_dir="$(dirname "$skill_dir")"
  parent="$(basename "$parent_dir")"
  # Skip _trailofbits and similar internal-grouping dirs
  if [[ "$parent" == _* ]]; then
    grandparent="$(basename "$(dirname "$parent_dir")")"
    target_name="${grandparent}-trailofbits-${skill_name}"
  else
    # Find the top-level domain by climbing
    domain="$parent"
    target_name="${domain}-${skill_name}"
  fi
  ln -s "../../$skill_dir" "$CLAUDE/skills/$target_name"
done

# 3. Commands
mkdir -p "$CLAUDE/commands"
for f in team/commands/*.md; do
  [ -f "$f" ] && ln -s "../../$f" "$CLAUDE/commands/$(basename "$f")"
done

# 4. Rules — Claude Code reads CLAUDE.md as the project root memory.
#    Our CLAUDE.md already points to team/rules/. We symlink them for direct access too.
mkdir -p "$CLAUDE/rules"
for f in team/rules/common/*.md; do
  [ -f "$f" ] && ln -s "../../$f" "$CLAUDE/rules/$(basename "$f")"
done

echo "✅ .claude/ synced"
echo "   $(find "$CLAUDE/agents" -type l | wc -l) agents"
echo "   $(find "$CLAUDE/skills" -type l | wc -l) skills"
echo "   $(find "$CLAUDE/commands" -type l | wc -l) commands"
echo "   $(find "$CLAUDE/rules" -type l | wc -l) rules"
