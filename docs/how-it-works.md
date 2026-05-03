# How theaiteam works

## The 30-second version

```
You write a brief.            briefs/<slug>.md
   ↓
Orchestrator reads it.        orchestrator/orchestrator.md
   ↓
It picks a workflow.          team/workflows/*.md
   ↓
Roles are dispatched.         team/roles/*.md  (some sequential, some parallel)
   ↓
Each role uses skills.        team/skills/**/*.md
   ↓
All shared state lives in     workspace/<slug>/
   ↓
PRs get opened, docs get written, marketing assets ship.
```

## The brief

A structured markdown file in `briefs/`. The template ([briefs/_template.md](../briefs/_template.md)) asks for: goal, target users, stack, constraints, deliverables, success criteria, deadline, target repo (if any).

Briefs should be specific. "Build me Twitter" produces noise. "Build a /api/links endpoint that creates short URLs, validates the destination, and writes to PostgreSQL — see attached spec" produces work.

## The orchestrator

A persona, not a process. When you invoke `/kickoff <slug>` (or read [orchestrator/orchestrator.md](../orchestrator/orchestrator.md) and act as it manually), the active AI session takes on the orchestrator role. It:

1. Loads `briefs/<slug>.md`
2. Picks a workflow from [team/workflows/](../team/workflows/) based on the brief's `type` field
3. Creates `workspace/<slug>/` with subdirs and a `task-board.md` from the template
4. Lists tasks with assigned roles, dependencies, and status
5. Dispatches the first batch (sometimes one role, sometimes several in parallel)

## Roles

Each role file is a prompt that turns the active session into that specialist. A role file contains:

- **Mission** — what they exist to do
- **Responsibilities** — bulleted list of owned outputs
- **Default skills** — which skills under [team/skills/](../team/skills/) they reach for
- **Inputs** — what they expect on their desk
- **Outputs** — what they produce, and where it goes in `workspace/`
- **Handoffs** — who picks up next
- **Quality bar** — what "done" means for them
- **Anti-patterns** — what to refuse or push back on

Roles do NOT delegate to each other directly. They write a handoff file and update the task board; the orchestrator picks up the next role.

## Skills

A skill is a reusable workflow snippet. Examples: TDD loop, OWASP API review, PRD-writing, schema-markup, cold-email-sequence. Skills are domain-organized in [team/skills/](../team/skills/) and any role can use any skill — the role file lists its defaults but isn't restricted.

Each skill has frontmatter (`name`, `description`, `when-to-use`, `related-skills`) and a body of steps/checklist/examples/pitfalls.

## Rules

[team/rules/common/](../team/rules/common/) are always-follow guidelines (coding style, git workflow, testing rigor, security baseline, doc standards, communication norms). [team/rules/languages/](../team/rules/languages/) layers in language-specific norms (TypeScript, Python, Swift, Kotlin).

Rules apply to every role. Skills are opt-in.

## Workflows

Multi-step pipelines composed of role dispatches. A workflow file says "for a brief of type X, run these stages in this order, with these parallelism boundaries." Initial workflows:

- **greenfield-feature** — PM → Architect → (Backend ‖ Frontend ‖ Designer) → QA → Security → DevOps → Tech Writer → Marketing
- **bug-fix** — PM (triage) → Engineer (root cause + fix) → QA (regression test) → DevOps (deploy)
- **code-review-cycle** — Architect (high-level) ‖ Engineer-of-domain ‖ Security → consolidated comments
- **launch-prep** — DevOps (infra check) ‖ Security (audit) ‖ Tech Writer (docs) ‖ Marketing (launch kit) → Founder sign-off

## Workspace

`workspace/<slug>/` is the shared filesystem state for one project. Conventions:

- `task-board.md` — single source of truth for progress. Roles update it before handing off.
- `plans/` — per-project plans (PRDs, system design, sprint plans)
- `artifacts/code/` — scaffolded code if not in a target repo
- `artifacts/design/` — UX flows, design specs, image references
- `artifacts/docs/` — generated docs awaiting publication
- `artifacts/marketing/` — positioning, content briefs, launch kits
- `handoffs/<from>-to-<to>-<n>.md` — explicit handoff packets between roles
- `ingested/` — repomix output if we ingested a target repo

## Provider portability

[team/](../team/) is plain markdown. Adapters in [adapters/](../adapters/) generate the provider-specific surface:

- **Claude Code**: symlinks roles → `.claude/agents/`, skills → `.claude/skills/`, commands → `.claude/commands/`
- **Codex**: concatenates everything into `AGENTS.md`
- **Gemini**: stub — extend as needed

You author once in `team/`. Run `./adapters/sync-all.sh` to refresh the per-provider configs.

## What this is NOT

- Not a runtime — your AI CLI is the runtime
- Not a tool registry — skills are prompts, not executables
- Not a memory system — the workspace is per-project; long-term memory belongs to the AI provider's own memory
- Not a replacement for human judgment — the orchestrator escalates ambiguity back to you
