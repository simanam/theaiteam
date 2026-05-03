---
name: standup
description: Daily-standup-style status read of an active project. Surfaces blockers and what's next.
type: command
args: <brief-slug>
---

# /standup <brief-slug>

Read the current state of `workspace/<brief-slug>/` and report a 5-line standup-style update.

## Steps

1. Read `workspace/<brief-slug>/task-board.md`
2. Read the most recent 5 handoff packets in `workspace/<brief-slug>/handoffs/`
3. Read open questions in `workspace/<brief-slug>/plans/decisions.md`

## Output format

```
Project: <slug>
Workflow: <workflow-name>
Stage: <current stage> (<n> of <total>)

✅ Done since last standup:
- <stage>: <what shipped>

🚧 In progress:
- <role>: <what they're working on> (since <date>)

⛔ Blocked:
- <role>: <what they're stuck on> (waiting on <whom>)

❓ Open questions for the user:
- Q1: <question> — recommended answer: <pick>

📅 Next dispatch:
- <role>: <what they'll start when current stage completes>
```

If everything is unblocked and progressing, say so. Don't invent issues.

## When to use

- Daily, on long-running projects
- When picking up a project after a gap (gives you context fast)
- Before a user check-in (so you walk in with the right summary)
