---
name: greenfield-feature
description: Build a new feature or service end-to-end from a brief.
type: workflow
triggers: [greenfield-feature]
roles: [product-manager, architect, backend-engineer, frontend-engineer, mobile-engineer, designer, qa-engineer, security-engineer, devops-engineer, technical-writer, marketing-strategist]
---

# Workflow — Greenfield Feature

## Stages

```
1. INTAKE              [PM]               sequential
2. DESIGN              [Architect]        sequential, after PM
3. IMPLEMENT           [BE ‖ FE ‖ Mobile ‖ Designer]   parallel, after Architect
4. TEST + REVIEW       [QA ‖ Security]    parallel, after each impl branch
5. RELEASE PREP        [DevOps ‖ TechWriter ‖ Marketing]   parallel, after QA + Sec sign-off
6. SHIP                [DevOps]           sequential, after Release Prep
7. POST-LAUNCH         [Marketing ‖ PM]   parallel, ongoing
```

## Stage 1 — Intake (PM, sequential)

- Read `briefs/<slug>.md`
- Produce `workspace/<slug>/plans/prd.md`
- Produce `workspace/<slug>/plans/stories.md` with acceptance criteria per story
- Recommend the role roster + workflow to the orchestrator
- Record decision #1 in `decisions.md`: scope and lead
- Handoff: `handoffs/pm-to-architect-1.md`

## Stage 2 — Design (Architect, sequential)

- Read PRD and stories
- If `target_repo` is set, run `tools/ingest.sh <target_repo>` and read the relevant slice
- Produce:
  - `workspace/<slug>/plans/system-design.md`
  - `workspace/<slug>/plans/api-spec.yaml`
  - ADRs for non-obvious choices in `workspace/<slug>/plans/adr/`
- Update task-board with engineering-ready stories
- Handoffs (parallel):
  - `handoffs/architect-to-backend-1.md`
  - `handoffs/architect-to-frontend-1.md` (if applicable)
  - `handoffs/architect-to-mobile-1.md` (if applicable)
  - `handoffs/architect-to-designer-1.md` (if applicable)
  - `handoffs/architect-to-security-1.md` (design-time threat model)

## Stage 3 — Implement (parallel)

Run in parallel. Each role works in its own slice and updates the task-board.

- **Backend Engineer**: implements per `api-spec.yaml`, writes tests, opens PRs
- **Frontend Engineer**: implements per design specs, wires API, writes tests, opens PRs
- **Mobile Engineer**: implements per platform, opens PRs
- **Designer**: produces UX flows, design system updates, mockup specs

Boundary check: don't merge any PR before Stage 4 sign-off.

## Stage 4 — Test + Review (parallel, gated)

- **QA Engineer**: writes Playwright (or platform-equivalent) E2E tests for the user flows. Creates `test-strategy.md`. Files bug reports for any acceptance criteria failure.
- **Security Engineer**: code-time review, finds vulnerabilities, writes findings to `security/findings.md`. Approves or blocks.

Both must sign off in the task-board before any PR merges to main.

## Stage 5 — Release prep (parallel)

- **DevOps Engineer**: deploys to staging, finalizes CI gates, writes runbook
- **Tech Writer**: writes/updates README, API docs, integration guide, changelog entry
- **Marketing Strategist**: produces positioning + launch kit (announcement, social, email)

## Stage 6 — Ship (DevOps, sequential)

- Production deploy with rollback documented
- Smoke tests pass in production
- DNS / domain final
- Status page updated if applicable
- Mark task-board: `shipped`

## Stage 7 — Post-launch (parallel, ongoing)

- **Marketing Strategist**: monitors launch metrics; iterates on copy/CTAs based on data
- **PM**: gathers user feedback, files follow-ups for next iteration
- Retro entry in `decisions.md`

## Failure modes

- Architect can't decide → escalate to user (via orchestrator)
- Security finds blocker post-impl → halt Stage 5, loop back to Stage 3
- Designer and Frontend disagree on a flow → PM arbitrates with the brief
- DevOps deploy fails → rollback per runbook, root-cause, redeploy

## Customization

- For pure-backend (no UI): drop frontend-engineer, designer, mobile-engineer
- For pure-iOS (no web): drop frontend-engineer
- For internal tooling (no marketing surface): drop marketing-strategist (still create internal launch doc)
