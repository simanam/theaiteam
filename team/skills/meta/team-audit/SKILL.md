---
name: team-audit
description: Sweep theaiteam for staleness, drift, broken links, missing skills, and outdated content. Produce a structured report in _team-gaps.md.
type: skill
when-to-use: Whenever Team Maintainer is invoked via /audit or /self-improve, or when a project run surfaced multiple gaps that need consolidation.
related-skills: [meta/upstream-sync-check, meta/apply-self-fix, meta/log-gap]
metadata:
  version: 1.0.0
  origin: theaiteam
---

# Team audit

A read-only sweep that produces a findings report. Doesn't change anything — that's [apply-self-fix](../apply-self-fix/SKILL.md)'s job.

## Six audit passes

Run them in order. Stop and surface only after all six are complete.

### Pass 1 — Internal consistency

```bash
# Find broken markdown links (relative paths only)
cd /Users/amansingh/Documents/theaiteam
grep -rEn '\]\((?!https?://)[^)]+\)' team/ docs/ orchestrator/ adapters/ *.md | \
  while IFS=: read -r file lineno match; do
    link=$(echo "$match" | grep -oE '\]\([^)]+\)' | sed 's/](//;s/)$//' | head -1)
    base=$(dirname "$file")
    target="$base/$link"
    [ -e "$target" ] || [ -e "${target%#*}" ] || echo "BROKEN: $file:$lineno → $link"
  done
```

Also check:
- Every role file's `default-skills:` frontmatter list points at an existing `team/skills/<path>/SKILL.md`
- Every workflow's `roles:` list matches actual files in `team/roles/`
- Every command's `args` line matches what the body describes
- Every skill's `related-skills:` resolve

### Pass 2 — Frontmatter validity

For every `*.md` file in `team/`, `orchestrator/`, and `adapters/*/README.md`:
- YAML frontmatter present (between `---` fences)
- Required fields per type:
  - role: name, description, tools, model
  - skill: name, description, type
  - workflow: name, description, type, triggers, roles
  - command: name, description, type
- `name` matches filename (kebab-case)
- `description` is non-empty and a real sentence

### Pass 3 — Coverage gaps

- Each role's `default-skills` list is non-empty
- Each domain in `team/skills/` has at least one skill (currently flagged: `devops/`, top-level `security/`)
- Each brief `type` value listed in any brief's frontmatter has a matching workflow
- Each language in `team/rules/languages/` has a matching language-reviewer agent in `team/agents-extra/language-reviewers/` (or a noted gap)

### Pass 4 — Staleness (world drift)

For each version pin found in `team/rules/`, `team/skills/`, role files:
- Language pins: Swift, Kotlin, Python, Node/TypeScript, Go, Rust
- Framework pins: SwiftUI/iOS target, Compose/Android target, FastAPI, Next.js, React, Tailwind
- Tool pins: Xcode, AGP, ESLint, Ruff
- Spec pins: OWASP Top 10 year, GDPR/CCPA references

Procedure:
1. Grep for the pin (e.g., `grep -rEn 'Swift [0-9]\.[0-9]+' team/rules/`)
2. WebSearch / WebFetch the official source to confirm the latest stable version
3. If pinned version is a major behind: flag as **stale**
4. If pinned version is current or one minor behind: OK
5. Cite the source in the gap entry

Be careful: some pins are deliberate floors ("targeting iOS 16+"). Don't flag floors as stale unless the floor itself is unreasonable (e.g., iOS 12 today).

### Pass 5 — Upstream sync drift

Use [upstream-sync-check](../upstream-sync-check/SKILL.md). For each vendored upstream listed in [THIRD_PARTY_NOTICES.md](../../../../THIRD_PARTY_NOTICES.md), check:
- Has the upstream had a major release since the vendor date?
- Have any vendored skills been materially rewritten upstream?
- Have any new skills been added upstream that we'd want?

Surface as moderate findings — don't auto-pull upstream changes without review.

### Pass 6 — Adapter sync drift

```bash
# Compare the count of files in team/ vs what was synced into .claude/ etc.
cd /Users/amansingh/Documents/theaiteam
expected_skills=$(find team/skills -name 'SKILL.md' | wc -l)
synced_skills=$(find .claude/skills -type l 2>/dev/null | wc -l)
[ "$expected_skills" = "$synced_skills" ] || echo "DRIFT: $expected_skills SKILL.md files but $synced_skills symlinks in .claude/skills/"

# Check AGENTS.md is fresher than the latest team/ edit
agents_mtime=$(stat -f %m AGENTS.md 2>/dev/null || stat -c %Y AGENTS.md)
latest_team_mtime=$(find team/ -name '*.md' -exec stat -f %m {} \; 2>/dev/null | sort -n | tail -1)
[ "$agents_mtime" -ge "$latest_team_mtime" ] || echo "DRIFT: AGENTS.md is older than team/ — run ./adapters/sync-all.sh"
```

## Output format — `_team-gaps.md`

Append findings to `_team-gaps.md` at the repo root. Don't overwrite existing entries; mark resolved ones with status.

```markdown
## Audit YYYY-MM-DD

### G-NNN — <short title>
**Severity:** trivial | moderate | structural
**Evidence:** path/to/file:line — actual quoted text
**Proposed fix:** what to change
**Citation:** (for staleness) URL of source confirming the drift
**Status:** open | in-progress | fixed-in-<commit-sha> | filed-as-improvement-<brief-slug> | won't-fix
**Logged by:** team-maintainer | <other-role-name>
**Logged date:** YYYY-MM-DD
```

Numbering: G-001 is the first gap ever logged. Increment globally — don't reset per audit.

## When to escalate vs. self-fix

Use [apply-self-fix](../apply-self-fix/SKILL.md) for the rules. Quick guide:

| Severity | Action |
|---|---|
| trivial | Apply fix immediately. Mark `fixed-in-<sha>`. |
| moderate | Apply if confident; otherwise file an improvement brief. |
| structural | File an improvement brief. Run the team-improvement workflow. |

## Pitfalls

- Running the audit and "fixing as you find." That mixes audit and apply, which makes commits sprawl. Audit first, fix second.
- Reasoning about currency from training data without a citation. Always verify.
- Treating every old version pin as stale. Some are deliberate floors; preserve the intent.
- Skipping the adapter-sync drift check. It's the most common real-world drift.
