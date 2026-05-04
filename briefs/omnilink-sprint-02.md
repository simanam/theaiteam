---
slug: omnilink-sprint-02
type: greenfield-feature
priority: P1
deadline: 2026-05-24
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
predecessors:
  - omnilink-sprint-01
---

# Project Brief — OmniLink Sprint 2: RBAC Enforcement

## 1. Goal

Close audit finding **H3 ("any org member can do everything")**. Wire `require_permission()` into every mutating endpoint so a VIEWER cannot delete campaigns or cancel subscriptions and an ADMIN cannot manage billing. Register four new permission strings (`manage_workspace`, `approve_drafts`, `manage_branded_domain`, `view_audit_log`) that Sprints 3, 16, and 17 enforce in their respective domains. Add offset-based pagination on the four list endpoints that can return 4K+ rows.

The `OrganizationContext.require_permission()` framework already exists in `core/dependencies.py` — Sprint 2 is a wiring sprint, not a design sprint.

**Outcome at sprint end:** every endpoint enforces its declared permission. RBAC matrix integration test passes (~40 representative cases, ~960 logical cells covered). List endpoints handle 4K rows without OOM, p95 < 100ms.

The full ticket detail is in [`docs/plans/sprints/sprint-02-rbac-enforcement.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-02-rbac-enforcement.md) in the target repo (15 tickets, ~55–70h, 2 weeks). This brief is the orchestration wrapper; the canonical ticket spec lives there.

## 2. Target users

Indirect, but with a hard external trigger: **before any agency staff (DRAFTER, ADMIN, OWNER seats) touch the system**, role boundaries must be real. Today a VIEWER seat is a fiction — they have all permissions. After Sprint 2 they actually can't mutate. This unblocks Sprint 17 (DRAFTER workflow) and the agency tier launch.

## 3. Success criteria

All 15 tickets in `docs/plans/sprints/sprint-02-rbac-enforcement.md` complete with passing tests and merged PR. Specifically:

- [ ] **2.1** Endpoint coverage audit doc — every endpoint in `app/api/v1/endpoints/*.py` mapped to its required permission
- [ ] **2.2** Billing endpoint RBAC: `manage_billing` on mutations; `view` on reads; remove H11 re-query pattern
- [ ] **2.3** Campaigns endpoint RBAC: create/edit/delete gated; VIEWER blocked
- [ ] **2.4** Short links endpoint RBAC: same pattern as 2.3
- [ ] **2.5** Placements endpoint RBAC: same pattern as 2.3
- [ ] **2.6** Bulk endpoint RBAC: `create` minimum; `delete` if applicable
- [ ] **2.7** GS1 endpoint RBAC: matrix coverage; audit log read gated by `view_audit_log`
- [ ] **2.8** `me/delete_account` requires `delete_organization`; route through service layer (audit H12)
- [ ] **2.9** Register 4 new permission strings in `ROLE_PERMISSIONS` (`manage_workspace`, `approve_drafts`, `manage_branded_domain`, `view_audit_log`)
- [ ] **2.10** Pagination on `GET /campaigns` (offset-based, default 50, max 200, response shape `{items, total, next_cursor}`)
- [ ] **2.11** Pagination on `GET /shortlinks`
- [ ] **2.12** Pagination on `GET /placements`
- [ ] **2.13** Pagination on `GET /organizations` and `GET /organizations/{id}/members`
- [ ] **2.14** RBAC integration test matrix at `tests/integration/test_rbac_matrix.py` — ~40 parametrized representative cases covering all permission strings × all 4 roles
- [ ] **2.15** Pagination tests at `tests/integration/test_pagination.py` — seed 4K campaigns, paginate exhaustively, edge cases (`limit=0`, `limit=10000`, negative offset)
- [ ] All tests pass; coverage on touched files ≥ 70%
- [ ] One PR opened against `develop`, with the 15 ticket IDs in the body
- [ ] After merge, fast-forward `main` → `develop` to ship to prod (Truckers Routine MUST stay green; their flows don't hit RBAC-gated endpoints, but verify with a smoke test)

## 4. Stack and constraints

- **Languages / frameworks**: Python 3.12 + FastAPI + SQLAlchemy 2.x + Alembic + Pydantic v2 (unchanged from Sprint 1)
- **Datastores**: Postgres (Neon dev branch locally, Neon main branch in prod), Redis 7
- **Hosting**: Railway (`api.omny.link`, `go.omny.link`)
- **Test framework**: pytest + pytest-asyncio (integration suite now uses `alembic upgrade head` bootstrap — fixed in Sprint 2 Stage 0)
- **Lint/format**: ruff (informational; G-014 cleanup deferred)
- **Hard constraints**:
  - **Pagination response shape change** (array → `{items, total, next_cursor}`) is a breaking change to API consumers. Single consumer is the dashboard frontend. Ship coordinated, not versioned (per ticket 2.10 R2).
  - **Solo-dev cadence**: 55–70 hrs. Don't expand scope.
  - All locked decisions in `SESSION-BOOTSTRAP.md` apply.
- **Out of scope**:
  - **Sprint 3** (workspace model) — uses `manage_workspace` registered here
  - **Sprint 16** (branded domains) — uses `manage_branded_domain` registered here
  - **Sprint 17** (DRAFTER workflow) — uses `approve_drafts` registered here
  - **G-019 integration suite bit-rot** — separate cleanup PR, not bundled here. Sprint 2's RBAC tests are NEW tests; they go through the now-working alembic bootstrap and don't entangle with the legacy fixture drift.
  - **G-014 ruff cleanup** — separate cleanup PR
  - Frontend changes to consume the new paginated response shape (the dashboard is in a separate repo; coordinate via a follow-on ticket)

## 5. Deliverables

- [ ] Working code (PR opened against `develop` on a feature branch `feat/sprint-02-rbac-enforcement`)
- [ ] Tests (RBAC matrix + pagination tests; ≥70% coverage on touched files; existing tests stay green)
- [ ] Updated migrations if needed — none expected (permission strings live in Python, not the DB)
- [ ] Updated `docs/plans/sprints/checklist.md` with `[x]` marks per completed ticket
- [ ] Update `docs/plans/sprints/00-overview.md` to mark Sprint 2 complete
- [ ] System design / ADRs — minimal; ADR for the pagination response shape decision (offset vs cursor) if not already in canonical brief
- [ ] **Security review — REQUIRED this sprint** (it's literally an authz hardening sprint; `security-engineer` signs off before merge)
- [ ] Deployment runbook — verify the develop→main fast-forward step is documented
- [ ] UX flows / mockups — N/A (no user-visible UI change)
- [ ] Marketing kit — N/A
- [ ] User-facing docs — coordinate a follow-on doc-update for the API response-shape change once Sprint 2 ships

## 6. Roles needed

- **Required**: product-manager (slices canonical brief into stories, validates scope), architect (confirms endpoint inventory + pagination response shape; ADR if needed), backend-engineer (does the work for tickets 2.2–2.13), qa-engineer (writes RBAC matrix + pagination tests, tickets 2.14 + 2.15), security-engineer (reviews authz changes — this is the headline review for this sprint, not a rubber stamp), devops-engineer (verifies CI green; deploys via develop → main fast-forward; smoke tests Truckers post-deploy)
- **Excluded**: frontend-engineer, mobile-engineer, designer, marketing-strategist, technical-writer (no UI/marketing/doc work in this sprint beyond the changelog and a brief API doc note)
- **Lead**: product-manager (per team default for greenfield-feature workflow)

## 7. Context and references

**Read first (in order):**
1. [`docs/plans/sprints/sprint-02-rbac-enforcement.md`](../../marketing_projects/omnilink-backend/docs/plans/sprints/sprint-02-rbac-enforcement.md) — full ticket detail with acceptance criteria, permission matrix, R1/R2/R3 risks
2. `docs/plans/SESSION-BOOTSTRAP.md` — locked decisions and project canon
3. `docs/plans/sprints/checklist.md` — master tracking checklist
4. `docs/plans/sprints/00-overview.md` — Sprint 1 status and Sprint 3+ unlock map
5. Sprint 1 task board at [`workspace/omnilink-sprint-01/task-board.md`](../workspace/omnilink-sprint-01/task-board.md) — for context on what Stage 0 closed and what's still open (G-014, G-015 pooler-side, G-019)

**Spot-check before designing:**
- `app/api/v1/endpoints/*.py` — every endpoint, for ticket 2.1 audit
- `app/core/dependencies.py` — `OrganizationContext` + `require_permission` — already exists
- `app/models/organization_member.py::ROLE_PERMISSIONS` — extend in ticket 2.9
- `app/api/v1/endpoints/billing.py` — for ticket 2.2 + audit H11 re-query removal
- `app/api/v1/endpoints/me.py` — for ticket 2.8 + audit H12 service-layer routing
- `tests/integration/test_rbac_matrix.py` (NEW file in 2.14) — pattern after the existing integration test layout, but seed orgs + members in setup (don't replicate the legacy fixture drift from G-019)

**Use repomix:** the orchestrator's `tools/ingest.sh` packs the omnilink-backend repo into `workspace/omnilink-sprint-02/ingested/repomix-output.xml`. Read that for full context.

## 8. Risks and unknowns

- **R1 (from canonical brief):** Existing endpoints implicitly relied on no role check; adding `require_permission` may break integration tests written assuming MEMBER could do everything. Fix the tests to seed the right role per case, NOT loosen the new permission code.
- **R2:** Pagination changes the response shape from `[...]` to `{items, total, next_cursor}`. Single frontend consumer; ship coordinated. Verify the dashboard repo is updated in lockstep before deploy to prod.
- **R3:** RBAC matrix tests are tedious. Don't enumerate all 960 cells — pick ~40 representative cases that cover every permission string × every role at least once. Use `pytest.mark.parametrize` to keep the file small.
- **R4 (NEW for Sprint 2):** Truckers Routine flows hit redirect endpoints, not RBAC-gated CRUD. They should be unaffected, but verify with a pre/post-deploy smoke against `go.omny.link/survey` and `go.omny.link/tr-app` — same checks Sprint 1 ran.
- **R5 (NEW for Sprint 2):** Pre-existing G-019 (integration suite bit-rot) means the `tests/integration/` baseline is red. Sprint 2's NEW tests must be green; the existing failures stay informational. Don't get distracted into fixing G-019 mid-sprint — it's its own scoped effort.

## 9. Notes

- Sprint 2 ships off `develop`. After merge, fast-forward `main` → `develop` and push (matches Sprint 1's release pattern; Railway auto-redeploys both envs).
- Solo-dev mode applies. Self-review the diff before merge; security-engineer review is REQUIRED this sprint (not optional like in Sprint 1).
- Use `/standup omnilink-sprint-02` daily for status. `/audit` only if theaiteam itself misbehaves.
- After Sprint 2 ships, the natural next brief is `omnilink-sprint-03` (Workspace Model), which immediately starts enforcing `manage_workspace` registered here.
