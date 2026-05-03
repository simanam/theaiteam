---
name: bug-fix
description: Triage, root-cause, fix, regression-test, ship a bug.
type: workflow
triggers: [bug-fix]
roles: [product-manager, backend-engineer, frontend-engineer, mobile-engineer, qa-engineer, security-engineer, devops-engineer]
---

# Workflow — Bug Fix

## Stages

```
1. TRIAGE            [PM]                                      sequential
2. ROOT CAUSE        [engineer-of-domain]                      sequential
3. FIX + TEST        [engineer ‖ QA writes regression test]    parallel
4. SECURITY CHECK    [Security]                                conditional
5. SHIP              [DevOps]                                  sequential
6. POSTMORTEM        [PM ‖ engineer]                           if severity high
```

## Stage 1 — Triage (PM)

- Read `briefs/<slug>.md` (the bug report)
- Reproduce per the steps. If can't reproduce, ask reporter for a clearer repro before progressing.
- Classify severity:
  - **P0**: data loss, broken auth, broken billing, full outage
  - **P1**: critical flow degraded, workaround painful
  - **P2**: minor flow broken, workaround easy
  - **P3**: cosmetic, edge case
- Identify domain: backend / frontend / mobile / infra
- Update task-board, handoff to engineer of domain

## Stage 2 — Root cause (engineer)

- Skill: [systematic-debugging](../skills/engineering/systematic-debugging/SKILL.md)
- Find the actual cause, not just the symptom. Write it in the PR description.
- If root cause reveals a wider class of bugs, escalate to PM (scope check).

## Stage 3 — Fix + regression test (parallel)

- **Engineer**: implements the fix on a fresh branch. Skill: [test-driven-development](../skills/engineering/test-driven-development/SKILL.md) — write the failing test first, then fix.
- **QA**: adds the same scenario to the regression catalog. Creates `regression.md` entry.

Engineer's PR includes both the fix and the test.

## Stage 4 — Security check (conditional)

If the bug touched auth, authorization, data validation, secrets, or external integrations:
- Security engineer reviews the fix
- Confirms no related vulnerabilities exist
- Adds finding to `security/findings.md` if a class-of-bug emerged

## Stage 5 — Ship (DevOps)

- Deploy following the standard release runbook
- Verify in production with the original repro steps
- Notify reporter (if external)
- Update changelog: `Fixed: <user-facing description>`

## Stage 6 — Postmortem (P0/P1 only)

- Within 48h of P0/P1 ship:
- PM authors `workspace/<slug>/plans/postmortem.md`: timeline, impact, root cause, contributing factors, what we'll change
- Add a regression test if not already present
- Update runbooks if alerting failed to catch this

## Failure modes

- Can't reproduce → bounce to reporter; close as "needs more info" if no response in N days
- Fix introduces new failure → revert, retry, learn
- Postmortem finds a systemic issue → file a follow-up brief for `refactor`
