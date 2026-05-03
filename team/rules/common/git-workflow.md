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
