---
name: log-gap
description: Quick-record a gap in theaiteam from any role mid-task. Goes into _team-gaps.md for the maintainer to drain later.
type: command
args: <severity> <short-title>
---

# /log-gap <severity> <short-title>

You're a role mid-task and noticed a problem in theaiteam itself (a stale rule, a broken skill reference, a missing pack). Log it and keep going.

## Steps

1. Use [meta/log-gap](../skills/meta/log-gap/SKILL.md) — read it once if you haven't.
2. Open `_team-gaps.md` at the repo root. Create it if missing using the header from log-gap skill.
3. Find the highest existing G-NNN; yours is the next.
4. Append a new entry with:
   - **Severity:** trivial | moderate | structural (best estimate; maintainer reclassifies)
   - **Evidence:** path/to/file:line — quoted text
   - **Proposed fix:** one-liner
   - **Status:** open
   - **Logged by:** <your role name>
   - **Logged date:** today's date
   - **Notes:** anything else relevant
5. Continue your original task.

## Example

You're acting as the mobile-engineer, reading swift.md, and notice it pins Swift 5.9. You run:

`/log-gap trivial swift-version-pin-stale`

Resulting entry in `_team-gaps.md`:

```markdown
## Gap G-007 — swift-version-pin-stale
**Severity:** trivial
**Evidence:** team/rules/languages/swift.md:5 — "Swift 5.9+; targeting iOS 16+ unless brief says otherwise."
**Proposed fix:** Bump pin to Swift 6.0; iOS 16+ floor still reasonable.
**Status:** open
**Logged by:** mobile-engineer
**Logged date:** 2026-05-03
**Notes:** Verified Swift 6.0 stable since June 2024 per swift.org.
```

Then you go back to your iOS work. Maintainer picks this up on the next /audit or /self-improve.

## Use when

- A rule references an outdated version
- A role's `default-skills` points at a missing skill
- A workflow names a role that doesn't exist
- An adapter sync fails because of a malformed file
- Two rules contradict each other
- A skill's instructions don't work with the current tooling
- You'd otherwise just shrug and work around it

## Don't use for

- Disagreements about how a role should behave (file an improvement brief instead)
- Bugs in user projects (those go in the project's own task-board)
- Style preferences ("I'd write this differently")

## Anti-patterns

- Logging a gap and then trying to fix it yourself. Stay in your lane — finish your role's task first. Maintainer drains the queue.
- Forgetting evidence. Without `path:line — quoted text`, the gap is useless to the maintainer.
- Logging duplicates. Skim recent entries first; if your gap is already there, append a note to the existing entry instead of creating a new one.
