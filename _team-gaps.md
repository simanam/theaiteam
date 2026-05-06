# theaiteam — gap log

This is the queue of identified gaps in theaiteam itself. Roles append here when they notice issues during project work via `/log-gap`. Team Maintainer drains the queue via `/audit` and `/self-improve`.

## Conventions

- Each gap has an ID (`G-NNN`), severity, evidence, proposed fix, status, logged-by, logged-date.
- Append-only — never delete entries. Mark `won't-fix` with reason if rejected.
- Numbering is global. `G-001` is the first gap ever; do not reset per audit.
- The Maintainer is the only role that closes entries (sets `fixed-in-<sha>` or `filed-as-improvement-<slug>`).

## Status values

| Status | Meaning |
|---|---|
| `open` | Just logged. Maintainer hasn't triaged yet. |
| `in-progress` | Maintainer is actively fixing. |
| `fixed-in-<sha>` | Edited and committed. SHA references the commit. |
| `filed-as-improvement-<slug>` | Non-trivial fix; brief at `improvement-briefs/<slug>.md`. Run `/kickoff <slug>` to address. |
| `won't-fix` | Rejected with reason in **Notes**. |

---

## Initial gaps (logged at scaffolding time, 2026-05-03)

These are the four gaps surfaced when the team was first built. Maintainer can drain them on first `/self-improve`.

### Gap G-001 — devops-skills-empty
**Severity:** moderate
**Evidence:** `team/skills/devops/` is empty. The DevOps role file expects skills like `ci-cd-setup`, `deployment`, `observability`, `infra-as-code`.
**Proposed fix:** Author 4 skills under `team/skills/devops/` covering CI/CD pipeline setup, repeatable deploys, observability (logs/metrics/alerts), and infra-as-code patterns.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Likely too large for auto-fix; file as improvement brief on first /self-improve.

### Gap G-002 — security-skills-only-trailofbits
**Severity:** moderate
**Evidence:** `team/skills/security/` top level is empty. Only `_trailofbits/` (CC BY-SA 4.0) is present. No top-level Apache/MIT-licensed `owasp-review` or `threat-modeling` skill.
**Proposed fix:** Author 2 skills under `team/skills/security/`: `owasp-review` (API + Web Top 10 checklist) and `threat-modeling` (STRIDE-style design review). MIT-licensed (theaiteam original) so derivatives don't carry CC BY-SA share-alike.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Filed as improvement brief on first /self-improve.

### Gap G-003 — gemini-adapter-stub
**Severity:** moderate
**Evidence:** `adapters/gemini/sync.sh` only writes a `GEMINI.md` pointer + `.gemini/context.md` index. It does not concatenate the team into a usable system-instruction.
**Proposed fix:** Extend the script to mirror `adapters/codex/sync.sh` — concatenate roles + skills + rules + commands + workflows into a single GEMINI.md or per-file system-instruction set.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Simple extension; auto-fixable on first /self-improve.

### Gap G-004 — language-reviewer-agents-not-symlinked
**Severity:** trivial
**Evidence:** `adapters/claude-code/sync.sh` symlinks top-level `team/agents-extra/*.md` but does not recurse into `language-reviewers/` or `build-resolvers/` subdirs.
**Proposed fix:** Update sync.sh to recurse, OR explicitly list nested agent files. Decide whether to flatten (avoids picker overload) or namespace (e.g., `lang-typescript-reviewer`).
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Auto-fixable.

---

## Discovered by tools/validate.sh on 2026-05-03

### Gap G-005 — missing-skill-set-architecture
**Severity:** moderate
**Evidence:** `team/roles/architect.md` previously listed `architecture/system-design`, `architecture/data-modeling`, `architecture/tech-stack-selection`, `meta/repomix-ingest` in default-skills; none have `SKILL.md` files. Removed from frontmatter; documented as aspirational.
**Proposed fix:** Author 4 skills under `team/skills/architecture/` and `team/skills/meta/` covering system design, data modeling (ERD + indexing patterns), tech-stack-selection (decision matrix), and repomix-ingest (procedure for using `tools/ingest.sh`).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-006 — missing-skill-engineering-refactoring
**Severity:** moderate
**Evidence:** `team/roles/backend-engineer.md` referenced `engineering/refactoring`; no SKILL.md exists. Removed.
**Proposed fix:** Author `team/skills/engineering/refactoring/SKILL.md` covering safe transformation patterns (extract, inline, split-merge) with tests-as-safety-net.
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-007 — missing-skill-engineering-code-review-canonical
**Severity:** trivial
**Evidence:** Multiple roles (backend, frontend, mobile, security) referenced `engineering/code-review`; vendored set has `engineering/requesting-code-review` and `engineering/receiving-code-review` (separate). Roles updated to use both vendored versions or one as appropriate.
**Proposed fix:** Either author a single `engineering/code-review/SKILL.md` that points to both, OR keep the split and add a meta skill `engineering/peer-review-loop` describing how requesting+receiving compose. Lean toward composing.
**Status:** in-progress (worked around in role frontmatter; proper fix deferred)
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-008 — missing-skill-set-design
**Severity:** moderate
**Evidence:** `team/roles/designer.md` and `team/roles/frontend-engineer.md` referenced `design/design-system` and `design/ux-flow`; neither has a SKILL.md.
**Proposed fix:** Author 2 skills under `team/skills/design/`: `design-system` (tokens + components + rhythm) and `ux-flow` (every screen, every state, every transition).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-009 — missing-skill-set-product
**Severity:** moderate
**Evidence:** `team/roles/product-manager.md` referenced `product/user-story`, `product/roadmap`, `meta/handoff-protocol`; none have SKILL.md files.
**Proposed fix:** Author 3 skills: `product/user-story` (decomposing PRDs into testable stories with acceptance criteria), `product/roadmap` (sequencing work), `meta/handoff-protocol` (the format for `workspace/<slug>/handoffs/*.md`).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-010 — missing-skill-set-qa
**Severity:** moderate
**Evidence:** `team/roles/qa-engineer.md` referenced `qa/test-strategy` and `qa/manual-test-plans`; neither has SKILL.md.
**Proposed fix:** Author 2 skills: `qa/test-strategy` (unit/integration/E2E split per project) and `qa/manual-test-plans` (exploratory + scripted test plan structure).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-011 — missing-skill-set-docs
**Severity:** moderate
**Evidence:** `team/roles/technical-writer.md` referenced `docs/api-docs`, `docs/readme-writing`, `docs/changelog`, `docs/runbook`; ZERO of the 4 have SKILL.md files. Worst-impacted domain.
**Proposed fix:** Author all 4 skills under `team/skills/docs/`. README and runbook are highest-leverage (they're produced for every project).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

---

## Future gaps go here

Append below. Increment G-NNN globally.

---

## Discovered during omnilink-sprint-01 backend impl

### Gap G-012 — pre-existing-organization-test-failures-on-omnilink-develop
**Severity:** trivial (project-specific, not theaiteam itself — kept here only because the noise risks masking real Sprint 1 regressions)
**Evidence:** On the omnilink-backend repo's `develop` branch, six tests in `tests/unit/test_organization.py` (`TestOrganizationPlan::test_free_plan_value`, `test_pro_plan_value`, `test_enterprise_plan_value`, `test_all_plans_exist`, `TestOrganizationListResponse::test_includes_role`, `test_role_is_optional`) fail with `AttributeError: FREE` because the `OrganizationPlan` enum was renamed to the new tier set (CREATOR/FLEET/SCALE/AGENCY/ADMIN) without updating these tests.
**Proposed fix:** Project-side, not theaiteam-side. Backend role on omnilink should rewrite those tests against the current enum values. Out of scope for Sprint 1 audit-fixes (no ticket touches this).
**Status:** fixed-in-ebd2fc2 (omnilink-backend, on PR #2 / branch `chore/sprint-02-pre-cleanup`)
**Logged by:** backend-engineer (during omnilink-sprint-01 S-003/S-004 verification)
**Logged date:** 2026-05-04
**Notes:** Confirmed pre-existing on `develop` (verified by stashing Sprint 1 work and re-running). Closed during Sprint 2 Stage 0 — rewrote the enum-value tests against the actual 7-tier set (HOBBY/CREATOR/FLEET/SCALE/AGENCY/PARTNER/ADMIN, not the 5-tier the gap text guessed at) and added STRIPE_PLANS / UNLIMITED_PLANS membership checks to catch future drift. CI `--ignore=tests/unit/test_organization.py` flag dropped in commit 21a2a89.

### Gap G-013 — omnilink-integration-tests-broken-on-develop
**Severity:** moderate (project-specific, but big enough to block CI gating until fixed)
**Evidence:** On the omnilink-backend repo, `pytest tests/integration/` errors on every test with `sqlalchemy.exc.DBAPIError: invalid input value for enum gs1bulkjobstatus: "pending"` during the `Base.metadata.create_all()` schema bootstrap. The `gs1_bulk_jobs` CREATE TABLE references the enum's `'pending'` default value before PostgreSQL has committed the `CREATE TYPE gs1bulkjobstatus`. Confirmed pre-existing on `develop` branch (re-verified 2026-05-04).
**Proposed fix:** Project-side. Bootstrap the test schema via `alembic upgrade head` instead of `Base.metadata.create_all()` in `tests/conftest.py`. This forces enum types to be CREATEd before any table that references them.
**Status:** fixed-in-85a5869 (conftest bootstrap); required-gate promotion deferred behind G-019
**Logged by:** backend-engineer (during omnilink-sprint-01 Stage 4 prep)
**Logged date:** 2026-05-04
**Notes:** Closed during Sprint 2 Stage 0. Conftest now overrides `DATABASE_URL` to `TEST_DATABASE_URL`, busts `get_settings.cache_clear()`, runs `alembic.command.upgrade(cfg, "head")` in a worker thread (env.py uses `asyncio.run` at module load and can't run inside pytest-asyncio's event loop), and tears down via `DROP SCHEMA public CASCADE; CREATE SCHEMA public`. Verified locally: 21 migrations apply cleanly, schema bootstrap is no longer a blocker. **However**, with the bootstrap fixed, the integration suite surfaced ~40 pre-existing failures that were hidden behind `continue-on-error: true` — those are split out as G-019 below. Integration job stays informational until G-019 is drained, then promote to required.

### Gap G-015 — omnilink-asyncpg-cant-reach-neon-pooler-from-local-mac
**Severity:** moderate (project-specific, blocks any local script that hits the live DB)
**Evidence:** From two different Macs (mine and Aman's), `asyncpg.connect("postgresql://...@ep-misty-haze-a4n4v7t3-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require")` times out after 30s. Neon console shows compute as Active. `psql` from the same machine wasn't successfully tested due to a shell-quoting issue with the URL. Browser-based Neon SQL editor works (Aman uses it for snapshots). Suggests the pooler endpoint is unreachable from these IPs OR there's a TLS/auth handshake issue specific to asyncpg.
**Proposed fix:** Project-side. Diagnose:
1. Try the direct (non-pooler) endpoint — drop `-pooler` from the host. If that works, the issue is pgbouncer + asyncpg compat (fix: append `?prepared_statement_cache_size=0` to the URL).
2. Check Neon IP allowlist (Settings → Network).
3. Try `psql` with `PGPASSWORD=... psql -h ep-misty-haze-a4n4v7t3-pooler.us-east-1.aws.neon.tech -U neondb_owner -d neondb -c "SELECT 1"` to bisect asyncpg-vs-libpq.
**Status:** open
**Logged by:** backend-engineer (during omnilink-sprint-01 S-013 attempted execution)
**Logged date:** 2026-05-04
**Notes:** Sprint 1 S-013 data drop will run via Neon's web SQL editor as a workaround. Doesn't block the PR or the deploy.
**Update 2026-05-04 (post-deploy):** Bisected further. `pg_dump` against the same URL fails with `invalid URI query parameter: "ssl"` — the `.env` `DATABASE_URL` uses asyncpg's `?ssl=require` syntax, which libpq doesn't accept (libpq wants `?sslmode=require`). Workaround for `pg_dump`: rewrite the param at command time. Project-side fix: standardize `.env` on `?sslmode=require` (asyncpg accepts both; libpq only accepts the latter). The asyncpg-can't-reach-pooler issue is separate and still open — even with correct asyncpg syntax, the connection times out.
**Update 2026-05-04 (Sprint 2 Stage 0 verification):** `.env` is already standardized — both `DATABASE_URL` (line 37) and `PROD_DATABASE_URL` (line 38) use `?sslmode=require`. Stripe-related portion of this gap is effectively closed; no edit needed. The asyncpg-can't-reach-pooler-from-local-mac symptom (separate root cause: likely Neon network-restrictions or pgbouncer compat) is not blocking any current work — log a fresh gap if it recurs. Marking this as **partial-closed**: the documented sslmode fix is in place; the pooler-reachability piece never had a confirmed root cause.

### Gap G-016 — omnilink-local-env-points-at-dev-neon-branch (BY DESIGN)
**Severity:** trivial (clarified after logging — the divergence is intentional, not a bug)
**Evidence:** `omnilink-backend/.env` `DATABASE_URL` points at the **development** Neon branch by design. Production (`api.omny.link` / `go.omny.link`) connects to the **main** Neon branch via the Railway prod env. Workflow: feature branches off `develop`, PRs merge to `develop` (Railway redeploys dev env), then fast-forward `main` → `develop` and push (Railway redeploys prod env). Each env has its own Neon branch.
**Proposed fix:** None — this is the intended setup. Document for future sessions (saved to memory: `project_omnilink_environments.md`).
**Status:** won't-fix (working as intended)
**Logged by:** backend-engineer (during omnilink-sprint-01 S-013 attempt)
**Logged date:** 2026-05-04
**Notes:** Initially logged as a config error after seeing zero Truckers rows in local; Aman clarified the two-environment split. Saved environment topology to claude memory so future sessions don't trip on it. Real implication: prod-side ops (data drops, schema reviews) must use Neon's web SQL editor in the prod project, not local scripts.

### Gap G-017 — script-uses-wrong-table-name-gs1_audit_logs
**Severity:** trivial
**Evidence:** `omnilink-backend/scripts/sprint01_test_data_drop.py` references `gs1_audit_logs` (plural) in DELETE statements; actual table per `app/models/gs1_audit_log.py::__tablename__` is `gs1_audit_log` (singular). The script would have errored on first non-empty run.
**Proposed fix:** Project-side. Single-character edit in `scripts/sprint01_test_data_drop.py` (drop the trailing `s`).
**Status:** fixed-in-a041f69 (script deleted entirely)
**Logged by:** backend-engineer
**Logged date:** 2026-05-04
**Notes:** Caught while reviewing the SQL before running it via Neon web editor. The web-editor SQL in the runbook already uses the correct singular form. Closed during Sprint 2 Stage 0 by deleting the script — its purpose is served (Truckers data drop ran via Neon SQL editor) and keeping a dead script with two latent bugs around adds risk for zero benefit.

### Gap G-018 — script-references-nonexistent-public-users-table
**Severity:** trivial
**Evidence:** `omnilink-backend/scripts/sprint01_test_data_drop.py` includes `DELETE FROM users WHERE id NOT IN (...)`. There is no `public.users` table in the app schema — user identity lives in Neon Auth (separate auth service the app integrates with via JWT), referenced only by UUID in `organization_members.user_id`. The DELETE would error.
**Proposed fix:** Project-side. Remove the `users` step from the script. The Sprint 1 brief assumed a `users` table existed in app schema; it doesn't. App-side cleanup is just `organizations` + `organization_members` + cascaded children.
**Status:** fixed-in-a041f69 (script deleted entirely; same commit as G-017)
**Logged by:** backend-engineer
**Logged date:** 2026-05-04
**Notes:** When/if Neon Auth records need cleanup, that's a separate operation in the Neon Auth dashboard, not a SQL DELETE. Closed during Sprint 2 Stage 0 alongside G-017.

### Gap G-014 — omnilink-baseline-ruff-noise
**Severity:** trivial (project-specific)
**Evidence:** ~688 ruff findings on the diff against `develop` (most pre-existing on `develop`); ~1259 across the whole repo. Top categories: UP045 (500) `Optional[X]` → `X | None`, UP017 (23) tz import, PLC0415 (21) deferred imports.
**Proposed fix:** Project-side. Run `ruff check --fix --unsafe-fixes app tests` once, review the diff, commit. Then enable lint as a required CI gate.
**Status:** open
**Logged by:** backend-engineer
**Logged date:** 2026-05-04
**Notes:** Sprint 1's CI workflow runs lint as `continue-on-error: true` until this is cleaned up.

---

## Discovered during omnilink-sprint-02 Stage 0

### Gap G-019 — omnilink-integration-suite-bit-rot-uncovered-by-G013-fix
**Severity:** moderate (project-specific; blocks promoting integration to a required CI gate)
**Evidence:** With G-013's conftest fix in place (commit 85a5869 — alembic upgrade head bootstrap), the integration suite RUNS for the first time in months. Local run with the same env CI uses (`postgres:16-alpine` at localhost, `redis:7-alpine`, dev env vars): **26 passed, 18 failed, 22 errored** in 35.21s. All failures pre-date Sprint 2 Stage 0; they were hidden behind `continue-on-error: true`. Two distinct categories:

1. **~22 errors — fixture/model drift**: tests in `test_redirects.py`, `test_gs1.py`, `test_campaigns.py` create `Campaign` / `ShortLink` rows without `organization_id`, but migration `eca77b8c65d0` ("Make organization_id NOT NULL on campaigns and short_links", from EP-09 multi-tenancy work) added the constraint. Sample error: `null value in column "organization_id" of relation "campaigns" violates not-null constraint`. Every campaign-creating test fixture needs an org seeded first.
2. **~18 failures — schema/payload + assertion drift**:
   - `POST /campaigns` returns 422 for the legacy test payloads — Pydantic schema gained / changed required fields since the tests were written.
   - `tests/integration/test_health.py::test_health_endpoint` asserts `{status, environment, debug}` in the response body, but the endpoint deliberately returns just `{"status": "healthy"}` (security-hardening: "no sensitive data exposed", per `app/main.py:178-182`).

**Proposed fix:** Project-side. Standalone PR (do NOT bundle into Sprint 2 RBAC tickets). Estimated 6–12h:
- Update integration test fixtures (`auth_client`, the per-test setup helpers in `test_campaigns.py` / `test_redirects.py` / `test_gs1.py`) to seed an `Organization` and `OrganizationMember` for the test user, then pass `organization_id` to every `Campaign` / `ShortLink` factory call.
- Walk each failing assertion against the current schema/endpoint contract; either update the test or, where the test reflects a still-valid invariant the endpoint regressed on, fix the endpoint.
- Once the suite is green, drop `continue-on-error: true` from `.github/workflows/ci.yml::integration-tests` and update the job name back to "Integration tests (required gate)".

**Status:** open
**Logged by:** backend-engineer (during Sprint 2 Stage 0, after G-013 conftest fix exposed the underlying suite state)
**Logged date:** 2026-05-04
**Notes:** Sprint 2's RBAC matrix tests (ticket 2.14) are NEW tests in `tests/integration/test_rbac_matrix.py` and won't be blocked by G-019 — they'll seed orgs + members per the current pattern from the start. Promoting integration to a required gate is what G-019 unlocks; the alembic-bootstrap piece (G-013 proper) is already done.


---

## Discovered during omnilink-sprint-03 kickoff (P0 incident)

### Gap G-020 — cross-repo-consumer-migration-rule-missing
**Severity:** high (process gap — caused a real ~15.5h customer-facing outage on the dashboard)
**Evidence:** `omnilink-backend` Sprint 2 (PR #3, merged 2026-05-05 02:04:46Z, commit `808ad69`) changed five paginated GET endpoints to `PaginatedResponse[T] = {items, total, next_cursor}`. The dashboard repo (`omnlink-frontend`) typed the responses as bare arrays. Sprint 2's PRD R2 named the consumer-migration risk but the team excluded `frontend-engineer` from the role mix and had no compensating gate. Backend shipped; dashboard broke in prod with `Uncaught TypeError: q.map is not a function` on every authenticated list view (campaigns, short links, organizations, team roster). Recovery: `omnlink-frontend` PR #1 (commit `c5c13b9`), Vercel prod deploy at 2026-05-05 17:31:33Z, ~15.5h impact window. Truckers Routine redirects unaffected.

**Proposed fix:** Team-level. `team/rules/common/git-workflow.md` gets a new section `## Cross-repo response-shape changes` requiring: (a) PM identifies consumed endpoints in PRD; (b) if the sprint changes a response shape / status code / breaking schema on a consumed endpoint AND excludes frontend-engineer from the role mix, the PRD must specify the consumer migration plan; (c) DevOps gates ship on either a parallel consumer PR co-deployed OR a manual smoke against consumer prod build verifying the new shape works. Maintainer drafts; PM + DevOps review.

**Status:** fixed-in-703c448
**Logged by:** orchestrator (during omnilink-sprint-03 kickoff, after recovering from the regression)
**Logged date:** 2026-05-05
**Notes:** Brief at [`improvement-briefs/cross-repo-consumer-migration-rule.md`](improvement-briefs/cross-repo-consumer-migration-rule.md). Landed in commit 703c448 (2026-05-05) before Sprint 4 architect dispatch — added `## Cross-repo response-shape changes` section to `team/rules/common/git-workflow.md` naming trigger, gate, owners (PM at PRD-time / Architect at design-time / DevOps at ship-time), and two enforcement mechanisms (PR-description checkbox + sprint-level PRD section). Cross-linked from `team/rules/common/communication.md`. Updated `team/workflows/greenfield-feature.md` Customization to gate the "drop frontend-engineer" path on no-consumer-impact rather than offering a frictionless drop. Cross-checked against Sprint 4: rule catches 4.2 (`X-Workspace-ID` header semantic), 4.11 (per-role anonymized export shape), and any F-5 backend-only folding pattern.


### Gap G-021 — subagent-bash-sandboxed-to-project-working-tree
**Severity:** moderate (recurs on every cross-repo sprint; works around easily but adds friction)
**Evidence:** Stage 3 backend dispatch on omnilink-sprint-03 hit a hard wall: spawned `backend-engineer` subagent reported `/Users/amansingh/Documents/marketing_projects/omnilink-backend` is outside its Bash sandbox. It could Read at known absolute paths but couldn't `ls`/`find` to discover structure, run `pytest`, run `alembic`, `git commit`, or `gh pr create`. The orchestrator (main Claude Code session) has no such restriction — already drove the omnlink-frontend hotfix end-to-end including push + PR creation. The asymmetry is structural to subagent isolation, not per-role-config.

**Repro:** any Agent({...}) dispatch in this repo where the subagent needs to operate on a sibling project under `/Users/amansingh/Documents/marketing_projects/`. Sprint 3 was the first time we needed this; Sprint 4 (API keys + rate limit) and Sprint 16 (branded domains) will hit it again.

**Proposed fix:** team-level. Three options for the maintainer to evaluate in a brief:
1. **Document the pattern**: "Cross-repo implementation work runs as orchestrator-drives, not subagent-drives. Subagents are for design/review/planning artifacts inside theaiteam workspace; main session executes against sibling repos." Codify in `team/rules/common/team-improvement.md` or a new `team/rules/common/multi-repo-execution.md`.
2. **Pre-stage the repo**: orchestrator copies/symlinks the target repo into `workspace/<slug>/staging/` before subagent dispatch so it's inside the sandbox. Adds ~30s setup; recovery is `rsync` back. Risk: working-tree drift.
3. **Broaden subagent permissions** via Claude Code settings (if possible): `additional-bash-roots` style config. Investigate what's available; this would be the cleanest fix.

**Status:** open
**Logged by:** orchestrator (during omnilink-sprint-03 Stage 3 dispatch)
**Logged date:** 2026-05-05
**Notes:** Sprint 3 unblocked by orchestrator-drives-directly fallback (Aman approved 2026-05-05). The fallback works but burns the main session's context window on implementation work; a fresh subagent would have ~150K headroom while the orchestrator has whatever's left after PM + architect + security + frontend-hotfix orchestration. Not a Sprint 3 blocker, but the maintainer should pick option (1) or (3) before Sprint 4 to keep the workflow scalable.


### Gap G-022 — ai-legal-doc-drafter-skill-or-agent
**Severity:** moderate (recurring need; current workaround is "inline AI prompt during PM intake")
**Evidence:** Sprint 4 (kickoff 2026-05-05) needs a DPA template drafted but Aman explicitly opted out of paying for outside legal counsel at this stage. Current workaround: PM drafts via inline AI during Stage 1 with disclaimers. Sprint 25 will need an SCC doc using the same `OrganizationLegalDoc` model. Sprint 16+ may need privacy policy / ToS updates per branded-domain rollout. Without a structured helper, every legal-doc need re-derives the prompt + disclaimer pattern from scratch and risks inconsistency.

**Proposed fix:** team-level. Maintainer evaluates two shapes:

1. **As a skill** at `team/skills/legal/legal-doc-drafter/` — invocable from any role (PM, marketing-strategist, security-engineer). Templates: DPA, privacy policy, ToS, SCC, GDPR-Article-30 record. Each template has structured input schema (data controller, sub-processors, retention period, lawful basis, etc.) and outputs markdown. Footer disclaimer baked in: "AI-drafted, not lawyer-reviewed; consult counsel before final use."

2. **As an agent role** at `team/roles/legal-doc-drafter.md` — focused agent invoked when a sprint needs a legal artifact. Pros: separates legal context from PM's product context; cons: another role to maintain; legal docs are infrequent enough that a skill might suffice.

Maintainer's call which shape. Skill is lighter; agent is more separation-of-concerns.

**Status:** open
**Logged by:** orchestrator (during omnilink-sprint-04 kickoff prep)
**Logged date:** 2026-05-05
**Notes:** Sprint 4 itself uses the inline-AI workaround; not blocked on this gap. The improvement brief should land before Sprint 25 (EU residency / SCC), which is the next sprint that needs another legal doc. If Aman engages outside legal counsel before then, this gap is partially obviated (counsel reviews, AI drafts) but the structured-input-schema value remains.


### Gap G-023 — railway-cloudflare-only-ingress-not-enforced
**Severity:** moderate (project-specific; security hardening, not a current incident)
**Evidence:** OmniLink prod traffic goes Cloudflare → Railway → FastAPI. Railway sets `CF-Connecting-IP` correctly when traffic comes through Cloudflare, and Sprint 4's IP-helper rewrite (P1-H-01 fix) prefers that header. **However**, Railway also exposes auto-generated subdomains (`web-production-XXXXX.up.railway.app` for prod; `web-production-53a8c.up.railway.app` for dev) that bypass Cloudflare entirely. A request hitting the Railway-direct domain has no `CF-Connecting-IP` (Cloudflare didn't set it), so the helper falls back to XFF — which an attacker can spoof since Railway's proxy on its own doesn't strip client-supplied XFF. Net effect: Sprint 4's spoofing fix is end-to-end secure ONLY when traffic actually goes through Cloudflare; the Railway-direct path remains a one-header-spoof bypass.

**Proposed fix:** Project-side, separate sprint. Three options:
1. **Railway IP allowlist** — restrict Railway ingress to Cloudflare's published IP ranges (~17 CIDRs). Cloudflare publishes the list at https://www.cloudflare.com/ips/ . Add at Railway's network/firewall settings if Railway supports IP allowlist (verify capability). Refresh allowlist quarterly via a small cron / GitHub Action.
2. **Cloudflare Authenticated Origin Pulls (mTLS)** — Cloudflare presents a client cert when calling origin; Railway/FastAPI rejects requests without it. Most robust but heavier setup; needs Cloudflare's free origin cert + nginx/reverse-proxy on Railway side.
3. **Application-layer header check** — in FastAPI middleware, reject requests where `CF-Connecting-IP` is missing AND the request appears to be from outside the Railway-internal proxy. Cheapest but adds app-layer auth; only catches HTTP-level bypasses, not TCP-level scans.

Recommend option 1 (Railway IP allowlist) for minimum operational complexity. Pair with a Sprint-4 mitigation: Sprint 4's helper logs a `WARNING` when `CF-Connecting-IP` is missing on a request, so we'll see if anyone is actually hitting the Railway-direct domain in practice before committing to the lockdown work.

**Status:** open
**Logged by:** orchestrator (during omnilink-sprint-04 Phase 1 sign-off)
**Logged date:** 2026-05-05
**Notes:** Not blocking Sprint 4 ship. Sprint 4's defensive coding (CF-Connecting-IP preference + XFF-depth fallback + missing-CF-header warning log) is sufficient for the customer-facing path. G-023 is the long-term hardening that closes the bypass entirely. Schedule for a post-Sprint-6 DevOps hardening sprint or fold into Sprint 16 (branded domains) since that sprint touches custom-domain ingress configuration. Truckers Routine traffic is already correctly Cloudflare-fronted so this gap doesn't affect them today.
