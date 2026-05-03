# Coding style (always follow)

## General

- Prefer clarity over cleverness. The next reader is a tired human (or a context-limited LLM).
- Names describe purpose, not type. `userId` not `userIdInt`. `linksByCampaign` not `dictOfLinks`.
- One concept per function. If the body needs a comment to explain "what this part does," extract it.
- No commented-out code. Use git.
- No dead code. Remove it; don't tag with `// removed`.
- No `// will fix later` without an issue link and an owner.

## Functions

- Pure where possible. Side effects live at the boundary.
- Early-return for guard clauses; reduces nesting.
- Small enough to read on one screen.
- Named for what they do, not what they're called from.

## Errors

- Fail loud at boundaries (input validation, external API responses).
- Catch only what you can handle. Re-raise or wrap with context.
- Never swallow exceptions silently. If you must `pass` / `catch (_)`, write a comment with why.
- Errors are values; design APIs that surface them clearly.

## Comments

- Default: don't write any.
- Write one when the *why* is non-obvious — a hidden constraint, a workaround, surprising behavior.
- Don't restate what the code does. Don't reference current task or callers ("for issue #123").

## Tests

- Test behavior, not implementation.
- Arrange / Act / Assert structure.
- One logical assertion per test (multiple `expect` is fine if they verify one outcome).
- Test names describe the scenario and expectation: `creates_short_url_for_valid_destination`.
- No flaky tests on main. Quarantine and fix, don't disable.

## Dependencies

- Don't add a dep for one function you can write in 20 lines.
- Pin versions in lockfiles.
- Audit license + maintainer activity before adding a new transitive dep tree.
- Update deps as a separate PR from features.

## Concurrency

- Async/await, not threads, for I/O.
- Don't share mutable state across tasks without a lock or a queue.
- Time out external calls. Default timeouts are not protection.

## Logging

- Structured (JSON) in services. Levels: error, warn, info, debug.
- Include a request/correlation id on every log line in request-handlers.
- Never log secrets, tokens, or PII not already in the URL/headers.
