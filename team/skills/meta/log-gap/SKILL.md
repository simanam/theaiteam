---
name: log-gap
description: When any role notices a gap in theaiteam during normal project work, record it in _team-gaps.md without breaking flow. Maintainer drains the log later.
type: skill
when-to-use: When you (any role) notice during normal work that a rule, skill, or role file is wrong, stale, contradictory, or missing — and fixing it would derail your current task.
related-skills: [meta/team-audit, meta/apply-self-fix]
metadata:
  version: 1.0.0
  origin: theaiteam
---

# Log gap (any-role channel)

This skill exists for **every role**, not just the maintainer. The maintainer is the consumer.

## Why

You're mid-task. You read `team/rules/languages/swift.md` and notice it says "Swift 5.9+" but Swift 6 has been stable for ages. You don't want to:
- Stop your current work to go fix it
- Drop the gap on the floor and forget

So: log it in 30 seconds, keep going. Maintainer processes the queue on the next `/audit` or `/self-improve`.

## How to log

Append a stub entry to the root-level `_team-gaps.md`. If the file doesn't exist yet, create it with the header below.

```markdown
# theaiteam — gap log

This is the queue of identified gaps in theaiteam itself. Roles append here when they notice issues during project work. Maintainer drains the queue.

Conventions:
- Each gap has an ID (G-NNN), severity, evidence, proposed fix, status, logged-by, logged-date.
- Append-only — never delete entries. Mark `won't-fix` with reason if rejected.
- Numbering is global; G-001 is the first gap ever.
- Maintainer is the only one who closes entries (sets `fixed-in-<sha>` or `filed-as-improvement-<slug>`).

---

## Gap G-NNN — <short title>
**Severity:** trivial | moderate | structural
**Evidence:** path/to/file:line — <quoted text>
**Proposed fix:** what to change (short — Maintainer fills in details)
**Status:** open
**Logged by:** <your-role-name>
**Logged date:** YYYY-MM-DD
**Notes:** anything else relevant
```

## Severity quick guide

You don't have to be precise — Maintainer reclassifies. But a starting estimate helps:

- **trivial**: typo, wrong version pin, broken link, missing field, single-line fix
- **moderate**: a section that needs rewriting, a skill that contradicts itself, a missing skill in a domain that already has others
- **structural**: needs a new role / new workflow / new directory / new convention

## What counts as a gap

Yes:
- Stale version pin ("Swift 5.9" when the world has moved on)
- A rule that contradicts another rule
- A role's `default-skills` list points at a skill that doesn't exist
- A workflow that references a role that's been renamed
- A skill that lists steps for a tool we no longer use
- A domain (e.g., devops/) that has zero skills despite a role expecting them
- An adapter that fails to sync because of a malformed file
- A vendored skill that has a known security issue / outdated practice
- A missing language rule pack for a stack we keep using

No:
- "I disagree with this rule" (file an improvement brief instead — full discussion warranted)
- "I'd write this differently" (style preferences aren't gaps)
- Issues in user projects (those go in the project's own task-board, not theaiteam-level)

## Steps

1. Open `_team-gaps.md` at the repo root.
2. Find the highest G-NNN number; your entry is the next.
3. Append the new gap entry per the format above.
4. Save.
5. Continue your original task. Don't fix the gap unless it's blocking you.

If the gap is **blocking** your current task (e.g., a workflow file is broken so you can't dispatch), do this instead:
1. Log the gap as above with severity escalated.
2. Surface it to the orchestrator (or directly to the user if running solo) — the maintainer needs to fix this before you can proceed.

## Pitfalls

- **Logging without evidence.** Always include a path:line and a quote. "I think there's a problem somewhere" isn't actionable.
- **Logging style preferences.** Use improvement-briefs for those.
- **Trying to fix as you log.** Stay in your lane — finish the project work first.
- **Forgetting to increment G-NNN.** If two roles log gaps simultaneously they may collide. The maintainer cleans up duplicates on next audit.
