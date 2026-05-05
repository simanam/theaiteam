---
slug: cross-repo-consumer-migration-rule
type: team-improvement
priority: P1
deadline: "before Sprint 4 kickoff"
target_repo: "/Users/amansingh/Documents/theaiteam"
ai_provider: claude-code
gap_id: G-020
---

# Improvement Brief — Cross-repo consumer migration rule

> An improvement brief is a project brief whose subject is **theaiteam itself**. The team-maintainer leads.

## 1. Goal

Add a rule (or extend an existing rule) so that any sprint that changes a response shape, status code, or breaking contract on an endpoint a consumer depends on cannot ship the backend until either:

- a parallel consumer-migration PR is co-deployed; OR
- a "consumer migration verified" gate is closed by manual confirmation against the consumer's prod build before backend ship.

This closes the process gap that caused the omnilink-sprint-02 dashboard regression on 2026-05-05 (~15.5h customer-facing outage on the dashboard list views).

## 2. Affected files / surfaces

- [team/rules/common/git-workflow.md](../team/rules/common/git-workflow.md) — add a new section `## Cross-repo response-shape changes` after the existing `## Pull Requests` section, OR extend the existing PR-review section.
- [team/rules/common/communication.md](../team/rules/common/communication.md) — possibly cross-link from the "in PRs" section.
- [team/workflows/](../team/workflows/) — consider if a workflow-level checklist is warranted (e.g. greenfield-feature workflow's PR-merge gate gets a new sub-step).
- Adapter outputs would refresh on `/sync` per existing process.

No effect on user-facing CLAUDE.md or README.

## 3. Success criteria

- [ ] The new rule is concrete and enforceable: it names the trigger ("response-shape, status-code, or breaking schema change on a consumed endpoint"), the gate ("either parallel consumer PR OR pre-ship manual smoke against consumer prod"), and the owner ("PM at PRD-time; DevOps at ship-time").
- [ ] At least one example of how to enforce it: e.g. a PR-description checkbox the reviewer ticks, or a sprint-level acceptance-criteria field the PM owns.
- [ ] If a non-trivial workflow change: the greenfield-feature workflow's role-mix doc is updated to flag when frontend-engineer must be in the mix (response-shape change implicates frontend by default).
- [ ] Cross-link from the relevant rule(s) to the omnilink-sprint-03 incident artifact for posterity.
- [ ] Validation suite passes (frontmatter, links, adapter sync).
- [ ] Cross-checked against omnilink-sprint-04's brief once it's drafted to confirm the rule actually catches the F-5 (per-user rate limit) work, which is also a backend-only sprint with potential consumer impact.

## 4. Roles needed

- **Required**: team-maintainer (default lead)
- **Reviewer**: product-manager (rule affects PRD-authoring practice) and devops-engineer (rule affects ship-gate practice)
- **Excluded**: all other roles unless the maintainer wants additional review

## 5. Risks

- **False positives:** the rule could fire on response-shape changes that have NO consumer (e.g. an internal-only endpoint), creating busywork. Mitigation: scope the rule to "endpoints a consumer depends on" — PM identifies in the PRD.
- **False negatives:** if a sprint's PRD doesn't accurately list consumed endpoints, the rule won't catch the leak. Mitigation: the rule names a default — "if you're not sure, treat the change as consumed" — and the maintainer audits PRDs periodically.
- **Process bloat:** adding more gates can slow shipping. Mitigation: the gate is "consumer migration verified" not "consumer migration PR open" — manual smoke is acceptable for tiny changes.

## 6. Out of scope

- A repo-wide consumer registry / dependency graph — too heavy for the current team size.
- Automated CORS / contract tests — would be a separate brief if Aman wants to invest.
- Backporting this rule to validate Sprint 1's ship (already shipped, no observed regression).

## 7. References

- Incident artifact: [workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md](../workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md)
- Decisions log: [workspace/omnilink-sprint-03/plans/decisions.md](../workspace/omnilink-sprint-03/plans/decisions.md) D-002c
- Sprint 2 PRD R2 (where the risk was named but had no enforcing mechanism): omnilink-backend `docs/plans/sprints/sprint-02-rbac-enforcement.md` and `workspace/omnilink-sprint-02/plans/prd.md`
- Hotfix PR: https://github.com/simanam/OmniLink-frontend/pull/1

## 8. Notes

The Sprint 2 PRD called this risk out (R2 in the PRD) but the team didn't operationalize the gate — frontend-engineer was excluded from the role mix because Sprint 2 was "backend-only," and there was no compensating mechanism for consumer migration. The rule should make that explicit: "if a sprint excludes frontend-engineer AND touches consumer-facing endpoint contracts, the PRD must specify the consumer migration plan."

Sprint 3 itself is also a candidate for this rule: it doesn't change response shapes on existing endpoints, but it introduces a new `X-Workspace-ID` header semantic. The PRD should specify whether the dashboard needs to start sending it (probably not in Sprint 3 per the brief's R3, but PM should make this explicit).
