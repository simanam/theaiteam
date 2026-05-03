---
name: handoff
description: Author a structured handoff packet from the current role to another.
type: command
args: <to-role> [optional: brief-slug]
---

# /handoff <to-role> [brief-slug]

You're currently acting as some role (or the orchestrator). The current stage is done. Write the handoff packet to the next role.

## Steps

1. Determine the brief-slug (from arg or current workspace context).
2. Determine the from-role (your current persona).
3. Determine the next handoff number `n` for this `from→to` pair (look in `workspace/<slug>/handoffs/` for the highest existing).
4. Write `workspace/<slug>/handoffs/<from-role>-to-<to-role>-<n>.md` per the format in [orchestrator/workspace-protocol.md](../../orchestrator/workspace-protocol.md).
5. Update `workspace/<slug>/task-board.md`:
   - Mark your row `done` with today's date
   - Mark the next role's row `pending` (if it isn't already)
6. If next role is ready to start (no other dependencies blocking), the orchestrator can dispatch immediately. Otherwise, leave it `pending`.

## Handoff packet format (copy this template)

```markdown
---
from: <your-role>
to: <to-role>
date: YYYY-MM-DD
n: <number>
---

# Handoff — <from> to <to>

## Context
2–3 sentences: what was just done, why, and what's relevant for the next role.

## Inputs you should read
- workspace/<slug>/plans/<file>
- ...

## Goal
1 sentence: what you're being asked to deliver.

## Quality bar
What "done" looks like for your stage.

## Watch out for
- Specific edge cases or open questions you encountered
- Anything ambiguous in the source material
- Decisions you made that the next role might want to revisit

## Time budget
Rough — hours / days / sprints.

## Linked stories
- S-NNN
```

## Anti-patterns

- Handing off mid-stage with the previous work undone
- Skipping the task-board update — it's the source of truth, not a side effect
- "See git for what I did" — the handoff packet must stand alone for someone with no context
