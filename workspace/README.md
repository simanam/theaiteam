# workspace/

Per-project shared state lives here. Each project gets a subdirectory: `workspace/<slug>/`.

When you run `/kickoff <slug>`, the orchestrator creates:

```
workspace/<slug>/
├── task-board.md             # single source of progress
├── plans/                    # PRD, system design, ADRs, decisions
├── handoffs/                 # one file per role-to-role handoff
├── artifacts/                # design, docs, qa, security, devops, marketing outputs
└── ingested/                 # repomix output if a target_repo was packed
```

## Gitignored

Everything inside `workspace/` (except this README) is gitignored. Per-project state is **not** part of theaiteam's source-of-truth — it's the working memory of a single project run.

If you want to keep a project's workspace under version control, do it inside the project's own repo (e.g., commit `workspace/myproject/plans/prd.md` into `~/code/myproject/.theaiteam/plans/prd.md`), not into theaiteam itself.

## Cleanup

You don't have to clean up old workspaces — they're useful reference for the next similar project. The orchestrator may eventually archive them under `workspace/_archived/<slug>.tar.gz` but never deletes outright.

See [orchestrator/workspace-protocol.md](../orchestrator/workspace-protocol.md) for the full file conventions.
