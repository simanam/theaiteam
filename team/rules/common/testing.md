# Testing (always follow)

## Pyramid

| Level | What it tests | Speed | Volume |
|---|---|---|---|
| Unit | Pure logic, single function | Fast (ms) | Many |
| Integration | Cross-component, with real DB / real HTTP | Medium (sec) | Some |
| E2E | User flows in a real browser | Slow (sec-min) | Few |

Most tests should be unit. Integration covers the seams. E2E covers the most important flows only — too many is brittle.

## When to write tests

- New feature: write tests with the code.
- Bug fix: write the failing test first (proves the bug), then fix.
- Refactor: pre-existing tests must stay green; don't loosen them.
- Spike / throwaway: tests optional; mark code as throwaway.

## What to test

- Behavior, not implementation. The test should survive a refactor.
- Edge cases the spec mentioned (empty, max, unicode, concurrent).
- Edge cases the spec didn't mention but the QA engineer would (race, retry, partial failure).
- Public API only. Don't test private helpers — test through the public surface.

## What NOT to test

- Framework code (we trust FastAPI to route, React to render).
- Trivial getters / setters / single-property mappers.
- Mocked-everywhere code where the test is a tautology.

## Mocking policy

- Mock at network boundaries (HTTP, DB if expensive, third-party APIs).
- Don't mock your own internal modules — use them.
- Integration tests should hit a real DB (test container or local). Burned-by-mock-divergence is a real category of bug.

## Coverage

- Default threshold: 70% lines on new code; 80% on critical paths (auth, billing, data integrity).
- Coverage is a smell, not a goal. 100% coverage with tautologies is worse than 60% with meaningful assertions.
- Don't lower the threshold to make CI green.

## Naming

- Test files mirror code files: `service.py` → `test_service.py`.
- Test names describe the scenario: `returns_400_when_destination_is_invalid_url`.
- Avoid "test_works", "test_basic", "test_1".

## Fixtures

- Factory functions over fragile fixture chains.
- Don't share mutable state across tests.
- Tests run in any order. If they don't, fix the test.

## CI

- All tests run on every PR.
- Failed tests block merge.
- Quarantine flaky tests with a tracked issue and an owner. Fix or delete in two weeks.
