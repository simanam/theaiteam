---
name: apply-self-fix
description: Apply gap-fixes to theaiteam itself with safety rails. Trivial issues edited and committed directly; moderate flagged for review; structural filed as improvement briefs.
type: skill
when-to-use: After a /audit run has populated _team-gaps.md, or when /self-improve is invoked.
related-skills: [meta/team-audit, meta/upstream-sync-check, meta/log-gap]
metadata:
  version: 1.0.0
  origin: theaiteam
---

# Apply self-fix

The mechanics of changing theaiteam without breaking it. **Only the team-maintainer role uses this skill.**

## The decision tree

For each open gap in `_team-gaps.md`:

```
Is severity trivial?
  yes → Auto-fix path
  no  → ↓
Is severity moderate AND I have high confidence in the fix?
  yes → Auto-fix path (with extra verification)
  no  → ↓
Is severity moderate or structural?
  → Improvement-brief path
```

## Auto-fix path (trivial + confident moderate)

For each gap:

1. **Re-read the gap entry.** Confirm severity, evidence, proposed fix.
2. **Verify the claim.** If the gap is "Swift 5.9 should be Swift 6," WebFetch swift.org to confirm the current stable version. Capture the URL — it goes in the commit.
3. **Make the edit.** Use the Edit tool against the exact file:line called out in evidence. Avoid drive-by changes.
4. **Run the validation suite:**
   ```bash
   cd /Users/amansingh/Documents/theaiteam
   # 1. Frontmatter still valid?
   head -20 <changed-file>
   # 2. Internal links still resolve? (run pass 1 of team-audit)
   grep -rEn '\]\((?!https?://)[^)]+\)' <changed-file>
   # 3. Adapter sync still works?
   ./adapters/sync-all.sh
   ```
5. **Commit.** Conventional Commit prefix `chore(team):` or `fix(team):`. Body cites the gap ID and the evidence URL.
   ```
   fix(team): bump Swift version pin to 6.0 in language rules

   Gap G-007. Swift 6.0 is the current stable per
   https://swift.org/blog/swift-6/ (June 2024). Updates the
   minimum-supported version pin from 5.9 to 6.0 in
   team/rules/languages/swift.md.

   Co-Authored-By: theaiteam-maintainer <noreply@anthropic.com>
   ```
6. **Update `_team-gaps.md`.** Set status to `fixed-in-<short-sha>`.

If any validation step fails, **revert the edit** and re-classify the gap as moderate. Don't ship a broken team.

## Improvement-brief path (moderate-uncertain + structural)

For each gap:

1. **Create a brief.** Copy [improvement-briefs/_template.md](../../../../improvement-briefs/_template.md) to `improvement-briefs/<gap-slug>.md`. Fill it in like a project brief — goal, success criteria, deliverables, affected files.
2. **Update `_team-gaps.md`.** Set status to `filed-as-improvement-<gap-slug>`.
3. **Surface to user.** Summarize: "Filed N improvement briefs at improvement-briefs/. Run `/kickoff <slug>` on each when you're ready to address."

The improvement brief then runs through the [team-improvement workflow](../../../workflows/team-improvement.md) like any other project, with the maintainer as lead.

## Validation suite (the must-pass list)

After ANY edit to `team/`, `orchestrator/`, or `adapters/`, before committing:

| Check | Command | Pass criteria |
|---|---|---|
| Frontmatter present | `head -10 <file>` | Has `---` fences with required fields |
| Internal links resolve | grep + file existence | No BROKEN entries |
| Adapter sync runs | `./adapters/sync-all.sh` | Exits 0 |
| Skill counts match | compare team/skills SKILL.md count vs .claude/skills symlink count | Equal |
| AGENTS.md regenerated | `stat AGENTS.md` mtime | Newer than the edited file |

## Hard prohibitions

NEVER auto-fix:
- Files in [licenses/](../../../../licenses/)
- [THIRD_PARTY_NOTICES.md](../../../../THIRD_PARTY_NOTICES.md)
- Any `_trailofbits/` content (CC BY-SA — derivative changes carry the obligation; surface to user first)
- Anything in `workspace/` (those are project-specific; not theaiteam's source-of-truth)

NEVER batch:
- Don't combine fixes for unrelated gaps in one commit. One gap → one commit (or one improvement brief).
- Don't fix-and-refactor in the same change. Refactors are separate commits.

NEVER skip:
- The validation suite. Every time. Even for one-line edits.
- The commit. Silent edits make later audits harder.
- The status update in `_team-gaps.md`. The log is the source of truth.

## Output

After processing the queue:

```
## Self-improvement run YYYY-MM-DD

Processed N gaps:
- M trivial → auto-fixed (commits: <sha1>, <sha2>, …)
- K moderate → P auto-fixed, Q filed as improvement briefs (improvement-briefs/<slugs>)
- L structural → all filed as improvement briefs

Validation: pass / fail

Next steps:
- Run `/kickoff <slug>` on each improvement brief when ready
- Re-run `/audit` after the next batch of project work to refresh the queue
```

Surface this to the user.
