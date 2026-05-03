# Documentation (always follow)

## What every repo has

- `README.md` — what it is, how to run locally, how to deploy, where the docs are
- `CHANGELOG.md` — Keep-a-Changelog format
- `LICENSE` (or explicit "internal use only" note)
- `.env.example` if any env vars are read
- `docs/` for anything beyond a one-pager

## What a good README answers

1. **What is this?** One sentence.
2. **Why does it exist?** One paragraph.
3. **Quickstart**: clone → install → run, copy-pasteable
4. **Configuration**: env vars with descriptions and example values
5. **Architecture**: brief; link to a deeper doc if needed
6. **Tests**: how to run them
7. **Deployment**: how it gets to production (or link to the runbook)
8. **Troubleshooting**: top 3 issues new contributors hit

## API docs

- OpenAPI 3.x spec is the source of truth for endpoint shapes.
- Narrative docs explain *when* and *why* to use each endpoint.
- Every endpoint has a curl example AND at least one SDK example (in the dominant client language).
- Errors are documented with codes, descriptions, and recovery actions.

## Changelog

- Keep-a-Changelog format: Added / Changed / Deprecated / Removed / Fixed / Security
- Entries are user-facing. "Added rate limiting on /api/links" not "wire ratelimiter".
- Update as part of the release commit, not as a separate task that gets forgotten.

## Inline docstrings

- Public functions / classes get docstrings.
- Docstrings answer: what does this do (one sentence), when do I use it, what does it return, what does it raise.
- No PHP-doc-style "@param string foo The foo." Use the type system.
- Internal helpers don't need docstrings. Names should suffice.

## Architecture Decision Records (ADRs)

- One file per decision: `workspace/<slug>/plans/adr/NNNN-title.md`
- Sections: Context, Decision, Consequences, Alternatives considered.
- Write when the decision is non-obvious or you'd want to remember the reasoning in 6 months.
- Don't write for trivial choices; do write for stack picks, schema designs, auth approaches.

## Runbooks

- One per service or major flow.
- Sections: deploy, rollback, common alerts (with playbook), escalation, dependencies.
- Tested. If it tells you to "ssh into prod" and we don't allow that, it's wrong.
- Lives in the target repo (`docs/runbook.md`) so it's versioned with the code.

## Style

- Active voice, concrete examples, present tense.
- Don't pad. Don't apologize ("This document attempts to..."). State.
- Audience-appropriate: developer docs aren't marketing copy and vice versa.
- Test instructions by following them with fresh eyes.
