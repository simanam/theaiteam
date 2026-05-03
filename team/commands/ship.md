---
name: ship
description: Open a PR for the current branch with a properly-formatted title, body, test plan, and links to brief/stories.
type: command
args: [optional: brief-slug]
---

# /ship [brief-slug]

You finished work on a feature branch. Open the PR.

## Steps

1. Confirm we're in a git repo and on a feature branch (not `main`).
2. Run `git status` — clean working tree expected. If dirty, commit first or warn the user.
3. Run `git log --oneline <base-branch>..HEAD` to see the commits on this branch.
4. Determine the brief-slug from arg or workspace context.
5. Read `workspace/<slug>/plans/stories.md` to find the story IDs this branch implements.
6. Run `git diff <base-branch>...HEAD` to see what's changed; summarize.
7. Push the branch if not already pushed: `git push -u origin <branch>`.
8. Open the PR using `gh pr create` with this format:

```
gh pr create --title "<conventional-commit-style title>" --body "$(cat <<'EOF'
## Summary
- 1–3 bullets: what changed and why

## Stories
- S-XXX
- S-YYY

## Test plan
- [ ] Unit tests added / updated for <X>
- [ ] Integration test for <Y>
- [ ] QA Playwright E2E covers <Z>
- [ ] Manually verified <flow> in browser/device
- [ ] Lint + type-check pass locally

## Screenshots / video
<embed if UI change>

## Brief
[briefs/<slug>.md](relative/path)

## Notes
- <anything reviewer should know>

🤖 Built by theaiteam
EOF
)"
```

9. Capture the returned PR URL. Add it to `workspace/<slug>/task-board.md` in the relevant story row.
10. Update the task-board: mark the implementing role's row as ready for QA + Security review.

## Anti-patterns

- Force-pushing over an already-reviewed branch
- Opening a PR without screenshots for UI changes
- Skipping the test plan ("ran it locally") — list specifics
- Including a million unrelated changes — split first if needed
- Pushing to `main` directly. Always a feature branch.
