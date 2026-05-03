---
name: audit
description: Run a read-only audit of theaiteam. Surfaces staleness, drift, broken links, missing skills, outdated content. Does not change anything.
type: command
args: (none)
---

# /audit

Become the team-maintainer. Run [meta/team-audit](../skills/meta/team-audit/SKILL.md). Append findings to `_team-gaps.md`. Don't apply fixes.

## Steps

1. Load the team-maintainer role file: [team/roles/team-maintainer.md](../roles/team-maintainer.md)
2. Run all six audit passes per [meta/team-audit](../skills/meta/team-audit/SKILL.md):
   - Internal consistency (broken links, dangling references)
   - Frontmatter validity
   - Coverage gaps (empty domains, missing language packs)
   - Staleness (version pins vs. world)
   - Upstream sync drift (vendored content vs. upstream)
   - Adapter sync drift (team/ vs. .claude/, AGENTS.md, etc.)
3. Append all findings to `_team-gaps.md` (create the file if missing using the format in [meta/log-gap](../skills/meta/log-gap/SKILL.md)).
4. Surface a summary to the user:

```
🔍 Audit complete

Open gaps: N
  - Trivial:    M  (recommend /self-improve to auto-fix)
  - Moderate:   K  (review needed; some auto-fixable)
  - Structural: L  (will be filed as improvement briefs)

Top 3 by impact:
  1. G-NNN — <title> (<severity>)
  2. ...
  3. ...

Full report: _team-gaps.md
Next: run /self-improve to apply fixes, or read the report and decide.
```

## When to use

- Monthly cadence to catch drift
- Before a major project (you want the team in good shape)
- After vendoring new upstream content (sanity check)
- When something feels off (a role's behavior surprised you, a skill seemed stale)
- After a `/log-gap` accumulation — to consolidate

## Anti-patterns

- Calling /audit and ignoring the findings. The log keeps growing.
- Calling /audit during active project work — surface area is too large; finish the project first.
- Skipping a pass because "it's probably fine." Fine becomes broken faster than you think.
