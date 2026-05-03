---
name: upstream-sync-check
description: Compare vendored skills against their upstream source repos to detect drift, new content, or material rewrites.
type: skill
when-to-use: Periodically (monthly) or as part of a /audit run. When THIRD_PARTY_NOTICES says we vendored content from upstream X and we want to know if X has moved on.
related-skills: [meta/team-audit, meta/apply-self-fix]
metadata:
  version: 1.0.0
  origin: theaiteam
---

# Upstream sync check

Verify our vendored content from the 5 upstream repos is still current. Flag drift; don't auto-sync.

## Sources to check

From [THIRD_PARTY_NOTICES.md](../../../../THIRD_PARTY_NOTICES.md):

| Upstream | URL | Vendored at | What we have |
|---|---|---|---|
| coreyhaines31/marketingskills | https://github.com/coreyhaines31/marketingskills | initial vendor 2026-05-03 | 40+ marketing skills |
| affaan-m/everything-claude-code | https://github.com/affaan-m/everything-claude-code | initial vendor 2026-05-03 | 35 agents, 13 skills, 8 commands, 10 lang rule packs |
| obra/superpowers | https://github.com/obra/superpowers | initial vendor 2026-05-03 | 13 skills |
| anthropics/skills | https://github.com/anthropics/skills | initial vendor 2026-05-03 | 12 skills (Apache 2.0 only) |
| trailofbits/skills | https://github.com/trailofbits/skills | initial vendor 2026-05-03 | 20 security skills |

## Procedure

### Step 1 — Re-clone or pull each upstream

```bash
mkdir -p /tmp/refrepos-check
cd /tmp/refrepos-check

for repo in \
  "https://github.com/coreyhaines31/marketingskills.git marketingskills" \
  "https://github.com/affaan-m/everything-claude-code.git everything-claude-code" \
  "https://github.com/obra/superpowers.git superpowers" \
  "https://github.com/anthropics/skills.git anthropic-skills" \
  "https://github.com/trailofbits/skills.git trailofbits-skills"; do
  url=$(echo $repo | awk '{print $1}')
  dir=$(echo $repo | awk '{print $2}')
  if [ -d "$dir" ]; then
    (cd "$dir" && git pull --ff-only)
  else
    git clone --depth 50 "$url" "$dir"
  fi
done
```

### Step 2 — For each vendored skill, diff against upstream

```bash
TEAM=/Users/amansingh/Documents/theaiteam

# Example: marketingskills/copywriting
diff -u \
  /tmp/refrepos-check/marketingskills/skills/copywriting/SKILL.md \
  $TEAM/team/skills/marketing/content/copywriting/SKILL.md \
  > /tmp/diff-copywriting.patch
```

For each skill, report:
- **identical** — no drift
- **drift (cosmetic)** — only formatting/comments differ; ours can stay
- **drift (substantive)** — content differs in meaningful ways; flag for review
- **upstream removed** — skill no longer in upstream; we're holding a fork
- **upstream rewritten** — major version bump in upstream

### Step 3 — Detect new upstream skills we don't have

```bash
# What's in upstream that's not in our vendored set?
diff <(ls /tmp/refrepos-check/marketingskills/skills/ | sort) \
     <(find $TEAM/team/skills/marketing -mindepth 2 -maxdepth 2 -type d -exec basename {} \; | sort)
```

For each new upstream skill, decide:
- **adopt** — vendor it now (file as moderate gap)
- **decline** — note in a `_team-gaps.md` "won't-fix" entry with reason
- **defer** — needs more thought

### Step 4 — Write findings to `_team-gaps.md`

Use the audit findings format. One entry per upstream, summarizing:
- Number of skills with drift (split by cosmetic / substantive)
- Number of new upstream skills not yet vendored
- Number of vendored skills upstream removed
- Pointers to specific diffs of concern

## Pitfalls

- Don't auto-pull upstream changes. We've adapted some skills; blind sync overwrites our adaptations.
- Don't confuse drift in content with drift in license. License changes warrant a separate gap entry.
- Don't forget the trailofbits CC BY-SA constraint — pulling upstream updates retains the share-alike obligation.
- Cosmetic diffs (whitespace, newline conventions) aren't drift. Use `diff --strip-trailing-cr -B` to ignore them.

## Output

Append a single audit-section to `_team-gaps.md`:

```markdown
## Upstream sync check YYYY-MM-DD

| Upstream | Drift (cosmetic) | Drift (substantive) | New skills | Removed |
|---|---|---|---|---|
| marketingskills | 3 | 1 | 2 | 0 |
| everything-claude-code | 0 | 0 | 7 | 0 |
| ...

### Substantive drift detected

- G-NNN — `team/skills/marketing/content/copywriting/SKILL.md`: upstream rewrote the "before writing" section. <br>**Action:** review diff at `/tmp/diff-copywriting.patch` and decide adopt/decline.
```
