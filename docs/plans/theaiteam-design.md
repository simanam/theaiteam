# theaiteam — Design Plan

**Date:** 2026-05-03
**Status:** v0.1 — initial scaffolding

## Goal

A reusable AI workforce. Drop a project brief in `briefs/`, the orchestrator routes it to the right roles, and the team delivers code, docs, designs, and marketing assets end-to-end. Works with Claude Code, Codex CLI, or Gemini CLI without rewriting agents.

## Non-goals

- Not a runtime/platform — no daemon, no UI. Agents run inside the user's chosen AI CLI.
- Not Dify or LangGraph — we borrow concepts, not the engine.
- Not a "magic do-everything" — the brief still needs to be specific enough for an LLM to act on.

## Inspirations and what we took

| Source | Took | Skipped |
|---|---|---|
| [repomix](https://github.com/yamadashy/repomix) | CLI wrapper for repo ingestion (`tools/ingest.sh`) | None — it's a tool, not a pattern |
| [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Directory layout (`agents/`, `skills/`, `rules/`, `commands/`, `hooks/`), YAML frontmatter conventions, multi-language reviewer pattern | Project-specific skills, the continuous-learning extraction (too coupled to harness) |
| [Dify](https://github.com/langgenius/dify) | Concept of typed workflow nodes with sequential/parallel composition | Runtime, DB, web UI |
| [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) | superpowers (TDD), webapp-testing (Playwright), frontend-design, Trail of Bits security, internal-comms, brand-guidelines | Skills tightly bound to a single framework |
| [marketingskills](https://github.com/coreyhaines31/marketingskills) | Full marketing taxonomy (strategy, content, SEO, CRO, paid, growth, analytics) | Branding tied to the source author |

## Architecture

```
[brief.md] → orchestrator → workflow selection → role dispatch → workspace/<project>/
                                                                  ├── plans/
                                                                  ├── artifacts/{code,design,docs,marketing}/
                                                                  ├── task-board.md       (single source of progress)
                                                                  ├── handoffs/           (one file per handoff)
                                                                  └── ingested/           (repomix output for target repos)
```

### Source-of-truth + adapter pattern

The team is defined in plain markdown under [team/](../../team/). Adapters generate provider-specific configs:

- **Claude Code adapter** — symlinks `team/roles/` → `.claude/agents/`, `team/skills/` → `.claude/skills/`, `team/commands/` → `.claude/commands/`
- **Codex adapter** — concatenates `team/` into a single `AGENTS.md`
- **Gemini adapter** — writes `.gemini/config.yaml` referencing the same files

This gives portability without duplicating content.

### Roles (11)

PM, Architect, Backend, Frontend, Mobile, Designer, QA, Security, DevOps, Tech Writer, Marketing Strategist.

Each role file specifies: mission, responsibilities, default skills, inputs, outputs, handoffs, quality bar, anti-patterns.

### Skills (~80 total at full build)

Organized by domain under [team/skills/](../../team/skills/):
- engineering — TDD, code-review, debugging, refactoring, search-first, verification-loop
- architecture — system-design, api-design, data-modeling, tech-stack-selection
- product — prd-writing, user-story, customer-research, roadmap
- design — frontend-design, design-system, ux-flow
- qa — test-strategy, webapp-testing-playwright
- security — owasp-review, threat-modeling, static-analysis
- devops — ci-cd-setup, deployment, observability, infra-as-code
- docs — api-docs, readme-writing, changelog, runbook
- marketing — full taxonomy from marketingskills (strategy / content / seo / cro / paid-ads / growth / analytics)
- meta — repomix-ingest, handoff-protocol

### Orchestrator

Not a binary — it's a persona + protocol. Lives in [orchestrator/orchestrator.md](../../orchestrator/orchestrator.md). The protocol is:

1. **Parse brief** — read `briefs/<slug>.md`, extract goal/stack/constraints/deliverables
2. **Pick workflow** — match brief to a workflow in [team/workflows/](../../team/workflows/) (greenfield-feature, bug-fix, code-review-cycle, launch-prep)
3. **Initialize workspace** — create `workspace/<slug>/` with task-board.md from template
4. **Dispatch** — populate task board with role assignments, sequential where dependencies exist, parallel otherwise
5. **Coordinate** — agents update the task board as they go; orchestrator monitors and re-dispatches
6. **Ship** — when criteria met, hand off to DevOps + Tech Writer for release prep

### Workspace protocol

`workspace/<project>/` is the shared scratchpad. Every role reads from and writes to it. Conventions in [orchestrator/workspace-protocol.md](../../orchestrator/workspace-protocol.md). Gitignored at the team level — each project's workspace is its own git repo or directory.

## Build phases

- [x] **Phase 1 — Scaffold** (this commit): directory tree, foundation docs, brief template
- [ ] **Phase 2 — Roles**: 11 role files with full prompt content
- [ ] **Phase 3 — Skills**: ~30 highest-leverage skills (engineering 6, architecture 4, product 4, design 3, qa 2, security 3, devops 4, docs 4, marketing 10+, meta 2)
- [ ] **Phase 4 — Orchestrator**: orchestrator.md, routing.md, task-board template, workspace-protocol, 4 starter workflows
- [ ] **Phase 5 — Rules**: 6 common rules + 4 language packs
- [ ] **Phase 6 — Adapters**: working Claude Code + Codex sync scripts; Gemini stub
- [ ] **Phase 7 — Tools**: repomix wrapper, ingest script
- [ ] **Phase 8 — Example**: filled-in example brief + walkthrough

## Open questions deferred

- Hooks (auto-invoke on events) — Claude Code only; deferred until we have a concrete trigger we want to automate
- MCP servers — only wire in when a project actually needs one
- Cost/latency budgets per role — wait until we have telemetry from a real run

## Success criteria

You can drop a brief into `briefs/`, say `/kickoff <slug>`, and the team produces:
- A plan in `workspace/<slug>/plans/`
- Code in a target repo (or scaffolded under `workspace/<slug>/artifacts/code/`)
- Docs (README, runbook, API)
- Design artifacts (UX flow, mockup spec)
- A marketing kit (positioning, launch checklist, content brief)
- A task board showing every step that happened and why
