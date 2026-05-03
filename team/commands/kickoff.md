---
name: kickoff
description: Start a new project from a brief. Initializes the workspace, picks the workflow, dispatches first roles.
type: command
args: <brief-slug>
---

# /kickoff <brief-slug>

Become the orchestrator. Run the intake → plan → initialize → first dispatch sequence.

## Steps

1. Verify `briefs/<brief-slug>.md` exists. If not, list available briefs and stop.
2. Read the brief. Validate all required sections are present (frontmatter + goal + success criteria + stack + deliverables).
3. If the brief has gaps, ask the user one consolidated question listing every gap. Don't progress until answered.
4. Pick the workflow file from [team/workflows/](../workflows/) matching `type` in the brief frontmatter.
5. Create `workspace/<brief-slug>/` per [orchestrator/workspace-protocol.md](../../orchestrator/workspace-protocol.md):
   - Copy [orchestrator/task-board-template.md](../../orchestrator/task-board-template.md) to `workspace/<brief-slug>/task-board.md`
   - Replace `<project-slug>` with the actual slug
   - Pre-fill the stages from the workflow
   - Create the artifact subdirectories
   - Seed `plans/decisions.md` with the intake decision (workflow chosen + lead role)
6. If `target_repo` is set in the brief, run `tools/ingest.sh <target_repo> <brief-slug>` to pack the repo.
7. Write the first handoff packet: `workspace/<brief-slug>/handoffs/orchestrator-to-<lead-role>-1.md`. Include:
   - Goal of stage 1 from the workflow
   - Inputs (the brief + any reference docs)
   - Outputs expected
   - Quality bar
   - Time budget
8. Mark stage 1 `in_progress` on the task-board.
9. Hand off to the lead role: load their role file from `team/roles/<lead-role>.md` and act as them.

## Output

Tell the user:
- Which workflow you picked (and why if non-obvious)
- The role roster
- The first role being dispatched and what they're starting on
- A link to `workspace/<brief-slug>/task-board.md`

Then start working as the lead role. The orchestrator persona is paused until the lead role's first stage completes or escalates.

## Fail modes

- Brief missing → list `briefs/` contents, ask user to create
- Brief frontmatter malformed → quote the malformed line, ask for fix
- Workflow type unknown → list available workflows, ask user to pick or create
- Workspace already exists → ask: resume, archive-and-restart, or rename
