---
slug: omnilink-sprint-06-conversion-userid
type: greenfield-feature
priority: P1
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 6: Conversion Model + UserIdentity (Phase 2 — Tracking Loop, closes the click→conversion half)

> **Source-of-scope:** [`omnilink-backend/docs/plans/sprints/sprint-06-conversion-userid.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-06-conversion-userid.md). This brief synthesizes that doc; **the canonical plan is the source of truth at PM Stage 1** for ticket-level acceptance criteria (tickets 6.1–6.13).

## 1. Goal

Close the click → conversion loop. Idempotent `POST /api/v1/conversions` endpoint with three matching paths (click_id / visitor_id / user_id). Cross-device chain via `UserIdentity`. GDPR right-to-erasure operational. Consent flag honored end-to-end (click capture → conversion attribution).

Outcome at sprint end: a vendor (Truckers Routine; future GlowUp-style integrators) can call `POST /api/v1/conversions` with any of three matching paths. Replays are idempotent (24h Redis-keyed). Cross-device works when integrator supplies authenticated user_id. Right-to-erasure (`DELETE /api/v1/visitors/{id}` + `/users/{id}`) wipes PII across all registered tables in <5 min via ARQ. Inference (Sprint 8) and Analytics (Sprint 7) can both read full attribution.

## 2. Target users

- **Truckers Routine** (paying customer, immediate consumer of the new endpoints) — first integrator to call `POST /conversions`. Their backend will report signups/installs against the omni_ref click chain captured in Sprint 5.
- **Future agency integrators** (GlowUp-pattern wedge) — same conversion endpoint, three matching paths cover web→web, app→app, cross-device.
- **Sprint 7 (Composable analytics)** — joins Conversion ↔ Event by `(visitor_id, target_id, time-window)` to surface revenue-per-campaign.
- **Sprint 8 (Inference Tier 1+2)** — reads conversion history to weight which campaign to suggest.
- **Sprint 12 (MCP write tools)** — wraps `POST /conversions` in a `track_conversion` MCP tool (stub registered this sprint, ticket 6.12).
- **Sprint 18 (Client portal)** — surfaces real conversion data to end-customer dashboards.
- **Sprint 23 (iOS SDK)** — uses Path 2 (`visitor_id`) and Path 3 (`user_id`) for app-side conversion reporting.

## 3. Success criteria

Headline criteria only. PM Stage 1 expands to per-ticket ACs in `stories.md` sourced from canonical sprint plan tickets 6.1–6.13.

- [ ] **Conversion model** lands per canonical 6.1 schema: `Conversion` table with FK chain to events/campaigns/short_links/placements (all SET NULL), `visitor_id`, `user_identity_id`, `event_name`/`event_value`/`currency`/`metadata`, `attribution_type` enum (default LAST_CLICK), `idempotency_key`/`client_event_id`, `consent_state` (granted/denied/unknown). Unique constraints on `(workspace_id, idempotency_key)` and `(workspace_id, client_event_id)`.
- [ ] **`UserIdentity` model** lands per 6.8 schema: hashed `integrator_user_id_hash` (workspace-salted, never plaintext), `visitor_ids` ARRAY with GIN index, unique `(workspace_id, integrator_user_id_hash)`.
- [ ] **One Alembic migration** for both tables (no-migration rule still active per [SESSION-BOOTSTRAP decision #5](../../marketing_projects/omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md)).
- [ ] **`POST /api/v1/conversions`** endpoint: validates ≥1 of {click_id, visitor_id, user_id}; idempotency check returns cached response with `X-Idempotent-Replay: true`; resolves attribution via three-path service; creates Conversion row; if `user_id` supplied, links to UserIdentity (creates if needed) with collision detection; returns Conversion details. Rate limit 500/min/workspace.
- [ ] **Idempotency layer**: Redis-backed, key `idempotency:conversions:{workspace_id}:{key}`, 24h TTL, race-safe via SET NX. Same key replay → identical response, no DB write.
- [ ] **Three matching paths**: click_id direct match (404 if not in workspace); visitor_id 30d lookback (None-tolerant — conversion still logged); user_id cross-device chain via UserIdentity.
- [ ] **`omni_ref` append on redirect**: Sprint 5's redirect handler appends `&omni_ref=evt_<event_id>` to destination URL pre-307. Skip if `&no_track=1`. Skip if `Event.consent_state == "denied"`.
- [ ] **Consent flag honored end-to-end**: `?consent=denied` click → Event with no PII (`visitor_id`/`ip_hash` blanked); subsequent conversion → metadata stripped. **Fail-closed when no Event found**: `consent_state="unknown"` is treated identically to denied (metadata `{}`, no ip_hash, no audit raw payload). Documented in API docs.
- [ ] **Cross-device chain**: first user_id call creates UserIdentity + appends current visitor_id; subsequent calls union visitor_ids and back-attribute past Conversions. **Visitor-ID collision detection** before append: if visitor_id already in another UserIdentity in same workspace, do NOT link retroactively (kiosk/family iPad case); log `attribution_collision` metric; forward-only attribution; document limitation in API docs.
- [ ] **Right-to-erasure** (`DELETE /api/v1/visitors/{visitor_id}` + `DELETE /api/v1/users/{integrator_user_id}`): behind `manage_workspace` permission; ARQ async job iterates explicit `app/services/privacy.py:ERASURE_TABLES` registry (initial: events nullify visitor_id/ip_hash/user_agent; conversions nullify visitor_id/idempotency_key + drop metadata to `{}`); aggregate counts unchanged; audit log entry; returns 202 + job_id; processes within 5 min.
- [ ] **Future-proof erasure registry**: unit test that scans models for any column named `visitor_id`/`ip_hash` and asserts coverage in `ERASURE_TABLES` — fails CI if a future sprint forgets (Sprint 8 InferenceLog, Sprint 21 webhook history, Sprint 12 Tier-3 cache, etc.).
- [ ] **MCP `track_conversion` tool stub** at `app/mcp/tools_stub.py` (raises NotImplementedError; documents the Sprint 12 surface).
- [ ] **Tests**: all 3 matching paths; idempotency replay (same/different key, race-free concurrent); cross-device chain happy + collision; consent denied + unknown; right-to-erasure; rate limit. Coverage on new services ≥ 70%; on conversion resolution + idempotency ≥ 85% (high-traffic path).
- [ ] **End-to-end smoke** (canonical doc happy path): `omny.link/glowup/blog?utm_source=blog` → Event w/ omni_ref appended → `glowup.com?omni_ref=evt_abc` → `POST /conversions { click_id, event_name:"signup", user_id:"u_123" }` → Conversion + UserIdentity → second device same user_id w/ "purchase" → both visitor_ids linked.

### Sprint 5 carry-forwards — IN SCOPE FOR SPRINT 6

These three items were enumerated as Sprint 5 closeout carry-forwards (D-007 in [`workspace/omnilink-sprint-05-enhanced-event/plans/decisions.md`](../workspace/omnilink-sprint-05-enhanced-event/plans/decisions.md)) and ride along with conversion work to avoid spinning a separate hygiene sprint:

- [ ] **F-P2-1 (P2, ~5 min)**: Append `"salt"` to `app/core/logging.py::SCRUB_PATTERNS`. No log site currently leaks the salt VALUE — this is regression-protection for future code that handles `Workspace.visitor_salt`. Source: [`workspace/omnilink-sprint-05-enhanced-event/artifacts/security/findings.md` § Phase 2](../workspace/omnilink-sprint-05-enhanced-event/artifacts/security/findings.md).
- [ ] **F-P2-2 (P2, ~2–3h)**: Sanitize SQL exception text in `click_logging_failed` log site so raw `user_agent` / `referer` values from `IntegrityError`/`DataError` messages don't appear in `exc_info=True` tracebacks. Pre-existing pre-Sprint-5 surface; Sprint 5 didn't add raw-PII columns to it. Pattern: wrap exception in `sanitize_for_log` or scrub before logging. Same fix shape will be needed by Sprint 7's salt-rotation cron (F-P1-5) — this sprint establishes the pattern.
- [ ] **BuildKit secrets (P3 hardening, ~3–4h OR doc-as-accepted)**: Migrate Railway/Nixpacks `ARG`/`ENV` env-var injection to Docker BuildKit `--mount=type=secret` pattern, OR document explicit acceptance with risk sign-off. Surfaced via every Sprint 5 prod build emitting `SecretsUsedInArgOrEnv` warnings for `MAXMIND_LICENSE_KEY` + 7 other pre-existing keys. See [Railway/Nixpacks ARG-secret memory](../../.claude/projects/-Users-amansingh-Documents-theaiteam/memory/project_omnilink_railway_buildkit_secrets.md). DevOps Stage 5 picks fix vs accept.

## 4. Stack and constraints

- **Languages / frameworks:** Python 3.12 / FastAPI / SQLAlchemy 2.x async / Pydantic v2 / Postgres 16 (Neon) / Redis 7 (Upstash) / ARQ for async erasure jobs. No new runtime deps expected — ARQ already used in repo (verify at PM Stage 1).
- **Hosting:** Railway prod (api.omny.link / go.omny.link) on `main`; Railway dev on `develop`. Two parallel envs per [project memory](../../.claude/projects/-Users-amansingh-Documents-theaiteam/memory/project_omnilink_environments.md).
- **Existing systems Sprint 6 inherits from Sprint 5** (DO NOT re-debate without explicit user instruction):
  - `Event.visitor_id` is `vid_<sha256-32-hex>` (real) OR `vid_anon_<urandom-32-hex>` (anon fallback). Conversion-matching MUST handle both shapes; anon vids lose cross-device potential by definition. Sprint 7 analytics filters `WHERE visitor_id NOT LIKE 'vid_anon_%'` for "true unique."
  - `Workspace.visitor_salt` is per-workspace + rotates quarterly. Conversions match on visitor_id only — never on salt. Salt never crosses any API boundary.
  - Sprint 5 dedup is **request-level** (5s SETNX window on `sha256(visitor_id+target+path+ip_hash)`). Sprint 6 idempotency is **conversion-level** (`Idempotency-Key` header / `client_event_id` body, 24h TTL). Different scopes; PM Stage 1 confirms PRD documents the distinction.
  - `Event.short_link_id` populated FK (Sprint 5 S-5.1). Conversion attribution can join via short_link_id for ShortLink-scoped conversions.
  - `Event.utm_*` (5 cols) stored (Sprint 5 S-5.7). Conversions attribute back to UTM by Event join.
  - `Event.inference_id` ships in Sprint 5 as a column with no FK; Sprint 8.1 wires the FK + populates it. **Sprint 6 ignores this column entirely** (don't read, don't write).
  - GeoIP delivery is build-into-image via Nixpacks (ADR-0005). Sprint 6 endpoints do NOT need to touch MMDB; reuse `app/services/geoip.py::lookup_city` if needed.
- **Auth posture:** Conversion endpoints consume `auth: CurrentAuth` (NOT `current_user: CurrentUser`) per [Sprint 4.2 ADR-0001](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md) — API keys (omni_*) and JWT are both valid; integrator backends use API keys.
- **Permissions:** `manage_workspace` for `DELETE /visitors/*` and `DELETE /users/*` (right-to-erasure is destructive — owner-tier action).
- **No-migration rule** still active. Drop test data freely; no backfill choreography.
- **Hard constraints:**
  - Idempotency layer race-safety: Redis SET NX OR Postgres unique constraint on `(workspace_id, idempotency_key)` — both. Belt and suspenders since concurrent identical requests must be safe.
  - PII: integrator_user_id is hashed with workspace salt before storage. Plaintext never persisted. Email-as-user_id is the common pattern; this constraint is non-negotiable.
  - Right-to-erasure SLO: ≤5 min from request to all-tables-cleansed.
  - **Cross-repo posture: NEW endpoints, ASSUMED CONSUMED.** This sprint introduces `POST /api/v1/conversions`, `DELETE /api/v1/visitors/{id}`, `DELETE /api/v1/users/{id}`, plus the omni_ref redirect-side change. Truckers Routine will be the immediate consumer of `POST /conversions`. Per [`team/rules/common/git-workflow.md` § Cross-repo response-shape changes](../team/rules/common/git-workflow.md#cross-repo-response-shape-changes), the default is "treat as consumed." Architect Stage 2 documents the consumer contract; PM Stage 1 names the gate (default: gate (b) manual smoke pre-ship via DevOps, since Truckers' integration is owned by Aman, not a separate frontend repo).
- **Out of scope:**
  - Sprint 7's composable analytics endpoint that exposes Conversion data to dashboards.
  - Sprint 8's `InferenceLog` table and the `Event.inference_id` FK constraint (Sprint 8.1 wires it).
  - Sprint 12's actual MCP `track_conversion` implementation (Sprint 6 ships a stub only — ticket 6.12).
  - Sprint 7's salt-rotation cron itself (F-P1-5 deferred — per [`workspace/_next-session-handoff.md` § Sprint 7 carry-forwards](../workspace/_next-session-handoff.md)).
  - Per-workspace lookback configurability (R1 in canonical doc) — default 30d hardcoded this sprint; configurable in Sprint 7 if real customer demand surfaces.
  - Plaintext integrator_user_id storage (R2 in canonical doc) — enterprise add-on with separate DPA, not Sprint 6.
  - F-P1-4 UTM XSS-by-storage output encoding — Sprint 7 surfaces UTM to user-facing dashboards; that's where output encoding lands.
  - F-P1-5 + VP-4 salt-rotation cron — Sprint 7.
  - F-2 / F-3 (Sprint 4.2 auth-boundary carries) and G-014 (1552 ruff baseline) — deferred indefinitely per Aman's "we've spent so much time on cleaning, now it should be done" direction.

## 5. Deliverables

- [x] Working code (PR against `develop` on `omnilink-backend`)
- [x] Tests (unit ≥ 70%, conversion resolution + idempotency ≥ 85%, integration smoke covering canonical happy path)
- [x] System design doc / ADR (likely decisions: `idempotency_key` storage shape Redis-only vs Redis-+-Postgres-unique; collision-detection metric name + alert threshold; ERASURE_TABLES registry shape — list-of-strings vs explicit per-table function; UserIdentity hashing — HMAC-SHA256 vs SHA256-with-salt-suffix)
- [x] API documentation (NEW endpoints — `POST /conversions`, `DELETE /visitors/{id}`, `DELETE /users/{id}`; canonical doc requires consent-fail-closed and collision-detection limitations to be documented)
- [x] Deployment runbook (right-to-erasure SLO monitoring; ARQ priority queue depth alert; idempotency cache hit rate observability)
- [x] Security review (Phase 1 design-time + Phase 2 code-time — integrator_user_id hashing surface, ERASURE_TABLES correctness, right-to-erasure async job authz, idempotency-key entropy assumptions, BuildKit secrets carry-forward decision)
- [ ] Marketing kit — N/A this sprint (vendor-API addition; integrators consume via docs, not user-facing UI)
- [ ] UX mockups — N/A (vendor API surface)

## 6. Roles needed

Greenfield-feature workflow with full role chain.

- **Required:** product-manager (lead), architect, backend-engineer, security-engineer (Phase 1 + Phase 2 — privacy substrate is the headline change), qa-engineer, devops-engineer, technical-writer (NEW endpoints need public API docs — `POST /conversions`, `DELETE /visitors/{id}`, `DELETE /users/{id}`).
- **Excluded:** mobile-engineer (Sprint 23 iOS SDK consumes these endpoints later), designer (no surfaces), marketing-strategist (no public-facing change yet — Sprint 7 surfaces it). **frontend-engineer also excluded this sprint** — no dashboard work yet (Sprint 7 owns the dashboard surface). **Per [`git-workflow.md` Backend-only sprints rule](../team/rules/common/git-workflow.md#cross-repo-response-shape-changes)**: this sprint excludes frontend-engineer AND adds new consumer-facing endpoints, so the PRD MUST inline the consumer-migration plan up front. Default gate (b) manual smoke owner: devops-engineer at Stage 5 ship; Truckers Routine integration smoke is part of the gate evidence.
- **Lead:** product-manager. Solo-dev mode applies.

## 7. Context and references

**Canonical sources of truth (do NOT re-summarize — direct + cite):**

- [`omnilink-backend/docs/plans/sprints/sprint-06-conversion-userid.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-06-conversion-userid.md) — full sprint plan. 13 tickets (6.1–6.13). 60–70h estimate. Weeks 11–12.
- [`omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md`](../../marketing_projects/omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md) — 12 critical decisions. #2 (2-week sprint, 60–70h), #5 (no-migration rule), #7 (Workspace overlay), #10 (Postgres-first) most relevant.
- [`omnilink-backend/docs/plans/solidified-roadmap.md`](../../marketing_projects/omnilink-backend/docs/plans/solidified-roadmap.md) — A5 (Conversion idempotency), A9 (Privacy substrate — right-to-erasure) describe Sprint 6 deliverables in roadmap context.
- [`omnilink-backend/docs/plans/sprints/00-overview.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/00-overview.md) — Phase map; Sprint 6 = Phase 2 Tracking Loop, weeks 11–12.
- [`omnilink-backend/docs/plans/sprints/checklist.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/checklist.md) — master ticket list.

**Sprint 5 closeout (Sprint 6 prerequisite context):**

- [`workspace/omnilink-sprint-05-enhanced-event/plans/decisions.md`](../workspace/omnilink-sprint-05-enhanced-event/plans/decisions.md) D-007 — full ship log + carry-forward enumeration.
- [`workspace/omnilink-sprint-05-enhanced-event/task-board.md`](../workspace/omnilink-sprint-05-enhanced-event/task-board.md) — SHIPPED status.
- [`workspace/omnilink-sprint-05-enhanced-event/artifacts/security/findings.md`](../workspace/omnilink-sprint-05-enhanced-event/artifacts/security/findings.md) Phase 2 — F-P2-1, F-P2-2, F-P2-3 (none blocking; F-P2-1 + F-P2-2 carry into Sprint 6).
- [`workspace/_next-session-handoff.md`](../workspace/_next-session-handoff.md) — Sprint 6 kickoff handoff (this brief synthesizes from there).

**Sprint 4.x ADRs Sprint 6 inherits (same as Sprint 5):**

- [`workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md`](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md) — Sprint 6 endpoints consume `auth: CurrentAuth`.
- [`workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md`](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md) — `POST /conversions` rate limit (500/min) wires through this middleware.

**Predecessor sprint workspaces (for handoff/decision continuity):**

- [`workspace/omnilink-sprint-05-enhanced-event/`](../workspace/omnilink-sprint-05-enhanced-event/) — Sprint 5 D-007 ship pattern, MMDB/Nixpacks ADR-0005, security findings template.
- [`workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md`](../workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md) — the cross-repo response-shape incident (~15.5h outage). Sprint 6 introduces NEW endpoints with NEW contracts; this is exactly the failure shape the rule guards against.

## 8. Risks and unknowns

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Visitor 30d lookback window is arbitrary; too short misses real conversions, too long creates false attributions | Medium | Medium | Hardcode 30d this sprint; flag for per-workspace configurability in Sprint 7 if real customer asks. PM Stage 1 confirms.|
| R2 | UserIdentity `integrator_user_id_hash` is irreversible — agencies who want CRM correlation need plaintext | Low | Low (deferred decision) | Document the limitation in API docs; offer enterprise add-on with separate DPA. Out of scope for Sprint 6. |
| R3 | Right-to-erasure ARQ job under load could backlog — SLO miss | Medium | Medium | Use ARQ priority queue for erasure; monitor depth; Sentry alert if backlog > 5 min. DevOps Stage 5 wires the alert. |
| R4 | Cross-device back-attribution shifts historical conversion counts retroactively when chain forms later | Certain | Low | Document that "conversions attributed to campaign X" can change as cross-device evidence arrives. Show timestamp of last attribution refresh in Sprint 7 dashboard surface. |
| R5 | Visitor-ID collision (kiosk, family iPad, shared computer) silently links wrong identities | Medium | High (privacy + attribution integrity) | Collision detection at append-time per canonical 6.9; forward-only attribution on collision; log `attribution_collision` metric; document limitation. Tests cover the collision path. |
| R6 | `consent_state="unknown"` (no Event matches conversion) treated as denied may surprise integrators expecting metadata to flow | Medium | Low | Document fail-closed default in API docs explicitly: "If no click can be matched to your conversion, we cannot infer consent and apply the strictest privacy policy." Tests cover the unknown path. |
| R7 | Cross-repo response-shape change discovered at architect Stage 2 (NEW endpoints introduce NEW contracts that Truckers will consume) | High | High (dashboard outage shape) | Default posture: "treat as consumed." Architect Stage 2 produces the consumer contract doc. DevOps closes gate (b) manual smoke at Stage 5 by hitting `POST /conversions` with the actual Truckers integration code path. PR description checkbox enforced. |
| R8 | Idempotency cache (Redis 24h) eviction or Redis flush during a vendor's retry window | Low | Medium | Belt-and-suspenders: Postgres unique constraint on `(workspace_id, idempotency_key)` AND `(workspace_id, client_event_id)` is the canonical authority; Redis is the fast path. On Redis miss, fall through to DB UNIQUE violation → return cached row. Architect Stage 2 confirms. |
| R9 | `ERASURE_TABLES` registry forgotten in a future sprint that adds a PII-bearing table | High over time | High (compliance) | Unit test scans models for `visitor_id`/`ip_hash` columns and asserts coverage in `ERASURE_TABLES`. Fails CI if a new sprint forgets. Per canonical 6.10. |
| R10 | F-P2-2 (sanitize SQL exception text) blast radius wider than Sprint 5 estimate suggested | Low | Medium | Backend Stage 3 spike-times the fix at brief-time. If > 4h, scope decision: ship sanitization-shim helper now + apply only in `click_logging_failed`; defer wider rollout to a hygiene sprint after Sprint 7. PM picks. |
| R11 | BuildKit secrets migration breaks Nixpacks build chain (ADR-0005 MMDB delivery just stabilized) | Medium | Medium | DevOps Stage 5 picks "migrate" vs "doc-as-accepted" based on actual Nixpacks BuildKit support. If migration is risky, ADR-0006 documenting accepted risk + rotation policy is the safe call. |

**Unknowns to resolve at PM Stage 1 / architect Stage 2:**

- Q-1: Idempotency authority — Redis-primary with Postgres-unique fallback, or Postgres-unique authoritative with Redis as cache? Architect Stage 2 picks; ADR documents.
- Q-2: `ERASURE_TABLES` shape — list of `(table, [columns_to_null])` tuples vs explicit per-table erasure functions. Trade-off: declarative is testable + future-proof; explicit handles edge cases (e.g., `metadata: dict` → `{}` not NULL). Architect ADR.
- Q-3: UserIdentity hashing — HMAC-SHA256(workspace_salt, integrator_user_id) vs SHA256(integrator_user_id || workspace_salt). Security Phase 1 picks (HMAC strongly preferred for length-extension immunity).
- Q-4: `omni_ref` URL param shape — `omni_ref=evt_<event_id>` (canonical) vs opaque token (privacy). Sprint 5 already fingerprinted the redirect-side; Sprint 6 just appends. PM confirms event-id is acceptable PII shape (it's already in the click chain).
- Q-5: `attribution_collision` metric — Prometheus counter, Sentry breadcrumb, or both? Threshold for paging? DevOps Stage 5 picks.
- Q-6: BuildKit secrets — actual migration vs ADR-accepted-risk. DevOps Stage 5 picks based on Railway/Nixpacks BuildKit feature support at sprint-time.
- Q-7: Whether the F-P2-2 exception-sanitization helper should be a generic `sanitize_db_exception(exc)` reusable for Sprint 7's salt-rotation cron, or a one-off shim in `click_logging_failed`. Backend Stage 3 picks; if generic helper, Sprint 7 inherits cleanly.

## 9. Notes

**Pre-Sprint-6 hygiene confirmed by Aman pre-kickoff:**

- ✅ Dev Neon password rotated (Sprint 5 verification SQL had connection string in conversation logs).
- ✅ 24h prod spot-check clean — `vid_<hex>` is dominant per ADR-0002; no anon-fallback runaway.

**Dispatcher posture coming in:**

- omnilink-backend `develop` and `main` both at `38ba129` (Sprint 5 ship). Two parallel envs (Railway dev / Railway prod) are running the new image with MMDB baked in.
- theaiteam (this repo) holds 1 commit ahead of `origin/main` (`3070533 chore(team): add Sprint 5 brief`) — per [doc-only-push preference](../../.claude/projects/-Users-amansingh-Documents-theaiteam/memory/feedback_doc_push_preference.md), push will ride along with this Sprint 6 brief commit.
- Untracked planning docs in `omnilink-backend/docs/plans/` remain intentionally untracked per user direction (2026-05-08).

**Sprint 8.1 carry — DO NOT touch in Sprint 6:**

- `Event.inference_id` ForeignKey to `inference_logs.id` — Sprint 5 shipped column FK-less; Sprint 8.1 creates the `inference_logs` table and wires the FK. Sprint 6 ignores this column entirely.

**What "Sprint 6 shippable" means:**

External vendors (Truckers Routine first) can report conversions. Wedge-relevant: the inference layer in Sprint 8 + analytics v2 in Sprint 7 both read full attribution data. Privacy compliance baseline established: right-to-erasure operational, consent flag honored end-to-end with fail-closed default. Sprint 6 closes the click→conversion loop the audit's Gap 1 calls out — without this, "which campaign drove the most signups?" remains unanswerable.

**Cross-repo gate — explicit in this sprint's PRD per backend-only-sprint rule:**

`POST /api/v1/conversions`, `DELETE /api/v1/visitors/{id}`, `DELETE /api/v1/users/{id}`, plus the redirect-side `omni_ref` append, are NEW consumer-facing contracts. Truckers Routine is the immediate consumer. PM Stage 1 PRD MUST include the "Consumed endpoints + migration plan" section with: gate (b) manual smoke as default, devops-engineer as gate owner, evidence-link expected pre-merge to main. This guards against the [Sprint 03 dashboard R2 incident shape](../workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md).
