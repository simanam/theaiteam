---
slug: omnilink-sprint-04.2.1-test-baseline-fix
type: bug-fix
priority: P2
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 4.2.1: Test Baseline Fix (G-025)

## 1. Goal

Restore the omnilink-backend integration test suite to **0 failures, 0 errors** on `develop`-tip so we can flip the integration-tests CI job from "informational" back to "required gate." Today the suite has ~47 stale failures (25 failed + 22 errors) that have been masking real regressions across Sprint 4.x. The bit-rot started in the Sprint 4 commit range (`d73d63e..c188388`) and grew during 4.1 and 4.2.

This is bookkeeping infrastructure work, not feature work. It exists to remove the "baseline-diff posture" that Sprint 4.x has been operating under — where reviewers had to manually diff failing test counts to spot real regressions.

## 2. Target users

The team itself (every future Sprint 4.x / Sprint 5+ effort). Today reviewers — Aman in single-dev mode, plus the orchestrator at QA Stage 4a — manually diff "old failures vs new failures" to assert no Sprint-N-introduced regressions. That works until it doesn't. Sprint 4.2 nearly leaked +7 fresh `test_campaigns` failures because they were buried in the noise; only caught because the orchestrator was specifically watching the diff. Eventually one slips. After this sprint: one real number — 0 — and CI enforces it.

## 3. Success criteria

- [ ] `venv/bin/pytest tests/integration/ -q` returns **0 failed, 0 errors** on `develop`-tip.
- [ ] `venv/bin/pytest -q` (full suite, unit + integration) is also clean.
- [ ] CI integration-tests job in `.github/workflows/*.yml` is flipped from "informational" to "required gate" (job no longer marked `continue-on-error`, or PR check is now required).
- [ ] Root causes documented in `workspace/omnilink-sprint-04.2.1-test-baseline-fix/plans/decisions.md` — at least which schema/fixture/migration drift produced each failure cluster.
- [ ] Regression-prevention: at least one CI-level safeguard added that would have caught this (e.g., a `develop`-protection rule that requires green integration tests before merge).
- [ ] G-025 closed in `_team-gaps.md` with `**Status:** closed` + fixed-in commit reference.

## 4. Stack and constraints

- **Languages / frameworks:** Python 3.12, FastAPI, SQLAlchemy 2 async, pytest, pytest-asyncio
- **Test DB:** local Postgres 16 via Docker (`omnilink-postgres-test` container, already running)
- **Test cache:** Redis 7 via Docker (`omnilink-redis` container, already running)
- **Hosting:** N/A (test infrastructure only — no runtime impact)
- **Existing systems:** Alembic migrations, `tests/integration/conftest.py` (deep fixture wiring, see `_build_auth_context` and `rbac_setup`), the `auth_client` legacy fixture in `test_campaigns.py` carrying G-019 drift
- **Hard constraints:**
  - No production behavior change. This sprint touches tests + fixtures + (possibly) a migration backfill, never API contracts.
  - No new dependencies unless a fix unambiguously requires it (e.g., adding `pytest-randomly` — already proposed in Sprint 4.3 R-5 — would shift to that sprint).
  - The handoff's hard gate: **if bisect surfaces something bigger than 2h of work** (e.g., a missing migration that touches schema), **STOP and surface to user — don't expand scope.**
- **Out of scope:**
  - Refactoring tests for clarity / style.
  - Adding new test coverage (Sprint 4.3 R-1..R-5 owns net-new tests).
  - Fixing the lint baseline (1552-error pre-existing — separate concern).
  - Migrating the legacy `auth_client` fixture in `test_campaigns.py` (G-019 territory — separate sprint).
  - Touching the unit-test suite unless a fix bleeds in (focus is integration).

## 5. Deliverables

- [x] Working code (PR opened against `develop` from `fix/sprint-04.2.1-test-baseline`)
- [x] Tests (the existing tests start passing — no new tests as deliverables)
- [ ] API documentation
- [ ] User-facing docs
- [x] System design doc / ADR (ADR for any non-obvious root-cause finding; e.g., "fixture X depends on a migration that didn't backfill seed data")
- [ ] UX flows / design mockups
- [ ] Marketing kit
- [ ] Deployment runbook
- [ ] Security review (NOT TRIGGERED — see § 6)
- [x] Other: CI workflow config change (flip integration job to required gate)

## 6. Roles needed

- **Required:** product-manager (lead, triage + scope lock), backend-engineer (root-cause + fix), qa-engineer (regression catalog + verify clean baseline), devops-engineer (CI gate flip + ship)
- **Excluded:**
  - frontend-engineer (no UI)
  - mobile-engineer (no mobile)
  - designer (no design)
  - security-engineer (no auth/data/secrets/integration boundaries — Stage 4 security check NOT TRIGGERED per bug-fix workflow §Stage 4)
  - marketing-strategist (internal infra only)
  - technical-writer (no public-facing docs)
- **Lead:** product-manager (triage at Stage 1 to confirm severity + lock scope, especially the "STOP if >2h" gate)

## 7. Context and references

- **Predecessor handoff:** `workspace/_next-session-handoff.md` § Order of work — option C
- **Gap entry:** `_team-gaps.md` § G-025 — pre-existing test failures on omnilink-backend develop tip
- **Sprint 4 ship tip (where bit-rot started):** `c188388` on omnilink-backend
- **Sprint 4 baseline (last known good):** `d73d63e` on omnilink-backend
- **Bisect range:** `d73d63e..c188388` (per G-025 proposed fix)
- **Current `develop`-tip:** `8cf1d27` (Sprint 4.2 + chore PR #8)
- **Failure surface today** (per handoff observation; PM re-validates at Stage 1):
  - 25 failed + 22 errors in `tests/integration/`
  - Files: `test_campaigns.py`, `test_gs1.py`, `test_redirects.py`, `test_workspaces.py`, `test_workspace_members.py`, `test_rbac_matrix.py`, `test_health.py`
  - Likely 3–4 actual root causes underneath (per G-025 proposed fix)
- **Branching ground truth:** main = production deploy source; develop = integration trunk; PR targets develop, then ff main ← develop to release.
- **Two parallel envs:** develop branch → Railway dev → Neon dev branch; main branch → Railway prod → Neon prod branch.
- **Single-dev mode rule:** Aman approves AND merges his own PRs but expects the diff narrated first.

## 8. Risks and unknowns

- **Bisect surfaces a missing migration that needs schema work.** Hard gate: STOP and surface.
- **Bit-rot is broader than the bisect range.** Sprint 4.1 and 4.2 may have added new failures that aren't reachable by bisecting `d73d63e..c188388`. PM at Stage 1 validates the bisect range; if 4.1/4.2 commits are also implicated, expand the range or split into multiple bisects.
- **The pytest harness itself may be the issue** (test-DB schema drift, conftest fixture timing, async session bleed). Engineer at Stage 2 distinguishes "code/migration regression" from "harness regression" — they fix differently.
- **Truckers Routine prod-data risk:** the only paying customer. Truckers data lives only in prod; test DB has none. No risk to Truckers from any test-suite changes — but worth restating in plans/decisions.md to keep the institutional reflex sharp.
- **CI flip enforcement order:** flipping integration-tests to "required" before the suite is actually green will block all Sprint 4.3 PRs. Must flip AFTER the green baseline lands on develop.
- **Cross-repo gate:** none expected. This sprint touches no consumed endpoints. Default to "no consumer-impacting contract change" checkbox.

## 9. Notes

- Sprint type per workflow: `bug-fix` (lighter ceremony than `greenfield-feature`).
- Branch: `fix/sprint-04.2.1-test-baseline` off `develop`.
- Estimated effort: 1–2h to bisect + fix per the handoff's reading; could expand to 3–4h if root causes are independent and need separate fixes. PM at Stage 1 reaffirms the gate ("STOP if >2h surfaces").
- Sequencing context: this sprint blocks the literal-zero gate that Sprint 4.3 (option A) and Sprint 5 (option B) both inherit. Until this lands, those sprints continue under "baseline-diff posture" — workable but fragile.
- After this ship, the integration-tests CI job becomes load-bearing on every PR. Sprint 4.3 R-5 (`pytest-randomly`) becomes more impactful once this is green.
- Postmortem (Stage 6) is OPTIONAL per workflow — only required for P0/P1. P2 here. Recommend a brief post-ship "what allowed Sprint 4 to ship red?" note in `decisions.md` instead of a full postmortem doc.
