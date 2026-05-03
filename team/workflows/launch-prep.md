---
name: launch-prep
description: Get an already-built feature ready to ship publicly — infra, security, docs, marketing.
type: workflow
triggers: [launch-prep]
roles: [devops-engineer, security-engineer, qa-engineer, technical-writer, marketing-strategist, product-manager]
---

# Workflow — Launch Prep

## Preconditions

Before a launch-prep brief is accepted:
- Feature code is on main, CI green
- QA has signed off on acceptance criteria for all stories
- A target launch date exists in the brief

If any precondition fails, the orchestrator returns the brief and asks PM to address it first.

## Stages

```
1. KICKOFF             [PM]                                       sequential
2. PARALLEL TRACKS:
   2a. INFRA + DEPLOY   [DevOps]                                  parallel
   2b. SECURITY AUDIT   [Security]                                parallel
   2c. QA SOAK          [QA]                                      parallel
   2d. DOCS             [TechWriter]                              parallel
   2e. MARKETING        [Marketing]                               parallel
3. GO/NO-GO            [PM ‖ user]                                sequential
4. LAUNCH              [DevOps]                                   sequential
5. POST-LAUNCH WATCH   [DevOps ‖ Marketing ‖ PM]                  parallel, time-boxed
```

## Stage 1 — Kickoff (PM)

- Confirm scope: what's launching, what's not
- Set the date and the GO/NO-GO criteria
- Notify all roles of their tracks via task-board

## Stage 2a — Infra + Deploy (DevOps)

- Production environment provisioned and verified (or staging promoted)
- Rollback verified (run a rollback drill in staging)
- Observability live: dashboards, alerts, on-call paged once to verify
- Cost estimates documented and signed off
- DNS / TLS / domains configured
- Output: `workspace/<slug>/artifacts/devops/launch-checklist.md`

## Stage 2b — Security audit (Security)

- Re-run static analysis on the launch-tagged commit
- Verify pre-launch checklist (auth, authz, secrets, logging, rate limiting, dep CVEs)
- Skim PRs that landed since last review for new attack surface
- Output: `workspace/<slug>/artifacts/security/sign-off.md` (must be signed)

## Stage 2c — QA soak (QA)

- Run full E2E suite against the production environment (or production-mirror)
- Smoke tests scheduled to run post-deploy automatically
- Regression suite green
- Edge cases re-verified manually
- Output: `workspace/<slug>/artifacts/qa/launch-soak.md`

## Stage 2d — Docs (Tech Writer)

- README updated with latest features and quickstart
- API docs current — every endpoint accurate
- Changelog entry for the launch
- Migration guide if there's a breaking change
- Public docs deployed to docs site / portal
- Output: `workspace/<slug>/artifacts/docs/launch-docs-checklist.md`

## Stage 2e — Marketing (Marketing Strategist)

- Positioning doc finalized (what this is, who it's for, why now)
- Launch kit:
  - Long-form announcement (blog or release note)
  - Social copy: LinkedIn, X, Threads, IG (per channel mix in the brief)
  - Email to existing users (if applicable)
  - ProductHunt / HN / industry-pub draft (if applicable)
  - Internal training / FAQ doc
- Analytics events specified and verified firing
- Output: `workspace/<slug>/artifacts/marketing/launch-kit/`

## Stage 3 — GO/NO-GO

- PM gathers each track's sign-off from the task-board
- Surfaces to user: GO / NO-GO with the reasons
- User has final call

## Stage 4 — Launch (DevOps)

- Execute the deploy
- Monitor dashboards for the first 60 minutes
- Smoke tests pass
- Post-launch announcements go live (Marketing pushes the button)

## Stage 5 — Post-launch watch (parallel, 72h)

- **DevOps**: monitor error rates, latency, costs. Page on anomaly.
- **Marketing**: track launch metrics (signups, traffic, conversions). Iterate copy/CTA based on what's converting.
- **PM**: collect user feedback. Catalog bugs into `bug-fix` briefs.

After 72h, write retro entry in `decisions.md`. Workflow closes.

## Failure modes

- Security signs off but a CVE drops in a dependency same week → patch + re-review before launch
- Marketing launch kit isn't ready → push date 1 week or launch quietly with marketing trailing
- Production deploy reveals a regression → rollback per runbook; treat as P0 bug-fix
