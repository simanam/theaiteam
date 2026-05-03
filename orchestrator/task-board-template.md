---
name: task-board-template
description: Template seed for workspace/<slug>/task-board.md. Orchestrator copies this and replaces placeholders.
type: template
---

# Task Board — <project-slug>

**Brief:** [briefs/<slug>.md](../../briefs/<slug>.md)
**Workflow:** <workflow-name>
**Started:** YYYY-MM-DD
**Status:** active | shipped | abandoned

## Summary

| Stage | Owner | Status | Started | Done | Blocker |
|---|---|---|---|---|---|
| 1. Brief intake + PRD | product-manager | done | 2026-MM-DD | 2026-MM-DD | — |
| 2. System design | architect | in_progress | 2026-MM-DD | — | — |
| 3. Backend impl | backend-engineer | pending | — | — | — |
| 4. Frontend impl | frontend-engineer | pending | — | — | — |
| 5. Design / mockups | designer | pending | — | — | — |
| 6. QA tests | qa-engineer | pending | — | — | — |
| 7. Security review | security-engineer | pending | — | — | — |
| 8. DevOps + deploy | devops-engineer | pending | — | — | — |
| 9. Tech docs | technical-writer | pending | — | — | — |
| 10. Marketing launch kit | marketing-strategist | pending | — | — | — |

Status values: `pending` | `in_progress` | `blocked` | `done` | `skipped`

## Stories

| ID | Title | Acceptance criteria | Owner | Status |
|---|---|---|---|---|
| S-001 | <story title> | see stories.md | backend-engineer | pending |
| S-002 | <story title> | see stories.md | frontend-engineer | pending |

## Open questions

| Q | Asked by | Asked of | Asked on | Answered | Answer |
|---|---|---|---|---|---|
| Q1 | architect | user | 2026-MM-DD | — | — |

## Handoffs

Latest handoff packets are in `../handoffs/`. Newest at top.

- `handoffs/orchestrator-to-product-manager-1.md` — initial dispatch
- `handoffs/product-manager-to-architect-1.md` — PRD ready, please design

## Blockers (active)

None.

## Decisions log pointer

See `../plans/decisions.md` for scope and architecture decisions and their rationale.

## Update protocol

- Each role updates this file when starting (`pending` → `in_progress`), when blocking (`in_progress` → `blocked` with reason), and when done (`in_progress` → `done` with link to artifact).
- Orchestrator reviews on every wake-up.
- Don't delete rows. Mark `skipped` if a stage is no longer needed and add a note.
