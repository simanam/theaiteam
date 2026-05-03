#!/usr/bin/env bash
# tools/validate.sh — lint team/ for frontmatter, links, adapter integrity.
# Run locally before commits; CI runs it on every PR.
#
# Exit codes: 0 clean, 1 validation failed.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ERRORS=0
WARNINGS=0

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

err()  { red "  ❌ $*"; ERRORS=$((ERRORS+1)); }
warn() { yellow "  ⚠️  $*"; WARNINGS=$((WARNINGS+1)); }
ok()   { green "  ✅ $*"; }

bold "=== theaiteam validate ==="
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Pass 1 — Frontmatter on files that need it"
# ─────────────────────────────────────────────────────────────────────────
# Scope: roles, top-level agents-extra .md, top-level commands, workflows,
# SKILL.md files (skills proper), the orchestrator persona, the task-board template.
# We do NOT validate aux files inside skill dirs (METHODOLOGY.md, references/*, examples/*)
# nor protocol docs in orchestrator/ that are pure narrative (routing.md, workspace-protocol.md).
PASS1_FILES=0
PASS1_FAILS=0

check_frontmatter() {
  local f="$1"
  local require_name="${2:-true}"   # ECC commands omit name; derived from filename
  PASS1_FILES=$((PASS1_FILES+1))

  local first
  first=$(head -1 "$f" 2>/dev/null)
  if [[ "$first" != "---" ]]; then
    err "Missing frontmatter: $f (first line: '$first')"
    PASS1_FAILS=$((PASS1_FAILS+1))
    return
  fi
  if ! head -30 "$f" | tail -29 | grep -q '^---$'; then
    err "Frontmatter not closed within 30 lines: $f"
    PASS1_FAILS=$((PASS1_FAILS+1))
    return
  fi
  if [ "$require_name" = "true" ] && ! head -30 "$f" | grep -qE '^name:\s'; then
    err "Frontmatter missing 'name:' field: $f"
    PASS1_FAILS=$((PASS1_FAILS+1))
    return
  fi
  if ! head -30 "$f" | grep -qE '^description:\s'; then
    err "Frontmatter missing 'description:' field: $f"
    PASS1_FAILS=$((PASS1_FAILS+1))
    return
  fi
}

# Roles, workflows, top-level agents-extra (not nested), orchestrator persona, task-board template
while IFS= read -r f; do check_frontmatter "$f" true; done < <(\
  find team/roles -name "*.md" -type f 2>/dev/null; \
  find team/workflows -name "*.md" -type f 2>/dev/null; \
  find team/agents-extra -maxdepth 1 -name "*.md" -type f 2>/dev/null; \
  echo "orchestrator/orchestrator.md"; \
  echo "orchestrator/task-board-template.md")

# Commands: many vendored from ECC use 'description:' without 'name:' (name-from-filename convention)
while IFS= read -r f; do check_frontmatter "$f" false; done < <(\
  find team/commands -name "*.md" -type f 2>/dev/null)

# SKILL.md files (skills proper). Some have 'name:', some don't — both are valid.
while IFS= read -r f; do check_frontmatter "$f" false; done < <(\
  find team/skills -name "SKILL.md" -type f 2>/dev/null)

if [ $PASS1_FAILS -eq 0 ]; then
  ok "$PASS1_FILES files checked, all have valid frontmatter"
fi
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Pass 2 — Internal markdown links resolve"
# ─────────────────────────────────────────────────────────────────────────
PASS2_FAILS=0

# Extract relative links from markdown — exclude http(s)://, mailto:, anchors only.
# Scope: ONLY theaiteam-authored content (root docs + roles + workflows + commands +
# orchestrator + our authored skills). Vendored content (team/skills/**/SKILL.md, agents-extra,
# rules/languages-extra, _trailofbits) keeps its own internal references; we don't validate
# upstream's choices about its own layout.
while IFS= read -r f; do
  # Find [text](path) where path is not http/mailto/anchor-only
  while IFS= read -r match; do
    [ -z "$match" ] && continue
    link=$(echo "$match" | sed -nE 's/.*\]\(([^)]+)\).*/\1/p')
    [ -z "$link" ] && continue
    # Strip anchor fragment
    target_path="${link%%#*}"
    [ -z "$target_path" ] && continue
    # Skip absolute URLs and mailto
    case "$target_path" in
      http://*|https://*|mailto:*|tel:*) continue ;;
    esac
    # Skip placeholder/template patterns common in templates and skill examples
    case "$target_path" in
      *"<"*">"*) continue ;;       # <slug>, <project>, etc.
      *"{"*"}"*) continue ;;        # {baseDir}, {var}
      "relative/path"|"relative/path.md") continue ;;  # illustrative example placeholder
    esac
    base=$(dirname "$f")
    candidate="$base/$target_path"
    # Resolve and check existence
    if [ ! -e "$candidate" ] && [ ! -e "$target_path" ]; then
      err "Broken link in $f: $link → not found at $candidate"
      PASS2_FAILS=$((PASS2_FAILS+1))
    fi
  done < <(awk 'BEGIN{in_code=0} /^```/{in_code=1-in_code; next} !in_code{print}' "$f" 2>/dev/null | grep -oE '\]\([^)]+\)' 2>/dev/null)
done < <(\
  echo "CLAUDE.md"; echo "README.md"; echo "GETTING_STARTED.md"; \
  echo "THIRD_PARTY_NOTICES.md"; echo "_team-gaps.md"; echo "LICENSE"; \
  find docs improvement-briefs orchestrator -name "*.md" -type f 2>/dev/null; \
  find team/roles team/commands team/workflows team/rules/common team/rules/languages -name "*.md" -type f 2>/dev/null; \
  find team/skills/engineering/search-first team/skills/meta/team-audit team/skills/meta/upstream-sync-check team/skills/meta/log-gap team/skills/meta/apply-self-fix -name "SKILL.md" -type f 2>/dev/null \
)

if [ $PASS2_FAILS -eq 0 ]; then
  ok "All relative links resolve"
fi
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Pass 3 — Role default-skills point at real skills"
# ─────────────────────────────────────────────────────────────────────────
PASS3_FAILS=0

while IFS= read -r role; do
  # Extract default-skills list from the role's YAML frontmatter
  in_default=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^default-skills:$ ]]; then in_default=1; continue; fi
    if [ $in_default -eq 1 ]; then
      if [[ "$line" =~ ^[a-z] ]] || [[ "$line" == "---" ]]; then break; fi
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.+)$ ]]; then
        skill="${BASH_REMATCH[1]}"
        # Format is domain/skill-name (e.g., engineering/test-driven-development)
        skill_path="team/skills/$skill/SKILL.md"
        if [ ! -f "$skill_path" ]; then
          # Try marketing nested form (marketing/strategy/foo) — already in path; but our roles use domain/skill not domain/sub/skill
          err "Role $role default-skill '$skill' not found at $skill_path"
          PASS3_FAILS=$((PASS3_FAILS+1))
        fi
      fi
    fi
  done < <(head -30 "$role")
done < <(find team/roles -name "*.md" -type f 2>/dev/null)

if [ $PASS3_FAILS -eq 0 ]; then
  ok "All role default-skills resolve to existing SKILL.md files"
fi
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Pass 4 — Adapter sync runs cleanly"
# ─────────────────────────────────────────────────────────────────────────
if [ -x ./adapters/sync-all.sh ]; then
  if ./adapters/sync-all.sh > /tmp/theaiteam-sync.log 2>&1; then
    ok "./adapters/sync-all.sh exited 0"
  else
    err "./adapters/sync-all.sh failed — see /tmp/theaiteam-sync.log"
    tail -20 /tmp/theaiteam-sync.log | sed 's/^/    /'
    ERRORS=$((ERRORS+1))
  fi
else
  err "adapters/sync-all.sh not executable"
fi
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Pass 5 — Skill SKILL.md count matches across team/ and .claude/"
# ─────────────────────────────────────────────────────────────────────────
expected=$(find team/skills -name 'SKILL.md' -type f 2>/dev/null | wc -l | tr -d ' ')
synced=$(find .claude/skills -type l 2>/dev/null | wc -l | tr -d ' ')
if [ "$expected" -eq "$synced" ]; then
  ok "$expected SKILL.md files in team/skills/ ↔ $synced symlinks in .claude/skills/"
else
  warn "Drift: $expected SKILL.md files but $synced symlinks in .claude/skills/ — re-run sync"
fi
echo

# ─────────────────────────────────────────────────────────────────────────
bold "Summary"
# ─────────────────────────────────────────────────────────────────────────
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  green "✅ All passes clean."
  exit 0
elif [ $ERRORS -eq 0 ]; then
  yellow "⚠️  $WARNINGS warning(s), 0 errors."
  exit 0
else
  red "❌ $ERRORS error(s), $WARNINGS warning(s)."
  exit 1
fi
