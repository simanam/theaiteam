# Python

## Toolchain

- Python 3.12+ preferred.
- Package manager: `uv` (preferred) or `poetry`. Never raw pip in repos.
- Lint + format: `ruff` (covers most of what flake8/black/isort did).
- Type check: `mypy --strict` or `pyright`. CI fails on type errors.
- Test: `pytest`. Async tests via `pytest-asyncio`.

## Types

- Type hints on every public function signature.
- `from __future__ import annotations` at top of files for forward refs.
- `TypedDict` / `dataclass` / `pydantic.BaseModel` for structured data.
- Avoid `Any`. Use `object` or a `Protocol` for duck-typed inputs.

## Style

- PEP 8 via ruff. 100-char line limit (not 79; modern terminals).
- f-strings for formatting. No `%` or `.format()` in new code.
- `pathlib.Path` over `os.path`.
- Context managers for resources.

## Async

- `asyncio` for I/O concurrency.
- `httpx.AsyncClient` for HTTP, not `requests`, in async contexts.
- `aioboto3` etc. when async-native libs exist.
- Don't mix `async` and sync I/O in the same code path without thinking.

## FastAPI specifics

- Pydantic models for request/response.
- Dependency injection for DB sessions, auth, rate limits.
- Background tasks for fire-and-forget; ARQ / Celery / RQ for proper queues.
- OpenAPI annotations: descriptions on every field, examples where helpful.

## Testing

- pytest with fixtures over setUp/tearDown.
- `factory_boy` or `pydantic_factories` for test data.
- Real DB via testcontainers or a local Postgres in CI.
- `freezegun` / `time-machine` for time-dependent tests.

## Common pitfalls

- Mutable default args (`def f(x=[])`) — don't. Use `None` + create inside.
- `print` in production code. Use logging.
- Catching `Exception` to mask bugs. Catch specific types.
- Lazy imports inside functions to "speed up startup" without measuring.
