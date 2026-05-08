---
slug: omnilink-sprint-04.4.1-rate-limit-size-currentauth
type: bug-fix
priority: P3
deadline:
target_repo: /Users/amansingh/Documents/marketing_projects/omnilink-backend
ai_provider: claude-code
---

# Project Brief — Sprint 4.4.1: rate_limit_size sibling of G-027 (G-028)

## 1. Goal

Close G-028 — the sibling carry-forward of G-027 in `rate_limit_size`. Mechanical mirror of [Sprint 4.4 ADR-0001](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md), applied to the same closure shape in a different factory. Zero live callers means zero behavior risk; the structural defect just stops existing.

After this ships, the Sprint 4.2 ADR-0001 audit-shape thread is fully closed end-to-end. No remaining JWT-only sub-deps under `app/middleware/` or `app/core/` outside the documented STAY-JWT-ONLY type aliases.

## 2. Severity

**P3.** Zero live callers exercise the broken branch today (`rate_limit_size` is only called from `bulk.py:146` with `identifier_type="org"`, NOT `"user"`). The defect is structural-correctness, not active failure. No customer impact, no revenue impact.

Severity-up trigger: if the bug-fix branch surfaces an unexpected live caller (e.g., a forgotten test fixture or a recently-added route), reclass to P2 and treat scope-expansion as a normal stop-and-surface event.

## 3. Bug

[`omnilink-backend/app/middleware/rate_limit.py:543-552`](../../marketing_projects/omnilink-backend/app/middleware/rate_limit.py#L543) — `rate_limit_size` factory's `_check` closure for `identifier_type="user"`:

```python
elif identifier_type == "user":
    from app.core.security import get_current_user as _get_user
    async def _check(
        request: Request,
        current_user: dict = _Depends(_get_user),  # JWT-only — same shape as G-027
    ) -> None:
        if not getattr(request.state, "user_id", None):
            request.state.user_id = current_user["user_id"]
        await _do_check(request)
```

`_get_user` is JWT-only per Sprint 4.2 ADR-0001. Any future caller that wires `rate_limit_size(..., identifier_type="user")` on an endpoint would 401 every API-key request — identical to the pre-G-027 billing routes.

## 4. Repro

No live caller; structural-only repro:

```bash
cd /Users/amansingh/Documents/marketing_projects/omnilink-backend
grep -A5 'identifier_type == "user"' app/middleware/rate_limit.py
# Two hits: rate_limit:400 (FIXED in c4ddad6) + rate_limit_size:543 (G-028 — this brief)
```

The architect's [Q-arch-S44-2 grep](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/system-design.md#2-q-arch-s44-2-audit-result--other-middleware-closures--helper-modules) is the canonical evidence.

## 5. Fix shape (locked at brief-time)

Mirror Sprint 4.4 ADR-0001's diff exactly, applied to lines 543-552 instead of 400-409:

```diff
 elif identifier_type == "user":
-    from app.core.security import get_current_user as _get_user
+    from app.core.dependencies import get_current_auth as _get_auth

     async def _check(
         request: Request,
-        current_user: dict = _Depends(_get_user),
+        auth=_Depends(_get_auth),
     ) -> None:
         if not getattr(request.state, "user_id", None):
-            request.state.user_id = current_user["user_id"]
+            request.state.user_id = str(auth.user_id)
         await _do_check(request)
```

Same defensive write retention per [Sprint 4.4 D-004](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/decisions.md#d-004) — load-bearing for test-environment `dependency_overrides[get_current_auth]`, idempotent in production.

## 6. Success criteria

- [ ] `rate_limit_size` factory's `_check` closure for `identifier_type="user"` migrated per § 5.
- [ ] Final integration suite stays at **184/0/0** (Sprint 4.4 baseline). No new tests required — the architect-time grep + the existing `test_rate_limit_currentauth.py` (covering the sibling factory's pattern) is sufficient evidence.
- [ ] Q-arch-S44-2 grep re-run post-fix returns ZERO `_Depends(_get_user)` / `_Depends(get_current_user)` hits in `app/middleware/`. Audit-shape thread fully closed.
- [ ] G-028 closed in `_team-gaps.md` with `**Status:** closed-fixed-in-<sha>`.

## 7. Stack and constraints

- **Same as Sprint 4.4** — Python 3.12, FastAPI, no new dependencies, literal-zero CI gate (184/0/0).
- **No new env vars.**
- **Cross-repo gate:** "no consumer-impacting change" — zero callers means zero contract surface.
- **Out of scope:**
  - F-2 / F-3 (Sprint 4.2 carries; rare-edge-case auth bugs; separate brief if/when prioritized)
  - Lint baseline (1552 ruff errors; standalone hygiene sprint)
  - 38 untracked `docs/plans/*` files (separate triage)
  - Sprint 5 enhanced event model (next sprint)
  - Adding a synthetic integration test for the `user` branch (would test dead code; provides no value beyond the architect-time grep)

## 8. Roles needed

- **Required:** product-manager (Stage 1 triage, ~5min — sev confirm + lock the scope to G-028 only), backend-engineer (Stage 2-3 root-cause + mirror diff + verify suite stays 184/0/0), security-engineer (Stage 4 conditional check — scoped-to-precedent per Sprint 4.4 ADR-0001), devops-engineer (Stage 5 ship + close G-028).
- **Excluded:** architect (the migration shape is already locked in Sprint 4.4 ADR-0001; no new design work), frontend-engineer / mobile-engineer / designer (no UI), QA-engineer (Stage 3 regression test step is N/A — no failing test to write since zero live callers; backend's grep + suite re-run replaces it), marketing-strategist (no externally-visible behavior change), technical-writer (no docs surface).
- **Lead:** product-manager.

## 9. Workflow

[`bug-fix`](../team/workflows/bug-fix.md) workflow, NOT greenfield-feature. Reasons:
- Mechanical mirror of an already-shipped, already-reviewed migration (`c4ddad6`).
- Zero new design surface; ADR-0001 is the spec.
- Severity P3; ceremony scales accordingly.
- Stage 4 security check is **scoped-to-precedent** (Sprint 4.3 D-001 lighter-ceremony pattern): the diff matches `c4ddad6`'s post-D-004 shape line-for-line; security re-confirms shape match without re-running full Phase 1/2 hard gates.

Sprint 4.4 brief § 4 hard constraint ("full Phase 1 + Phase 2") was scoped to G-027's load-bearing migration. G-028 is **not load-bearing** (zero callers). Lighter ceremony is correct here per Sprint 4.3 D-001 precedent.

## 10. Effort estimate

**~30-45min total.**

- Stage 1 (PM triage): 5min
- Stage 2 (root cause): N/A — already documented in Sprint 4.4 system-design.md § 2 + § 10
- Stage 3 (fix + verify): ~15min — apply diff, run integration suite, re-run Q-arch-S44-2 grep
- Stage 4 (security scoped check): ~10min — diff-shape-match-vs-c4ddad6 verification
- Stage 5 (ship): ~10min — PR, CI, squash-merge, ff main, close G-028 in `_team-gaps.md`

Hard 1h gate (lighter than Sprint 4.4's 2h gate, scaling to lower scope). If the fix surfaces an unexpected live caller or a deeper rate_limit_size ↔ dispatcher ordering issue, surface and re-scope.

## 11. Context and references

- **Predecessor:** Sprint 4.4 (`omnilink-sprint-04.4-rate-limit-currentauth`, shipped 2026-05-08 at `c4ddad6`, PR [#11](https://github.com/simanam/OmniLink/pull/11)). Closed G-027 + R-4.3-1; surfaced G-028 at Stage 2 Q-arch-S44-2 audit.
- **Reference docs:**
  - [`_team-gaps.md` § G-028](../_team-gaps.md#gap-g-028--rate_limit_size-factory-_get_user-sub-dep-jwt-only-g-027-sibling) — full evidence + fix shape
  - [Sprint 4.4 ADR-0001](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/adr/0001-rate-limit-middleware-migration-shape.md) — locked migration shape (post-D-004)
  - [Sprint 4.4 system-design.md § 2 (Q-arch-S44-2)](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/system-design.md#2-q-arch-s44-2-audit-result--other-middleware-closures--helper-modules) — audit evidence
  - [Sprint 4.4 D-004](../workspace/omnilink-sprint-04.4-rate-limit-currentauth/plans/decisions.md#d-004) — defensive-write retention rationale
- **Branching:** standard (`develop` integration, `main` deploy source, ff `main` ← `develop`).

## 12. Notes

- Sprint type: `bug-fix` (lighter ceremony). One PR. One commit expected (the migration diff). Maybe a second commit if I split the comment update from the diff for review clarity, but lean single commit.
- Branch: `fix/sprint-04.4.1-rate-limit-size-currentauth` (note `fix/` prefix per `git-workflow.md` for bug fixes, NOT `feat/`).
- After this ships, **Sprint 5 (enhanced event model)** is unblocked. The auth-coverage / audit-shape thread is closed end-to-end.
