# theaiteam

A reusable, provider-agnostic AI team. Drop a project brief, get end-to-end delivery.

> **New here?** Start at [GETTING_STARTED.md](GETTING_STARTED.md) — 10-minute onboarding from "what is this?" to "running it on my own project."

## Roster (11 roles)

| Role | File | Owns |
|---|---|---|
| Product Manager | [team/roles/product-manager.md](team/roles/product-manager.md) | Brief intake, PRDs, prioritization, customer research |
| System Architect | [team/roles/architect.md](team/roles/architect.md) | System design, tech-stack picks, API contracts, data models |
| Backend Engineer | [team/roles/backend-engineer.md](team/roles/backend-engineer.md) | Server code, DB, integrations, performance |
| Frontend Engineer | [team/roles/frontend-engineer.md](team/roles/frontend-engineer.md) | Web UI, dashboards, client-side state |
| Mobile Engineer | [team/roles/mobile-engineer.md](team/roles/mobile-engineer.md) | iOS (Swift) + Android (Kotlin) apps and SDKs |
| Designer | [team/roles/designer.md](team/roles/designer.md) | UX flows, design systems, mockups, brand visuals |
| QA Engineer | [team/roles/qa-engineer.md](team/roles/qa-engineer.md) | Test strategy, automation (Playwright), regression |
| Security Engineer | [team/roles/security-engineer.md](team/roles/security-engineer.md) | OWASP review, threat models, static analysis |
| DevOps Engineer | [team/roles/devops-engineer.md](team/roles/devops-engineer.md) | CI/CD, infra, deploys, observability |
| Technical Writer | [team/roles/technical-writer.md](team/roles/technical-writer.md) | API docs, READMEs, runbooks, changelogs |
| Marketing Strategist | [team/roles/marketing-strategist.md](team/roles/marketing-strategist.md) | GTM, content, SEO, CRO, paid, analytics |

## Quickstart

```bash
# 1. Copy the brief template and fill it out
cp briefs/_template.md briefs/my-project.md
$EDITOR briefs/my-project.md

# 2. Sync team/ into your AI provider's expected location
./adapters/sync-all.sh

# 3. Open the project in Claude Code (or Codex / Gemini) and run:
#    /kickoff my-project
```

The orchestrator will:
1. Parse the brief and pick the right workflow
2. Create `workspace/my-project/` with a task board
3. Dispatch roles sequentially or in parallel as the workflow demands
4. Track progress, handoffs, and PRs in the task board

## Architecture

```
briefs/<project>.md  ─►  orchestrator  ─►  workflow  ─►  roles + skills  ─►  workspace/<project>/
                                                                              ├── plans/
                                                                              ├── artifacts/
                                                                              ├── task-board.md
                                                                              └── handoffs/
```

See [docs/how-it-works.md](docs/how-it-works.md) for the deep dive and [docs/plans/theaiteam-design.md](docs/plans/theaiteam-design.md) for the design rationale.

## Provider support

| Provider | Adapter | Status |
|---|---|---|
| Claude Code | [adapters/claude-code/](adapters/claude-code/) | Primary |
| OpenAI Codex CLI | [adapters/codex/](adapters/codex/) | Supported |
| Gemini CLI | [adapters/gemini/](adapters/gemini/) | Stub — extend as needed |

Source of truth is plain markdown in [team/](team/). Adapters translate it to each provider's expected format.

## License

Internal — Aman Singh.
