# Workspace protocol

The contract every role follows when reading from / writing to `workspace/<slug>/`.

## Layout

```
workspace/<slug>/
├── task-board.md                  # single source of progress (mandatory)
├── plans/
│   ├── prd.md                     # PM
│   ├── stories.md                 # PM
│   ├── decisions.md               # all roles, append-only
│   ├── system-design.md           # Architect
│   ├── api-spec.yaml              # Architect (OpenAPI)
│   └── adr/
│       └── NNNN-title.md          # Architect (numbered)
├── artifacts/
│   ├── code/                      # only if no target_repo; otherwise PRs go to target_repo
│   ├── design/
│   │   ├── ux-flows.md
│   │   ├── design-system.md
│   │   ├── mockup-specs.md
│   │   └── brand/
│   ├── docs/                      # drafts; published versions go to target_repo/docs/
│   ├── qa/
│   │   ├── test-strategy.md
│   │   ├── regression.md
│   │   └── bugs/
│   ├── security/
│   │   ├── threat-model.md
│   │   ├── findings.md
│   │   └── sign-off.md
│   ├── devops/
│   │   ├── observability.md
│   │   └── launch-checklist.md
│   ├── marketing/
│   │   ├── positioning.md
│   │   ├── launch-kit/
│   │   ├── content-briefs/
│   │   ├── seo-plan.md
│   │   ├── cro-recommendations.md
│   │   └── analytics-spec.md
│   └── screenshots/               # PR-bound visual evidence
├── handoffs/
│   └── <from>-to-<to>-<n>.md
├── ingested/                      # repomix output; per target repo
└── README.md                      # one-paragraph "what is this project?" — orchestrator seeds it
```

## File-write rules

1. **Never overwrite another role's file silently.** If you need to change someone else's artifact, write a handoff packet instead and have them do it (or have the orchestrator dispatch them).
2. **Append-only files**: `plans/decisions.md`, `task-board.md` (rows added/edited; never deleted unless skipped).
3. **Versioned files**: ADRs are numbered and immutable once landed; if you need to revise a decision, write a new ADR that supersedes it.
4. **Commit cadence**: roles working in `target_repo` commit on their own feature branches. The team-level workspace is filesystem-only (no git inside `workspace/`).

## Handoff packet format

`handoffs/<from-role>-to-<to-role>-<n>.md`:

```markdown
---
from: <role>
to: <role>
date: YYYY-MM-DD
n: <integer; increments per from→to pair>
---

# Handoff — <from> to <to>

## Context
What was just done and why.

## Inputs you should read
- workspace/<slug>/plans/prd.md
- workspace/<slug>/plans/system-design.md
- ...

## Goal
What you're being asked to deliver.

## Quality bar
What "done" looks like for this hop.

## Watch out for
Specific things that will trip you up. Edge cases. Open questions.

## Time budget
~X hours / sprints / etc.

## Linked stories
- S-001
- S-002
```

## Reading rules

- Always read `task-board.md` first when picking up a task — it has the latest status.
- Read your handoff packet next. If it references files, read those.
- Don't read the entire `ingested/` repomix output unless your task requires it. It's huge and will burn your context window.
- Use `tools/ingest.sh --include "<pattern>"` to re-ingest with a narrower scope if you need a focused view.

## Status updates

When you start work, edit task-board.md to mark your row `in_progress` and set `Started: YYYY-MM-DD`.
When you finish, mark `done`, set `Done: YYYY-MM-DD`, and add a link to your primary artifact in the row's "Notes" if needed.
When you hit a blocker, mark `blocked` and add a short blocker description plus the role you're waiting on.

## Cleanup

- Don't delete files in `workspace/<slug>/` even after the project ships. They're reference for the next similar project.
- The orchestrator may archive old workspaces by adding a top-level `_archived/` prefix and a tarball, but never deletes outright.
