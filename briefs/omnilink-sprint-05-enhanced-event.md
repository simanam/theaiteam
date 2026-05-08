---
slug: omnilink-sprint-05-enhanced-event
type: greenfield-feature
priority: P1
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 5: Enhanced Event Model (Phase 2 — Tracking Loop)

> **Source-of-scope:** [`omnilink-backend/docs/plans/sprints/sprint-05-enhanced-event.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-05-enhanced-event.md). This brief synthesizes that doc; **the canonical plan is the source of truth at PM Stage 1** for ticket-level acceptance criteria.

## 1. Goal

Capture the rich click data the inference layer (Sprint 8), composable analytics (Sprint 7), and conversion attribution (Sprint 6) all need. Unify Link Shortener tracking into the Event model so a ShortLink click stops being a second-class integer counter and becomes a real Event row.

Outcome at sprint end: every click captures `browser`, `city`, `visitor_id`, `event_type`, `is_unique`, full UTM (`utm_source`/`medium`/`campaign`/`term`/`content`), plus `short_link_id` FK and a forward-compat `inference_id` column. Bot detection on. Request-level dedup for double-clicks/Cloudflare retries. ShortLink clicks produce full Events, not bumps to `click_count`.

## 2. Target users

- **Agencies** (Campaigns flagship) — Sprint 7 dashboards will slice analytics by browser + city after this lands.
- **Creators** (Bio Hub flagship, Sprint 11b) — every Bio Hub button click flows through this same Event pipeline; rich data unlocks per-button geo/device breakdowns post-Sprint-11b.
- **Sprint 6 (Conversion model)** — uses `visitor_id` for cross-event matching.
- **Sprint 8 (Inference)** — reads `utm_*` and `event_type` for context.
- **Sprint 23 (iOS SDK Tier B)** — single-use install fingerprint matches against `visitor_id`.
- **Sprint 17 (Approval workflow)** — DraftLink preview short URLs use Event tracking from day one.

## 3. Success criteria

Headline criteria only. PM Stage 1 expands to per-ticket ACs in [`stories.md`](../workspace/omnilink-sprint-05-enhanced-event/plans/stories.md) sourced from the [canonical sprint plan](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-05-enhanced-event.md) tickets 5.1 through 5.16.

- [ ] Schema additions land: `short_link_id` (nullable FK), `browser`, `city`, `visitor_id` (NOT NULL), `event_type` enum (CLICK/SCAN/REDIRECT, default CLICK), `is_unique` bool, full UTM (5 cols), `inference_id` (nullable, FK constraint deferred to Sprint 8.1). One Alembic migration; no backfill choreography (no-migration rule still active per [SESSION-BOOTSTRAP decision #5](../../marketing_projects/omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md)).
- [ ] CHECK constraint: either `campaign_id` OR `short_link_id` non-null on Event.
- [ ] MaxMind GeoLite2 integration: `app/services/geoip.py`, `lookup_city(ip) → {country, city, region}`, Redis-cached 1h TTL, falls back to None on missing MMDB.
- [ ] User-Agent parsing: `app/services/user_agent_parser.py` returns `{os, browser, device_type, is_bot}` — bots flagged but logged.
- [ ] Visitor ID computation: extends `app/services/fingerprint.py` with `compute_visitor_id(ip, ua, workspace_id) → "vid_<sha256-32-hex>"`. Per-workspace `visitor_salt` column on `Workspace` (NOT settings JSONB — explicit column for rotation cron). Quarterly rotation via background job.
- [ ] UTM parser: `app/services/utm_parser.py`, called in redirect handler before logging Event; UTM stripped from final destination URL.
- [ ] `is_unique` set at write time via Redis `SADD` against `unique_visitors:{workspace_id}:{campaign_id_or_short_link_id}:{quarter}` with 90d TTL.
- [ ] Request-level Event dedup: Redis `SET ... NX EX 5` on `sha256(visitor_id+target_id+url_path+ip_hash)`; 5s window kills double-clicks/CF retries; preserves `is_unique` semantics.
- [ ] `app/services/analytics.py log_click()` rewritten to populate every new field; transactional integrity preserved (services flush, callers commit per Sprint 1 ADR-0001 / audit H7).
- [ ] Endpoints: redirect handler updated; ShortLink redirect produces Event row (not just counter bump). Existing v1 analytics responses unchanged in shape (cross-repo posture: no breakage).
- [ ] Tests: every new field populated correctly on a sample request; ShortLink click → Event with `short_link_id` set, `campaign_id` null; bot UA → `is_bot` flagged; repeat visit → `is_unique=False`; salt rotation → visitor_id changes; concurrent identical requests → exactly 1 Event row. Coverage on new services ≥ 70%; on `analytics.log_click` ≥ 85% (high-traffic path).
- [ ] Truckers Routine smoke green post-deploy: `go.omny.link/{survey,tr-app}` 307 → `truckersroutine.com`; one real click produces a full Event row with new fields populated.
- [ ] Sprint 4 carry-forward `Sprint 1 ticket 1.14` (Truckers smoke after 1.13 staging exec) closeable inline if devops verifies during Stage 5 ship.

## 4. Stack and constraints

- **Languages / frameworks:** Python 3.12 / FastAPI / SQLAlchemy 2.x async / Pydantic v2 / Postgres 16 (Neon) / Redis 7 (Upstash). No new runtime deps unless justified — Sprint 5 needs `user-agents` and `geoip2` (MaxMind). Both lightweight, well-maintained; PM Stage 1 confirms.
- **Hosting:** Railway prod (api.omny.link / go.omny.link) on `main`; Railway dev on `develop`. Two parallel envs per [project memory](../../theaiteam-memory).
- **Existing systems:** `app/models/event.py`, `app/services/analytics.py`, `app/services/fingerprint.py`, `app/api/v1/endpoints/redirects.py`, `Workspace` model. Auth: events should consume `auth: CurrentAuth` (NOT `current_user: CurrentUser`) per [Sprint 4.2 ADR-0001](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md).
- **No-migration rule:** drop test data freely; no backfill choreography. Truckers Routine (only paying customer, 2 campaigns) needs a smoke test pre-/post-migration. Sunset condition unchanged (5 paying customers, projected ~Sprint 19).
- **Hard constraints:**
  - Redirect latency: GeoIP lookup adds 1–3ms acceptable; existing redirect is ~20ms. Profile on staging before promoting.
  - PII: `ip_hash` (existing) + `visitor_id` are the only identifier-shape fields; both salted. No raw IPs persisted. Visitor salt rotation by design lossy across quarters (privacy by design).
  - Cross-repo posture: this sprint's intended posture is **no consumer-impacting response-shape change** (per [`team/rules/common/git-workflow.md` § Cross-repo response-shape changes](../team/rules/common/git-workflow.md#cross-repo-response-shape-changes)). New columns are write-side; existing v1 analytics responses don't expose them yet (Sprint 7 does that). Architect at Stage 2 confirms; DevOps closes posture at Stage 5 (gate (b) Path B fallback if a consumer surfaces).
- **Out of scope:**
  - Sprint 7's composable analytics endpoint that would expose new fields to dashboards.
  - Sprint 6's Conversion model and idempotency.
  - Sprint 8's `InferenceLog` table and reattribution endpoint (Sprint 5 only adds the FK column with deferred constraint).
  - ClickHouse migration (deferred until > 1K events/sec sustained per [solidified-roadmap A4 / decision #10](../../marketing_projects/omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md)).
  - Visitor salt rotation cron itself (Sprint 5 adds the column + rotation function; cron wiring can land here OR in Sprint 7 — PM Stage 1 picks).

## 5. Deliverables

- [x] Working code (PR against `develop` on `omnilink-backend`)
- [x] Tests (unit ≥ 70%, `analytics.log_click` ≥ 85%, integration smoke covering full pipeline)
- [x] System design doc / ADR (decisions: `visitor_salt` storage shape — column vs JSONB; dedup window choice; UTM-stripping cosmetic vs preserving)
- [x] Deployment runbook (MaxMind MMDB delivery: lazy-download vs build-into-image; salt rotation cron schedule)
- [x] Security review (Phase 1 design-time + Phase 2 code-time — visitor_id is a PII-adjacent identifier; ensure salt is workspace-scoped, never logged, rotation policy documented; sanitize_for_log scrubbed before output)
- [ ] Marketing kit — N/A this sprint (no user-facing surface yet; Sprint 7 + Sprint 11b expose the data)
- [ ] UX mockups — N/A (data substrate only)

## 6. Roles needed

Greenfield-feature workflow. Full role chain.

- **Required:** product-manager (lead), architect, backend-engineer, security-engineer (Phase 1 + Phase 2), qa-engineer, devops-engineer.
- **Excluded:** frontend-engineer (no UI), mobile-engineer (Sprint 23 iOS SDK consumes `visitor_id` later), designer (no surfaces), marketing-strategist (no public-facing change), technical-writer (no public docs change — internal runbook ok).
- **Lead:** product-manager. Solo-dev mode applies (single-dev review per [`team/rules/common/git-workflow.md` § Single-dev mode](../team/rules/common/git-workflow.md#single-dev-mode)).

## 7. Context and references

**Canonical sources of truth (do NOT re-summarize — direct + cite):**

- [`omnilink-backend/docs/plans/sprints/sprint-05-enhanced-event.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-05-enhanced-event.md) — full sprint plan. 16 tickets (5.1–5.16). 55–65h estimate.
- [`omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md`](../../marketing_projects/omnilink-backend/docs/plans/SESSION-BOOTSTRAP.md) — 12 critical decisions locked. Decisions #2 (2-week sprint, 60–70h), #5 (no-migration rule), #7 (Workspace overlay), #10 (Postgres-first, ClickHouse deferred) most relevant.
- [`omnilink-backend/docs/plans/solidified-roadmap.md`](../../marketing_projects/omnilink-backend/docs/plans/solidified-roadmap.md) — Part A1 (Workspace overlay), A4 (Inference 3-tier — Sprint 5 forward-compat with `inference_id` col), A5 (Conversion idempotency — Sprint 6 consumes Sprint 5's `visitor_id`), A9 (Privacy substrate — `visitor_id` privacy-by-design rotation), Phase 1 list explicitly names Sprint 5's deliverables.
- [`omnilink-backend/docs/plans/sprints/00-overview.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/00-overview.md) — Phase map; Sprint 5 = Phase 2 Tracking Loop, weeks 9–10.
- [`omnilink-backend/docs/plans/sprints/checklist.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/checklist.md) — Sprint 5 master ticket list (5.1–5.16). Note: just reconciled with Sprint 4.x cleanup arc shipped at `9060890` (commit `bfc2955` on local develop, not yet pushed).

**Sprint 4.x ADRs Sprint 5 inherits:**

- [`workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md`](../workspace/omnilink-sprint-04.2/plans/adr/0001-current-user-stays-jwt-only.md) — STAY-JWT-ONLY classification. Sprint 5 events MUST consume `auth: CurrentAuth`, NOT `current_user: CurrentUser`.
- [`workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md`](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md) — middleware migration shape post-D-004. Only relevant if Sprint 5 adds rate-limit decorators on new endpoints (it shouldn't — redirects are already rate-limited at the platform edge).

**Predecessor sprint workspaces (for handoff/decision continuity):**

- [`workspace/omnilink-sprint-04.4-rate-limit-currentauth/`](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/) — Sprint 4.4 close decisions (D-006 retro pattern).
- [`workspace/omnilink-sprint-04.4.1-rate-limit-size-currentauth/`](../workspace/omnilink-sprint-04.4.1-rate-limit-size-currentauth/) — Sprint 4.4.1 same-day close pattern.
- [`workspace/omnilink-sprint-04/`](../workspace/omnilink-sprint-04/) — Sprint 4 PRD shape + cross-repo gate posture pattern.

**External references:**

- MaxMind GeoLite2: <https://www.maxmind.com/en/geolite2/signup> — free GeoIP DB, requires account approval (~24h lead time). Apply at brief-time so MMDB is in hand for backend Stage 3.
- `user-agents` Python lib: <https://pypi.org/project/user-agents/> — UA parsing.

## 8. Risks and unknowns

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | MaxMind GeoLite2 license signup gates Stage 3 backend work | Medium | Medium (~24h delay) | PM Stage 1 ticket: apply for GeoLite2 license at brief-time. If rejected/delayed, Plan B = ip-api.com or fall back to country-only via existing logic. |
| R2 | GeoIP lookup adds redirect latency beyond budget | Low | Medium | Profile on staging before promote. Redis 1h cache covers 80%+ of IPs (bot traffic repeats). Hard budget: redirect p95 ≤ 30ms post-Sprint-5 (currently ~20ms). DevOps gates ship on this. |
| R3 | Visitor salt rotation cron forgotten / skipped > 1 quarter | Low | Low | Document in `core/scheduler.py`; add Sentry alert if rotation skipped > 100 days. Defer cron wiring to PM Stage 1 — column + rotation function lands this sprint, scheduler hook lands here OR Sprint 7 (PM picks). |
| R4 | Existing ShortLink clicks have NO Event history (just counter); post-Sprint-5 they will but historical data is lost | Certain | Low (only Truckers Routine + tests have any traffic) | Communicate to Truckers; document in handoff to Sprint 7. No customer-facing breakage. |
| R5 | Cross-repo response-shape change discovered at architect Stage 2 | Low | High (dashboard outage shape per [`workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md`](../workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md)) | Default posture: no consumer impact (new fields write-side; v1 analytics responses don't expose). Architect Stage 2 audits actual response surface; if anything changes shape, gate (b) manual smoke OR gate (a) co-deploy per `git-workflow.md`. DevOps closes at Stage 5. |
| R6 | `visitor_id` defined as NOT NULL but not always computable (e.g., missing UA / IP edge cases) | Low | Medium | Service must always return a value — fall back to `vid_anon_<random32>` for edge cases. Architect ADR locks the fallback; backend implements. |
| R7 | Dedup 5s window collides with Sprint 6 conversion idempotency (24h `Idempotency-Key` keys) | Low | Low | Different scopes — Sprint 5 dedup is request-level (`sha256(visitor_id+target+path+ip_hash)`); Sprint 6 idempotency is conversion-level (`Idempotency-Key` header). PM Stage 1 confirms semantic distinction in PRD. |
| R8 | Visitor ID stability across client behaviors (mobile UA shifts, IP changes per session) | High | Low | Acceptable. `visitor_id` is best-effort within a quarter; cross-quarter is intentionally lossy. Sprint 6's `UserIdentity` chain handles cross-device when integrator supplies stable user_id. |

**Unknowns to resolve at PM Stage 1 / architect Stage 2:**

- Q-1: `visitor_salt` storage — dedicated column on `Workspace` vs JSONB key in `Workspace.settings`. Canonical doc says column; verify with architect that rotation semantics + index needs justify it.
- Q-2: MMDB delivery shape — build into Docker image (deterministic, +60MB image) vs lazy-download on first lookup (smaller image, cold-start latency, license-key in env). DevOps Stage 5 picks.
- Q-3: Visitor salt rotation cron — wire in Sprint 5 or defer to Sprint 7 with column-only this sprint? PM Stage 1 picks based on effort headroom (canonical 55–65h leaves room).
- Q-4: UTM stripping from final destination URL — cosmetic-only or preserve for downstream tracking compatibility (e.g., Truckers' destination already expects UTM). Architect Stage 2 reviews call sites.
- Q-5: Event row volume estimate post-ShortLink-unification — Truckers Routine's 2 campaigns currently log only `click_count` bumps; post-Sprint-5 they log full Events. Estimate steady-state event/day to confirm Postgres comfort margin (per A4 ClickHouse-deferral threshold).

## 9. Notes

**Dispatcher posture coming in:**

- omnilink-backend on local `develop` at `bfc2955` (one commit ahead of `origin/develop @ 9060890`). The unpushed commit is the [Sprint 4 + 4.x cleanup arc reconciliation](../../marketing_projects/omnilink-backend/docs/plans/sprints/checklist.md) — docs-only, no behavior change. Decision pending with user: push to origin/develop now or hold.
- Untracked planning docs in `omnilink-backend/docs/plans/` (SESSION-BOOTSTRAP, solidified-roadmap, sprint-*) are intentionally untracked per user direction (2026-05-08). They remain the canonical source of truth via local working tree.
- Forward-looking unstaged scope additions on `checklist.md` (Bio Hub Sprint 11b, Sprint 19.11 Stripe, Sprint 22.2 Empty Click, Commerce Source Connectors) are user WIP, not Sprint 5 scope.
- Open Sprint 4 carry-forwards (F-2, F-3, lint G-014) deferred per user direction: "we've spent so much time on cleaning, now it should be done." Sprint 5 should not pile cleanup on top — only fold these in if a Sprint 5 ticket trips them.

**What "Sprint 5 shippable" means:**

User-facing: when Sprint 7 lands, agency dashboards will show browser/city/UTM breakdowns and ShortLink users will see their clicks broken down by device/geo for the first time. This sprint does the underground plumbing. Substrate-readiness for Sprints 6, 7, 8 is the actual value.

**Sprint 12 dependency thread:** AI-products-ready milestone (Sprint 12, ~Month 6) requires Sprint 5/6/7 to be solid because the MCP `get_click_stream`, `get_geo_breakdown`, `get_attribution_report` tools (Sprint 11) all read this data. Don't cut quality corners here.
