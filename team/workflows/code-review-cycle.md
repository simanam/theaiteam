---
name: code-review-cycle
description: Independent multi-perspective review of an existing PR or branch.
type: workflow
triggers: [code-review-cycle]
roles: [architect, backend-engineer, frontend-engineer, mobile-engineer, security-engineer, qa-engineer]
---

# Workflow — Code Review Cycle

## Stages

```
1. INTAKE            [orchestrator]                       sequential
2. INGEST            [orchestrator]                       sequential
3. REVIEW            [Architect ‖ Engineer ‖ Security]    parallel
4. CONSOLIDATE       [orchestrator]                       sequential
5. AUTHOR RESPONDS   [original author]                    sequential
6. RE-REVIEW         [as needed]                          conditional
```

## Stage 1 — Intake

Brief should include:
- `target_repo`: the repo
- `pr_number` or `branch`: what to review
- `review_focus` (optional): "auth changes", "performance", "API design", "all"

If missing, escalate.

## Stage 2 — Ingest

- Run `tools/ingest.sh <target_repo> --include "<changed-files>"` to capture the PR slice
- Save to `workspace/<slug>/ingested/`
- Save the PR diff to `workspace/<slug>/ingested/diff.patch`

## Stage 3 — Review (parallel)

Three reviews run in parallel, no cross-contamination:

- **Architect**: high-level — does the change fit the system? Are abstractions right? Are contracts respected?
  - Skill: [architecture-decision-records](../skills/architecture/architecture-decision-records/SKILL.md) (if applicable)
  - Output: `workspace/<slug>/artifacts/qa/architect-review.md`

- **Engineer of domain** (backend / frontend / mobile based on changed files):
  - Skill: language-specific reviewer in [team/agents-extra/language-reviewers/](../../team/agents-extra/language-reviewers/)
  - Skill: [code-review](../commands/code-review.md)
  - Output: `workspace/<slug>/artifacts/qa/engineer-review.md`

- **Security Engineer**: OWASP review of the diff
  - Skill: [owasp-review](../skills/security/_trailofbits/) and the trailofbits security skills
  - Output: `workspace/<slug>/artifacts/security/findings.md`

Each review uses confidence-based filtering: only report findings ≥80% sure are real. Speculative concerns go in a separate "questions" section.

## Stage 4 — Consolidate (orchestrator)

- Merge the three review files into `workspace/<slug>/artifacts/qa/consolidated-review.md`
- Group findings by severity (CRITICAL / HIGH / MEDIUM / LOW / NIT)
- Deduplicate (multiple reviewers may flag the same line)
- Comment on the PR with the consolidated review

## Stage 5 — Author responds

- Author addresses each finding: fix, dispute (with reason), or defer (with ticket).
- Author updates the PR.

## Stage 6 — Re-review (conditional)

- If CRITICAL/HIGH findings: same reviewers re-check the changed sections
- If only MEDIUM/LOW: orchestrator can sign off without re-review

## Quality bar

- No CRITICAL or HIGH findings outstanding at merge
- Every finding has a status: fixed | accepted-with-reason | deferred-to-ticket
- Author understands every reviewer's point — no silent ignores
