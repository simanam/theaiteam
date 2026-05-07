---
slug: omnilink-sprint-04.4-rate-limit-currentauth
type: greenfield-feature
priority: P2
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 4.4: Rate-Limit Middleware → CurrentAuth (G-027) + R-4.3-1 caplog quirk

## 1. Goal

Close two carry-forwards from Sprint 4.3:

- **G-027** (load-bearing): migrate the `rate_limit` factory's `_check` closure for `identifier_type="user"` from `_get_user` (JWT-only) to `get_current_auth` (the unified dispatcher, API-key compatible). Same shape as Sprint 4.2's OrgContext migration but in middleware. Closes the G-024-round-2 gap that surfaced mid-Sprint-4.3 Stage 3.
- **R-4.3-1** (low): investigate + fix the `omnilink.auth.disabled=True` test-context quirk that forced backend to add a defensive `logger.disabled = False` line in the Sprint 4.3 R-3 caplog test. Eliminate the defensive line; document the root cause.

After 4.4 ships, every endpoint in the product surface (including the 7 rate-limited `/billing/*` routes) supports API-key auth, AND the test infrastructure no longer carries cosmetic-but-puzzling defensive logger code.

## 2. Target users

- **AI-native + MCP partner integrations.** Partners that need programmatic billing access (subscription status, invoice lists, seat management) are currently blocked by 401 on every `/billing/*` route. G-027 unblocks them. No live consumer is hitting the wall today (zero `omni_` matches in `omnlink-frontend/` per Sprint 4.2 AC-422-9), but the marketing surface "every endpoint supports API-key auth" stays honest only after this lands.
- **Future test-author engineers.** R-4.3-1's defensive `disabled = False` line is a footgun — engineers reading the R-3 caplog test will see a cosmetic-looking `disabled = False` and either copy-paste it everywhere or remove it without understanding why. Eliminating the workaround removes the footgun.

## 3. Success criteria

- [ ] **G-027:** `rate_limit` factory's `_check` closure for `identifier_type="user"` swaps `Depends(get_current_user)` → `Depends(get_current_auth)`. Closure body reads `request.state.user_id` from the dispatcher's writes (Sprint 4.2 P2-H-01 fix already populates this). API-key requests no longer 401 on `/billing/*` rate-limited endpoints.
- [ ] **G-027 integration test:** API-key request with `manage_billing` scope hits a `rate_limit("manage_billing", identifier_type="user")`-protected endpoint (e.g., `POST /billing/portal`) → no longer 401. Acceptable downstream states: 200, 400 (no Stripe customer), 503 (Stripe not configured in test env), or 403 (role-based deny). NOT 401.
- [ ] **G-027 regression test:** existing JWT-path rate-limit tests (`test_rate_limit_regression.py`) still pass.
- [ ] **G-027 saturation tests:** Sprint 4.3's `test_rate_limit_saturation.py::test_secondary_cap_fires_on_single_api_key` + `test_primary_cap_fires_across_multiple_api_keys` still pass (they exercise `identifier_type="org"` which is already API-key compatible — sanity check that the `identifier_type="user"` migration doesn't break sibling identifier_type behaviors).
- [ ] **G-027 closed in `_team-gaps.md`** with `**Status:** closed-fixed-in-<sha>` + closure evidence.
- [ ] **R-4.3-1:** root cause of `omnilink.auth.disabled=True` under pytest test context identified + documented in `decisions.md` D-005 or a sprint-local ADR. Defensive `logger.disabled = False` line in `tests/integration/test_orgcontext_currentauth.py::test_get_campaigns_api_key_with_scope_returns_200` removed (assuming the root-cause fix doesn't require it).
- [ ] **R-4.3-1 closed:** removed line + replacement-or-justification committed; QA carry-forward in Sprint 4.3 D-006 marked closed.
- [ ] Final integration suite stays at **0 fail / 0 errors** with new tests added.
- [ ] Severity reaffirmed at PM Stage 1 (P2 or pushed back).

## 4. Stack and constraints

- **Languages / frameworks:** Python 3.12, FastAPI, SQLAlchemy 2 async, pytest, pytest-asyncio.
- **No new dependencies.**
- **Test DB:** local Postgres 16 via Docker (`omnilink-postgres-test`).
- **Test cache:** Redis 7 via Docker (`omnilink-redis`).
- **Hosting:** Railway prod via the standard ff-main-from-develop pattern.
- **Hard constraints:**
  - Sprint must keep the literal-zero CI gate (Sprint 4.2.1 baseline + Sprint 4.3 = 183 integration tests). New failures = stop-and-fix.
  - G-027 touches the auth boundary — full Phase 1 + Phase 2 security review (NOT lighter ceremony). Same gate-shape as Sprint 4.2 G-024.
  - No expansion of unrelated tech debt (e.g., the 1552-error lint baseline stays untouched).
- **Out of scope:**
  - F-2 / F-3 from Sprint 4.2 (multi-org JWT `scalar_one_or_none()` raise; `_resolve_jwt_org_and_perms` workspace asymmetry). Pre-existing; explicit non-goals.
  - Lint baseline (separate sweep).
  - Branded domains / OAuth flows (Sprint 16+ territory).
  - Sprint 5 enhanced event model — explicitly the NEXT sprint after this one ships.
  - Untracked `docs/plans/*` files in omnilink-backend (separate triage).
  - Wiring `require_scope` on additional endpoints (Sprint 5+ work).
  - Deeper structlog refactor — R-4.3-1 is investigation-and-minimal-fix only.

## 5. Deliverables

- [x] Working code (PR opened against `develop` from `feat/sprint-04.4-rate-limit-currentauth`).
- [x] Tests (G-027 needs JWT path regression + API-key positive on at least one `/billing/*` endpoint; sanity-check Sprint 4.3 saturation tests still pass).
- [ ] API documentation (no public OpenAPI shape change expected — verify at architect stage).
- [ ] User-facing docs.
- [x] System design doc / ADR (one ADR for the `_get_user` → `get_current_auth` migration shape; reuse Sprint 4.2 ADR pattern).
- [ ] UX flows / design mockups.
- [ ] Marketing kit.
- [x] Deployment runbook update if the migration reveals consumer wiring assumptions (none expected — no live API-key consumers on `/billing/*`).
- [x] Security review — Phase 1 + Phase 2 (full ceremony — touches the auth boundary).
- [x] Other: R-4.3-1 root-cause documentation (decisions.md D-NNN or sprint-local ADR).

## 6. Roles needed

- **Required:** product-manager (lead), architect (G-027 system design + ADR; R-4.3-1 investigation guide), backend-engineer (impl), qa-engineer (test review), devops-engineer (CI confirm + ship), security-engineer (Phase 1 + Phase 2, full ceremony — auth boundary).
- **Excluded:**
  - frontend-engineer — no UI change. Cross-repo gate analysis: G-027 changes 401 → other-status on `/billing/*` API-key requests; no live consumer hits this path today (zero `omni_` matches in `omnlink-frontend/` per Sprint 4.2 AC-422-9). Existing JWT consumers retain JWT path. Cross-repo gate (b) at Stage 5: PM at Stage 1 confirms scope; architect at Stage 2 documents; DevOps at Stage 5 either runs gate (b) (if any consumer might be affected) or marks "no consumer-impacting change" in the PR description checkbox.
  - mobile-engineer (no mobile).
  - designer (no design).
  - marketing-strategist (internal infra + auth-migration only; no externally-visible behavior change for end users).
  - technical-writer (no public docs unless OpenAPI surface materially changes).
- **Lead:** product-manager (Stage 1 confirms scope + severity + cross-repo gate posture + R-4.3-1 ownership).

## 7. Context and references

- **Predecessor:** Sprint 4.3 (`omnilink-sprint-04.3-cleanup-sweep`, shipped 2026-05-07 at `ca09e44`, PR [#10](https://github.com/simanam/OmniLink/pull/10)). Closed G-026 (analytics endpoint API-key migration); landed R-1..R-5; surfaced G-027 + R-4.3-1 mid-Stage-3.
- **Predecessor of predecessor:** Sprint 4.2.1 (`omnilink-sprint-04.2.1-test-baseline-fix`, shipped 2026-05-07 at `2c10376`). Closed G-019 + G-025; integration suite at literal zero; CI flipped to required gate.
- **Sprint 4.2** (`omnilink-sprint-04.2`, shipped 2026-05-06 at `1087852`). Closed G-024 (OrgContext → CurrentAuth migration). G-027 is the same-shape gap in middleware that escaped Sprint 4.2 ADR-0001's audit (which scanned endpoint signatures only).
- **Reference docs (read at PM Stage 1):**
  - [`_team-gaps.md` § G-027](../_team-gaps.md#gap-g-027--rate_limit-middleware-_get_user-sub-dep-jwt-only-g-024-round-2) — full G-027 evidence + proposed fix shape.
  - [`workspace/omnilink-sprint-04.3-cleanup-sweep/plans/decisions.md` D-005 + D-006](../workspace/omnilink-sprint-04.3-cleanup-sweep/plans/decisions.md) — origin of G-027 mid-Stage-3 finding + R-4.3-1 carry-forward.
  - [`workspace/omnilink-sprint-04.3-cleanup-sweep/artifacts/qa/test-review.md`](../workspace/omnilink-sprint-04.3-cleanup-sweep/artifacts/qa/test-review.md) — R-4.3-1 recommendation.
  - [`workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md`](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md) — original audit (which missed middleware closures).
  - [`omnilink-backend/app/middleware/rate_limit.py:268-440`](../../marketing_projects/omnilink-backend/app/middleware/rate_limit.py) — the `rate_limit` factory.
  - [`omnilink-backend/app/api/v1/endpoints/billing.py`](../../marketing_projects/omnilink-backend/app/api/v1/endpoints/billing.py) — 7 affected routes (lines 231, 308, 360, 437, 830, 898, 1039).
  - [`omnilink-backend/tests/integration/test_orgcontext_currentauth.py:212`](../../marketing_projects/omnilink-backend/tests/integration/test_orgcontext_currentauth.py) — R-3 caplog test with the defensive `disabled = False` line to investigate.
  - [`omnilink-backend/app/core/logging.py`](../../marketing_projects/omnilink-backend/app/core/logging.py) — structlog `configure_logging()` (likely culprit per QA hypothesis).
  - [`omnilink-backend/app/main.py:35`](../../marketing_projects/omnilink-backend/app/main.py) — `logging.basicConfig()` cold-start.
  - [`team/rules/common/git-workflow.md` § Cross-repo response-shape changes](../team/rules/common/git-workflow.md#cross-repo-response-shape-changes) — gate (b) protocol; G-027 likely DOES NOT trigger (no live API-key consumer on `/billing/*`).
- **Scope rationale:** Sprint 4.3 closed the analytics-endpoint auth-coverage gap (G-026) and landed test-quality recommendations. Sprint 4.4 closes the same-shape gap that escaped Sprint 4.2 ADR-0001's audit (middleware closures, not endpoint signatures), plus eliminates a small test-infra footgun (R-4.3-1). After 4.4, the auth-coverage story is fully aligned with the marketing surface.
- **Branching ground truth:** main = production deploy source; develop = integration trunk; PR targets develop, then ff main ← develop to release.
- **Single-dev mode rule:** Aman approves AND merges his own PRs but expects the diff narrated first.

## 8. Risks and unknowns

- **G-027 migration reveals a deeper rate_limit ↔ dispatcher ordering issue.** Probability: low (Sprint 4 P2-H-01 fix already populates `request.state.user_id` from the dispatcher; the rate_limit closure just needs to consume that instead of re-resolving via JWT-only `_get_user`). Impact: medium if it surfaces (could expand scope to ~3-4h). Mitigation: architect at Stage 2 audits the dispatcher → rate_limit closure ordering before backend implements. Hard 2h gate per story applies.
- **G-027 fix breaks a sibling `identifier_type` branch.** Probability: very low (the migration is scoped to the `user` branch; `org` / `workspace` / `ip` branches are untouched). Impact: medium if it surfaces. Mitigation: Sprint 4.3's `test_rate_limit_saturation.py` (which exercises `identifier_type="org"`) is the regression check; runs in Stage 4a.
- **R-4.3-1 root cause turns out to be deeper than a basicConfig × structlog interaction.** Probability: medium (the symptom is unusual; pytest's `_pytest.logging` plugin doesn't normally set `disabled=True`). Impact: low (we keep the defensive `disabled = False` line + improved comment if root cause requires more than a 30min fix). Mitigation: architect at Stage 2 names a 30min hard-cap on R-4.3-1 investigation; if the root cause isn't reachable in that budget, ship Sprint 4.4 with G-027 only and carry R-4.3-1 forward.
- **Cross-repo gate (b) reveals an unexpected API-key consumer on `/billing/*`.** Probability: very low (Sprint 4.2 AC-422-9: zero `omni_` matches in `omnlink-frontend/`; no MCP partners in flight). Impact: medium if surfaces. Mitigation: PM at Stage 1 verifies; DevOps at Stage 5 spot-checks (if no live consumer, mark the PR "no consumer-impacting change" in the cross-repo checkbox).
- **Severity reclassification gate:** if G-027 review reveals a real auth bypass / IDOR while migrating, treat as P1 immediately and re-scope.

## 9. Notes

- Sprint type: `greenfield-feature` (full chain, full Phase 1 + Phase 2 security ceremony — auth-boundary migration). Different from Sprint 4.3's lighter ceremony because every commit touches auth-boundary code (rate_limit middleware = auth dispatcher sub-dep).
- Branch: `feat/sprint-04.4-rate-limit-currentauth` off `develop`.
- Estimated effort: **2-3h** total. G-027 impl ~1h + tests ~30min + Phase 1/Phase 2 sec review ~30min + R-4.3-1 investigation ~30min = ~2.5h. Hard 2h gate per story (Sprint 4.2.1 + 4.3 pattern); if G-027 expands, surface and re-scope.
- Sequencing: this is the second cleanup pair iteration (Sprint 4.2.1 ↔ Sprint 4.3, then Sprint 4.4) before Sprint 5 (enhanced event model). After 4.4, auth-coverage story is fully aligned + Sprint 5 lands on a truly clean baseline.
- The 38 untracked `docs/plans/*` files in omnilink-backend are still parked — not in scope for 4.4 either. Standalone triage candidate.
- **R-4.3-1 carry-forward decision rule:** if the root cause is not reachable in a 30min investigation budget, R-4.3-1 stays open with the documented hypothesis (`structlog.configure_logging` × `basicConfig` cold-start interaction) + the defensive `disabled = False` line stays in the test with an enriched comment. G-027 ships either way.
- **Cross-repo gate posture (preview at brief-time):** G-027 likely qualifies for "no consumer-impacting contract change" per Sprint 4.2 AC-422-9 (zero `omni_` matches). PM at Stage 1 confirms; if confirmed, the PR description ticks the no-impact checkbox and gate (b) doesn't fire. If a live API-key consumer surfaces, Path B (Sprint 4.2 D-004 / Sprint 4.3 D-006 pattern) — post-ship verification — is the precedent.
