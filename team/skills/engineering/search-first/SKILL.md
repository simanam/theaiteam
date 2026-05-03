---
name: search-first
description: Search the codebase before writing code so you reuse, not reinvent.
type: skill
when-to-use: Before starting any non-trivial code change. Especially before adding a new utility, helper, or pattern.
related-skills: [engineering/refactoring, meta/repomix-ingest]
---

# Search-first

## Why
Most production codebases already have the helper you're about to write. Duplicating it makes the code worse and the next change harder.

## Steps

1. **Identify the concept.** What are you about to build? "URL slug generator." "Date-range picker." "Retry-with-backoff."
2. **Search by name.** Grep for plausible function/class names: `grep -r "slug" src/`, `grep -r "retry" src/`.
3. **Search by usage.** Grep for the import string of common deps. If we already use `bullmq` or `arq` somewhere, use it; don't add a second queue.
4. **Search the deps.** Look at `package.json` / `pyproject.toml` / `Package.swift`. Existing libs are probably enough.
5. **Search recent PRs.** `git log --grep "slug"` — the pattern may already have been discussed.
6. **Decide.** Reuse, extend, or write new. If new, note in the PR why existing options didn't fit.

## Checklist before writing new

- [ ] Searched the repo for the concept by name
- [ ] Searched for the concept by usage pattern
- [ ] Reviewed the dependency list for existing libs
- [ ] Checked recent PRs and ADRs
- [ ] Documented why the new code is necessary if no reuse possible

## Pitfalls

- Searching only for exact match. Use partial substrings, related concepts.
- Skipping the dep list. The lib is already paid for; use it.
- Reusing something that *almost* fits and bending it. If the fit is forced, write new (and explain why in the PR).
