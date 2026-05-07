---
slug: omnilink-sprint-04.3-cleanup-sweep
type: greenfield-feature
priority: P2
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 4.3: Carry-Forward Cleanup Sweep

## 1. Goal

Land six discrete cleanup items: five test-quality / observability improvements (R-1..R-5) carried forward from Sprint 4.1 + 4.2 QA reviews, plus G-026 (migrate `GET /organizations/{id}/analytics` to API-key-compatible auth, deferred from Sprint 4.2 ADR-0001). Most work is non-auth-boundary; G-026 alone touches the auth dispatcher and triggers the cross-repo gate.

This is the second of the planned "cleanup → real work" pair sequenced in [`workspace/_next-session-handoff.md`](../workspace/_next-session-handoff.md) (option A; option C — Sprint 4.2.1 — shipped 2026-05-07 at `2c10376`). After 4.3, Sprint 5 (enhanced event model) becomes the next big-feature sprint with a clean baseline.

## 2. Target users

- **The team itself.** R-1..R-3 directly address gaps QA flagged in Sprint 4.2 review where the assertion paths were "indirect-by-baseline" rather than explicitly verified. R-5 (`pytest-randomly`) makes the now-literal-zero suite robust against order-dependent flakes.
- **AI-native + MCP partner integrations** (future). G-026 unblocks the canonical AI-native API-key use case (programmatic analytics access) named in the [OAuth + MCP roadmap](../../marketing_projects/omnilink-backend/docs/plans/oauth-and-mcp-roadmap.md). Until G-026 ships, every endpoint in OmniLink supports API-key auth EXCEPT analytics, which limits MCP tooling.

## 3. Success criteria

- [ ] **R-1:** new integration test exercises `OrgContext` membership-defense layer through a non-scope-gated endpoint; explicit 403 on the membership-miss path.
- [ ] **R-2:** AC-421-9 + AC-421-10 (cross-org defense + multi-org JWT users) have explicit assertions, not just "passing as a side effect of other tests."
- [ ] **R-3:** AC-402-6 (`auth.resolved` log emitted with correct shape) verified via `caplog` assertion in an integration test.
- [ ] **R-4:** Sprint 4.1 R1 saturation tests (AC-424-1 + AC-424-2) land; `api_key_setup` fixture extended with multi-key-per-org capability.
- [ ] **R-5:** `pytest-randomly` added to `requirements-dev.txt`; suite passes shuffled 3× at sprint start (catches order-dependent flakes that became visible post-4.2.1).
- [ ] **G-026:** `GET /organizations/{id}/analytics` migrated to `auth: CurrentAuth`; `Depends(require_scope("read:analytics"))` wired; integration tests cover JWT (200), API-key with scope (200), API-key without scope (403).
- [ ] Final integration suite stays at **0 fail / 0 errors** with new tests added.
- [ ] Cross-repo gate (b) clears for G-026: DevOps smokes the dashboard's existing JWT call to `/organizations/{id}/analytics` against the migrated backend before merge.
- [ ] G-026 closed in `_team-gaps.md` with `**Status:** closed` + fixed-in commit reference.

## 4. Stack and constraints

- **Languages / frameworks:** Python 3.12, FastAPI, SQLAlchemy 2 async, pytest, pytest-asyncio
- **New dependency:** `pytest-randomly` (R-5). Only addition this sprint. Vetted: widely used, MIT licensed, no transitive surprises.
- **Test DB:** local Postgres 16 via Docker (`omnilink-postgres-test`)
- **Test cache:** Redis 7 via Docker (`omnilink-redis`)
- **Hosting:** N/A for R-1..R-5; G-026 lands on Railway prod via the standard ff-main-from-develop pattern.
- **Hard constraints:**
  - Sprint must keep the literal-zero CI gate. New failures = stop-and-fix before continuing.
  - G-026 cross-repo gate (b) is a hard pre-merge requirement. Backend cannot ship without DevOps' smoke evidence.
  - No expansion of unrelated tech debt (e.g., the 1552-error lint baseline stays untouched).
- **Out of scope:**
  - Lint baseline (separate sweep).
  - Branded domains / OAuth flows (Sprint 16+ territory).
  - Sprint 5 enhanced event model — explicitly the NEXT sprint after this one ships.
  - Untracked `docs/plans/*` files in omnilink-backend (separate triage).

## 5. Deliverables

- [x] Working code (PR opened against `develop` from `feat/sprint-04.3-cleanup-sweep`)
- [x] Tests (R-1, R-2, R-3, R-4 are themselves new tests; G-026 needs JWT + API-key paths covered)
- [ ] API documentation (only if G-026 changes the public OpenAPI spec — verify at architect stage)
- [ ] User-facing docs
- [x] System design doc / ADR (one ADR for G-026's auth migration; reuse Sprint 4.2's pattern)
- [ ] UX flows / design mockups
- [ ] Marketing kit
- [x] Deployment runbook update if cross-repo gate (b) reveals dashboard wiring assumptions
- [x] Security review — Phase 1 + Phase 2 LIGHTER than full ceremony (most work is non-auth; security focus is G-026's auth-dispatcher migration only)
- [x] Other: `requirements-dev.txt` change for `pytest-randomly`

## 6. Roles needed

- **Required:** product-manager (lead), architect (G-026 system design + ADR), backend-engineer (R-1..R-5 + G-026 impl), qa-engineer (test review + regression catalog), devops-engineer (cross-repo gate (b) for G-026 + ship), security-engineer (Phase 1 + Phase 2, scoped to G-026's auth-boundary touch only)
- **Excluded:**
  - frontend-engineer (no UI in this sprint; cross-repo gate (b) is verifying the EXISTING dashboard JWT call still works, not new dashboard work)
  - mobile-engineer (no mobile)
  - designer (no design)
  - marketing-strategist (internal infra + auth-migration only)
  - technical-writer (no public docs unless G-026 changes OpenAPI surface materially)
- **Lead:** product-manager (Stage 1 confirms the 6-item scope, ACs, security-review trigger, and cross-repo gate ownership)

## 7. Context and references

- **Predecessor:** Sprint 4.2.1 (`omnilink-sprint-04.2.1-test-baseline-fix`, shipped 2026-05-07 at `2c10376`). Closed G-019 + G-025; integration suite at literal zero; CI flipped to required gate.
- **Predecessor of predecessor:** Sprint 4.2 (`omnilink-sprint-04.2`, shipped 2026-05-06 at `1087852`). Closed G-024 (OrgContext → CurrentAuth migration). G-026 was the deferred ADR-0001 follow-up.
- **Reference docs (read at PM Stage 1):**
  - [`workspace/omnilink-sprint-04.2/artifacts/qa/test-review.md`](../workspace/omnilink-sprint-04.2/artifacts/qa/test-review.md) § Recommendations — R-1..R-5 long-form rationale.
  - [`_team-gaps.md` G-026 entry](../_team-gaps.md#gap-g-026--analytics-endpoint-could-migrate-to-api-key-auth-but-deferred) — DEFER context + proposed fix shape.
  - [`workspace/omnilink-sprint-04.2/plans/decisions.md` D-004](../workspace/omnilink-sprint-04.2/plans/decisions.md) — full carry-forward list.
  - [`workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md`](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md) — original DEFER record for G-026.
  - [`omnilink-backend/app/api/v1/endpoints/organizations.py:707`](../../marketing_projects/omnilink-backend/app/api/v1/endpoints/organizations.py) — the analytics endpoint to migrate.
  - [`team/rules/common/git-workflow.md` § Cross-repo response-shape changes](../team/rules/common/git-workflow.md#cross-repo-response-shape-changes) — gate (b) protocol; G-026 triggers this.
- **Scope rationale:** Sprint 4.2.1 closed the test bit-rot. Sprint 4.3 closes the test *quality* gaps (assertion explicitness, coverage gaps, ordering robustness) AND the auth-migration coverage gap (G-026). After 4.3, every endpoint in the product surface speaks API-key auth, and the test suite has no known gaps.
- **Branching ground truth:** main = production deploy source; develop = integration trunk; PR targets develop, then ff main ← develop to release.
- **Single-dev mode rule:** Aman approves AND merges his own PRs but expects the diff narrated first.

## 8. Risks and unknowns

- **Cross-repo gate (b) reveals the dashboard's analytics call expects a different response shape after auth migration.** Probability: low (the migration is a strict superset; JWT path keeps working). Impact: medium if it surfaces. Mitigation: DevOps runs gate (b) BEFORE merge, not after; PR blocks if smoke fails.
- **`pytest-randomly` exposes order-dependent flakes.** Probability: medium (G-019 closure didn't audit for order dependency). Impact: low (just adds a few small fixture cleanups). Mitigation: budget 30min in R-5 for any flakes that surface; if more than ~3 surface, log a follow-up gap.
- **R-4's `api_key_setup` fixture extension introduces fixture coupling.** Probability: low. Impact: low. Mitigation: build the multi-key seeding as an opt-in mode (`reuse_existing_org=True`) rather than changing the default.
- **G-026 architect-stage discovery: the analytics endpoint depends on data-plane services that themselves use `CurrentUser`.** Probability: low (Sprint 4.2 ADR-0001 audited this). Impact: medium (could expand scope). Mitigation: hard gate at PM Stage 1 — re-confirm the migration is one-function as ADR-0001 suggests.
- **Severity reclassification gate:** if G-026 reveals a real auth bypass or IDOR while migrating, treat as P1 immediately and re-scope.

## 9. Notes

- Sprint type: `greenfield-feature` (full chain), but security ceremony is LIGHTER — only G-026 touches the auth boundary; R-1..R-5 are tests + dev tooling.
- Branch: `feat/sprint-04.3-cleanup-sweep` off `develop`.
- Estimated effort: 5–7h per the predecessor handoff; could expand to 7–10h if cross-repo gate (b) reveals an unexpected dashboard wiring.
- Sequencing context: this is the LAST cleanup sprint before "actual work with clean base" (per Aman's framing during Sprint 4.2.1). Sprint 5 (enhanced event model) follows.
- The 38 untracked `docs/plans/*` files in omnilink-backend are still parked — not in scope for 4.3 either. Can be addressed standalone whenever convenient.
