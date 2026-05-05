# Git workflow (always follow)

## Branches

- Default branch: `main`. Always deployable.
- Feature branches: `feat/<slug>-<short-desc>` e.g., `feat/link-shortener-mvp-rate-limit`
- Bug fixes: `fix/<short-desc>`
- Refactors: `refactor/<scope>`
- Don't push to `main` directly except via merged PR.

## Commits

- Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `ci:`, `perf:`, `style:`
- Subject line ≤ 70 chars, imperative ("add", not "added").
- Body explains *why*, not *what*. Diff shows the what.
- One logical change per commit. Refactors separate from features.
- Co-author trailers when appropriate.

## Pull Requests

- One feature / fix per PR. Big features → multiple PRs ("scaffold", "wire endpoint", "add tests", "wire UI").
- PR title: same conventions as commit subject. Keep ≤ 70 chars.
- PR body must include:
  - **Summary** (1–3 bullets): what changed and why
  - **Test plan**: how the reviewer (or you) verified it
  - **Screenshots / video** for any UI change
  - **Linked story IDs** from `workspace/<slug>/plans/stories.md`
- Link to the brief and PRD where relevant.

## Cross-repo response-shape changes

Backend ships and frontend breaks in prod is the most expensive bug shape we have. This rule exists because we lived it (~15.5h customer-facing dashboard outage, 2026-05-05 — see [`workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md`](../../../workspace/omnilink-sprint-03/artifacts/devops/dashboard-r2-incident.md)).

### Trigger

Any change that, on an endpoint a consumer depends on, does any of:

- Alters the response body shape (bare array → wrapper object, renames a top-level key, changes a field's type).
- Changes a status code that consumers branch on (200 → 204, 200 → 202, etc.).
- Changes a request contract (new required header, new required field, removed/renamed query param).
- Removes or renames an endpoint, or splits one into many.

Consumers include: dashboard, mobile apps, MCP tools, marketing site, public SDKs, partner integrations, internal scripts that other roles depend on. **In doubt: treat the change as consumed.** False positives cost a checkbox; false negatives cost a prod outage.

### Gate

Backend cannot ship until **one** of these is true:

- **(a) Co-deploy gate**: a parallel consumer-migration PR is open, reviewed, and merge-ready in the consumer repo, and both ship in the same window.
- **(b) Manual smoke gate**: DevOps runs the consumer's prod build (or a representative production-like environment) against the new backend, hits every changed endpoint through the consumer's actual code path, and posts the result in the ship checklist before backend merge to main.

A backend-internal smoke (curl, Postman) is **not** the manual smoke gate. The point is to catch the consumer's typed assumptions, not the wire format.

### Owners

- **PM at PRD-time**: identifies the consumed endpoints in the PRD. Section title: "Consumed endpoints + migration plan". For each changed endpoint: name the consumers, name the gate (a or b), name who owns each side. If the sprint excludes `frontend-engineer` from the role mix AND any item in this section is non-empty, the PRD must specify the consumer-migration plan inline — gate (b) is the default and PM names the DevOps owner.
- **Architect at design-time**: flags any new contract (e.g. `X-Workspace-ID` semantic, new auth dependency) as a future consumer-migration trigger even if no consumer reads it yet. Document in the system-design doc so the next sprint that wires the consumer inherits the context.
- **DevOps at ship-time**: closes the gate. Will not merge backend to main / promote to prod without the gate's checkbox ticked and evidence linked (consumer PR URL, or smoke transcript / screenshot).
- **Any role**: if you spot a consumed-endpoint change in a PRD or PR that doesn't have a gate plan, log it via [/log-gap](../../commands/log-gap.md) and surface to the orchestrator.

### Enforcement

Two concrete mechanisms; use both.

1. **PR description checkbox** (every PR that touches `app/api/`, route handlers, or response schemas):

   ```markdown
   ## Cross-repo impact
   - [ ] No consumer-impacting contract change.
   - [ ] Contract change present; gate (a) co-deploy — consumer PR: <url>.
   - [ ] Contract change present; gate (b) manual smoke — evidence: <link>.
   ```

   Reviewer ticks one. Unchecked = blocked.

2. **Sprint-level acceptance-criteria field**: every PRD has a "Consumed endpoints + migration plan" section. Even if empty (`None — no contract changes this sprint`), the section is present so the PM has actively considered it. Audit by maintainer if absent.

### Default rule

When in doubt, **treat the change as consumed**. The cost of a false positive (one extra checkbox) is an order of magnitude smaller than the cost of a false negative (production outage with the consumer's typed code crashing on render).

### Backend-only sprints (the sharp edge)

A "backend-only" sprint is the highest-risk shape for this bug, because the role mix excludes the engineer who would have caught it. If a sprint excludes `frontend-engineer` AND touches consumer-facing endpoint contracts, the PRD **must** specify the consumer migration plan up front, not as a post-ship follow-up. Examples that qualify:

- New required request header on an endpoint a consumer calls (e.g. `X-Workspace-ID`).
- Response body shape change (bare array → `PaginatedResponse[T]`).
- Per-role response variation (e.g. anonymized export shape for non-OWNER roles vs. raw shape for OWNER).
- Removed / renamed endpoint, or auth dependency change that affects how a consumer authenticates.

The PRD records who closes gate (b) and when (pre-ship, not post-ship).

## Review

- At least one role reviews before merge. For code, default reviewer is the architect or a peer engineer.
- Security review required when the PR touches auth, data export, file upload, or external integrations.
- Don't merge your own approval. (Solo dev exception: ship it, but document the deviation.)
- Address every comment. "Resolved" means "fixed or replied with a reason."

## Hygiene

- Rebase locally to keep history clean before opening PR. Don't rebase shared branches.
- Squash-merge for small features. Keep merge-commits for multi-PR features that benefit from history.
- Don't force-push branches with active reviews.
- Tag releases with semver. Update `CHANGELOG.md` in the same release commit.

## Operations

- Never `--no-verify` to skip hooks unless explicitly authorized.
- Never `git reset --hard`, `push --force`, `clean -f` without confirming with the user (or the orchestrator on solo work).
- Treat lockfile churn as suspicious — investigate before committing.

## Single-dev mode

When the team is being run by Aman alone (no human reviewer):
- Self-review the diff out loud (literally narrate it in chat) before merging.
- Keep PRs small enough that self-review is meaningful.
- Run the security skill on every PR touching auth or data.
