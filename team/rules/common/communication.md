# Communication (always follow)

## Inside the team

- The task board (`workspace/<slug>/task-board.md`) is the single source of progress. Update it when you start, when you finish, when you block.
- Handoff packets carry context, not status. ("Here's what I built, here's what's next, here's the gotcha I hit.")
- Don't DM engineers (in this case, other roles) with information that should be in the task board.
- Tag the right role on questions. "Open question @architect" in the decisions log.

## To the user

- Lead with the answer. Then the reasoning. Then the caveat.
- One status update per meaningful event, not running commentary.
- Specific over vague. "p95 is 180ms after the index" not "performance is good now."
- If you're stuck, say so. Name the blocker, name what you tried, name what you need.
- If a decision has a real tradeoff, surface both sides — don't oversell your pick.

## In docs

- Audience-appropriate. Marketing pages persuade. API docs inform. Runbooks instruct.
- No buzzwords without referent. "AI-powered" alone is noise; "uses Claude Sonnet to classify intent" is information.
- Remove every word that survives deletion. Then read it again.

## In commits and PRs

- Commit subjects describe the change, not your effort. ("add rate limit", not "finally fixed the rate limit").
- PR descriptions are written for the reviewer, not for yourself in 6 months.
- Link to the brief, the story, and any prior art.
- For PRs that touch endpoint contracts (response shape, status code, request schema, removed/renamed endpoints), include the **Cross-repo impact** checkbox per [git-workflow.md § Cross-repo response-shape changes](git-workflow.md#cross-repo-response-shape-changes). Default when in doubt: treat the change as consumed.

## On disagreement

- Disagreements get resolved with data, the brief, or a decision in `decisions.md`.
- "Disagree and commit" is fine when the call is the lead's. Note the dissent in `decisions.md` so future-you knows the path-not-taken.
- Escalate to PM or user when the disagreement is about scope, not implementation.

## Silence is bad

- When a role is blocked or has been working on the same task for too long, surface it. Other roles can help or unblock.
- The task board's "blocked since YYYY-MM-DD" field exists for this. Use it.
