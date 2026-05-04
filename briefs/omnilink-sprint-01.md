---
slug: omnilink-sprint-01
type: greenfield-feature
priority: P1
deadline: 2026-05-17
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — OmniLink Sprint 1: Audit Critical Fixes

## 1. Goal

Execute Sprint 1 of the OmniLink 26-sprint plan: 14 audit-cleanup tickets that resolve schema-model mismatches, finalize GS1 cache namespacing, add missing model relationships, standardize transaction boundaries, and clear the slips from Sprint 0. Get the codebase clean enough that Sprint 2 (RBAC Enforcement) can start without compounding debt.

This sprint is fix-existing-code, not new-feature-build. The plan, architecture, and stack are already locked — see `docs/plans/SESSION-BOOTSTRAP.md` in the target repo for non-negotiables.

## 2. Target users

Indirect — these are internal cleanup fixes that unblock all subsequent sprints. Real beneficiary is Aman (solo dev) and the future agency customers who'd otherwise hit schema-mismatch errors when consuming the API.

## 3. Success criteria

All 14 tickets in `docs/plans/sprints/sprint-01-audit-fixes.md` complete with passing tests and merged PR. Specifically:

- [ ] **1.1** GS1 service consolidation verified — `grep -r "from app.services.gs1_service" app/` returns empty (rewritten per REVIEW-FINDINGS F1; `gs1_service.py` is already gone, just confirm no orphaned imports)
- [ ] **1.2** GS1 cache namespace unified — single key pattern across `redirect_service.py` and `gs1_product_service.py`
- [ ] **1.3** `ShortLinkResponse.short_url` schema-model mismatch fixed; serialization roundtrip green
- [ ] **1.4** `CampaignResponse.short_url` schema-model mismatch fixed
- [ ] **1.5** `PlacementResponse.link` schema-model mismatch fixed
- [ ] **1.6** `GS1ProductResponse` 6 field mismatches fixed (`gs1_url`, `gs1_full_url`, `qr_code_url`, `gtin_type`, `check_digit_valid`, `is_sunrise_2027_compliant`)
- [ ] **1.7** `GS1BulkJobStatus` field rename (`success_count` → `successful_rows`)
- [ ] **1.8** `GS1AuditLogEntry` field rename (`timestamp` → `created_at`)
- [ ] **1.10** Add `relationship()` declarations on `Event` model (back-refs to `Campaign` and `Placement`)
- [ ] **1.12** Fix campaign slug stale-cache bug (capture old slug before update, invalidate both old + new keys)
- [ ] **1.13** Drop test-data tables; recreate fresh from migrations (no backfill — no-migration rule still applies, < 5 paying customers)
- [ ] **1.14** Verify Truckers Routine 2 campaigns work end-to-end after table recreation (the only real customer; their data must survive)
- [ ] **1.15** Standardize transaction boundaries — services flush, callers commit (audit H7, slipped from Sprint 0)
- [ ] **1.16** Fail-fast on missing Stripe keys in staging/prod (audit H18, slipped from Sprint 0)
- [ ] All tests pass; coverage on touched files ≥ 70%
- [ ] One PR opened against `main`, with the 14 ticket IDs in the body

Already done in Sprint 0 (verify only, don't redo):
- 1.9 — Redis `GETDEL` (done via Lua script in Sprint 0; verify the Lua script lives in `app/services/fingerprint_service.py` or equivalent)
- 1.11 — Missing indexes (done in `alembic/versions/2026_03_02_0002-cd635e1a27c6_add_missing_indexes.py`; verify migration has been applied)

## 4. Stack and constraints

- **Languages / frameworks**: Python 3.12 + FastAPI + SQLAlchemy 2.x + Alembic + Pydantic v2
- **Datastores**: Postgres (Supabase or local), Redis 7
- **Hosting**: Railway (backend), with Cloudflare in front
- **Test framework**: pytest + pytest-asyncio + factory_boy or pydantic-factories
- **Lint/format**: ruff
- **Type check**: mypy or pyright (per repo config)
- **Hard constraints**:
  - **No-migration rule still in force** (< 5 paying customers; drop-and-rebuild allowed for non-Truckers-Routine data)
  - **Solo-dev cadence**: 60–70 hrs of work in this sprint window. Don't expand scope.
  - All locked decisions in `SESSION-BOOTSTRAP.md` apply (no re-debating tier strategy, sprint count, iOS attribution tiers, etc.)
- **Out of scope**:
  - Sprint 2 (RBAC enforcement) — comes next, separate brief
  - Any new schema beyond what 14 tickets require
  - REVIEW-FINDINGS items not specifically tagged for Sprint 1 (those get folded as their own sprints land)
  - Performance optimization, refactoring beyond what tickets require

## 5. Deliverables

- [x] Working code (PR opened against `target_repo` on a feature branch `feat/sprint-01-audit-fixes`)
- [x] Tests (unit + integration; ≥70% coverage on touched files; existing tests stay green)
- [x] Updated migrations if needed (none expected for Sprint 1; flag if a ticket forces one)
- [x] Updated `docs/plans/sprints/checklist.md` with `[x]` marks per completed ticket
- [x] System design / ADRs — only if a fix requires a non-obvious decision (most are mechanical)
- [x] Security review — light pass; tickets 1.13/1.14/1.15/1.16 are the security-relevant ones
- [x] Deployment runbook — only update if 1.15 transaction-boundary changes affect deploy steps
- [ ] UX flows / mockups — N/A
- [ ] Marketing kit — N/A
- [ ] User-facing docs — N/A unless a public API shape changes (1.6 might if `gs1_full_url` was already documented)

## 6. Roles needed

- **Required**: product-manager (validates scope), architect (signs off on transaction-boundary pattern in 1.15), backend-engineer (does the work), qa-engineer (writes regression tests), security-engineer (reviews 1.13–1.16), devops-engineer (verifies CI green; checks if 1.15 needs deploy notes)
- **Excluded**: frontend-engineer, mobile-engineer, designer, marketing-strategist, technical-writer (no doc-writing in this sprint beyond the changelog)
- **Lead**: product-manager (per team default for greenfield-feature workflow)

## 7. Context and references

**Read first (in order):**
1. `docs/plans/SESSION-BOOTSTRAP.md` — locked decisions and project canon
2. `docs/plans/sprints/sprint-01-audit-fixes.md` — full ticket detail with acceptance criteria
3. `docs/plans/sprints/checklist.md` — master tracking checklist (update as you go)
4. `docs/plans/REVIEW-FINDINGS.md` — F1, F2, F5, F6 touch Sprint 1; the rest defer
5. `docs/plans/solidified-roadmap.md` — architectural locks; no re-debating

**Spot-check before designing:**
- `app/models/event.py` — for ticket 1.10 (relationship back-refs)
- `app/api/v1/endpoints/{shortlinks,campaigns,placements}.py` and matching schemas — for tickets 1.3–1.5
- `app/services/gs1_*.py` — for tickets 1.1, 1.2, 1.6, 1.7, 1.8
- `app/services/fingerprint_service.py` and Sprint 0 Lua script — for ticket 1.9 verification
- `alembic/versions/*indexes*` — for ticket 1.11 verification

**Use repomix:** the orchestrator's `tools/ingest.sh` will pack the omnilink-backend repo into `workspace/omnilink-sprint-01/ingested/repomix-output.xml`. Read that for full context, but spot-grep for the specific files above when designing fixes.

## 8. Risks and unknowns

- **Test data drop (1.13) cannot break Truckers Routine.** Their 2 campaigns are real. Plan: capture their campaign + shortlink rows before drop, recreate after. QA owns the verification (1.14).
- **Transaction boundary refactor (1.15) is broad-touch.** Services flush, callers commit — this is a pattern change that may surface latent bugs. Architect should sign off on the pattern before backend implements; QA should run the full integration suite after.
- **Pydantic v2 schema fixes (1.3–1.8)** may break consumers if the API responses change shape. Verify by grep'ing the only real consumer (Truckers Routine flows) and the test suite before changing field names.
- **Hidden Sprint 0 slips beyond 1.15/1.16**: REVIEW-FINDINGS may surface more during the sprint. If found, log via `/log-gap` and decide in-sprint whether to absorb (small) or defer (large).

## 9. Notes

- This is the team's first run on omnilink. Treat ticket 1.1's "verify only" as a smoke test for the team's ability to follow plan-vs-code reality (the plan said "consolidate" but Sprint 0 already did it; the team should notice this and not redo it).
- After this sprint ships, the natural next brief is `omnilink-sprint-02` (RBAC Enforcement). Don't pre-emptively pull Sprint 2 work into Sprint 1.
- Use `/standup omnilink-sprint-01` daily for status; `/audit` only if theaiteam itself starts misbehaving (separate concern from project work).
