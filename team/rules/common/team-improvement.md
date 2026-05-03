# Team self-improvement (always follow)

Every role helps keep theaiteam itself healthy. This rule defines how.

## When you notice a gap

You're mid-task. You read a rule, skill, or role file and notice it's wrong, stale, contradictory, or missing something. You have **three** options. Pick by impact:

| Situation | Action |
|---|---|
| Gap is **non-blocking** for your current task | Use [/log-gap](../../commands/log-gap.md) — append to `_team-gaps.md`, keep working. |
| Gap is **blocking** your current task | Log it AND surface to the orchestrator (or user) so the maintainer can fix it before you proceed. |
| Gap is a style/design preference, not a defect | Don't log. Either propose an improvement brief OR let it go. |

## What counts as a gap

- Stale version pins (language, framework, tool)
- Broken internal links in markdown
- A role's `default-skills` referencing a skill that doesn't exist
- A workflow listing a role that's been renamed or removed
- A skill with steps for tooling we no longer use
- A domain (`team/skills/<x>/`) with zero skills despite a role expecting them
- Adapter sync failures
- Vendored skills with known security or correctness issues
- Two rules that contradict each other

## What is NOT a gap

- Personal style preferences ("I'd word this differently")
- Bugs in user projects (those go in the project's own task-board)
- Speculative concerns without evidence
- Improvements that would be nice but the existing version isn't broken

## Roles do NOT auto-fix theaiteam

Only the **team-maintainer** edits files under `team/`, `orchestrator/`, `adapters/`, `tools/`, and root-level docs. Every other role:
- Logs gaps via `/log-gap`
- Surfaces blocking gaps to the orchestrator
- Files an improvement brief at `improvement-briefs/<slug>.md` for non-trivial proposals (then lets the maintainer pick it up)

This separation prevents drive-by edits during project work and keeps every change auditable.

## Frequency

You don't have to scan for gaps. Just log them when you happen to notice them during your normal work. The maintainer runs `/audit` periodically to find what wasn't logged.

## See also

- [team/commands/log-gap.md](../../commands/log-gap.md) — quick-log command
- [team/commands/audit.md](../../commands/audit.md) — full audit (maintainer-only)
- [team/commands/self-improve.md](../../commands/self-improve.md) — audit + apply (maintainer-only)
- [team/skills/meta/log-gap/SKILL.md](../../skills/meta/log-gap/SKILL.md) — full procedure
- [team/skills/meta/team-audit/SKILL.md](../../skills/meta/team-audit/SKILL.md) — audit procedure
- [team/roles/team-maintainer.md](../../roles/team-maintainer.md) — the only role that fixes
