---
name: self-improve
description: Run /audit then apply fixes. Trivial gaps auto-edited and committed; non-trivial filed as improvement briefs. Has hard safety rails.
type: command
args: [optional: --dry-run]
---

# /self-improve [--dry-run]

Become the team-maintainer. Audit, then apply.

## Steps

1. **Audit.** Run [/audit](audit.md) first if `_team-gaps.md` is empty or older than 7 days. Otherwise use existing log.
2. **Triage.** Per [meta/apply-self-fix](../skills/meta/apply-self-fix/SKILL.md) decision tree.
3. **Auto-fix loop.** For each trivial / high-confidence-moderate gap:
   - Verify the claim (WebFetch / WebSearch as needed)
   - Edit the exact file:line
   - Run validation suite (frontmatter, links, adapter sync)
   - Commit with `fix(team):` or `chore(team):` prefix
   - Update gap status to `fixed-in-<sha>`
4. **File improvement briefs.** For each remaining gap (moderate-uncertain, structural):
   - Copy [improvement-briefs/_template.md](../../improvement-briefs/_template.md) to `improvement-briefs/<gap-slug>.md`
   - Fill it with the gap's evidence, proposed fix, affected files, success criteria
   - Update gap status to `filed-as-improvement-<slug>`
5. **Verify.** Re-run [meta/team-audit](../skills/meta/team-audit/SKILL.md) — every gap that was `open` should now be terminal (fixed / filed / won't-fix).
6. **Surface results.** Tell the user:

```
🛠 Self-improve complete

Fixed automatically:
- M trivial gaps (commits: <sha1>, <sha2>, …)
- N high-confidence moderate gaps (commits: <sha3>, …)

Filed as improvement briefs:
- improvement-briefs/<slug-1>.md (G-NNN, severity, summary)
- improvement-briefs/<slug-2>.md (...)

Won't-fix (with reason):
- G-NNN — <why>

Validation: ✅ all passes  /  ❌ <which>

Next:
- Run /kickoff <slug> on improvement briefs you want to address
- Run /audit again in 30 days to catch new drift
```

## --dry-run

Shows what /self-improve WOULD do without making any edits, commits, or brief-filings. Useful before a big maintenance run.

## Hard safety rails

Per [meta/apply-self-fix](../skills/meta/apply-self-fix/SKILL.md):
- **Never auto-fix** files in [licenses/](../../licenses/), [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md), or `_trailofbits/` content
- **Never batch** unrelated gaps into one commit
- **Never skip** the validation suite
- **Never silent-edit** — every change is committed with attribution

## When to use

- Right after `/audit` when the queue is full
- Quarterly maintenance run
- Before handing the team to someone new (clean slate)
- After a known-stale period (e.g., you didn't audit for months)

## Anti-patterns

- Running `/self-improve` mid-project. The maintainer will be churning files other roles are referencing. Finish project work first.
- Skipping `--dry-run` on a large queue. If 50 gaps are open, see the plan before running it.
- Not reviewing the auto-fix commits. They're committed automatically but you should still skim before pushing to a remote.
- Ignoring filed improvement briefs. They sit there unless you `/kickoff` them.
