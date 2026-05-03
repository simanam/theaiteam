# Codex adapter

Generates `AGENTS.md` at the repo root for OpenAI Codex CLI (and any other tool that reads the AGENTS.md convention).

## How to run

```bash
./adapters/codex/sync.sh
```

## What it does

Concatenates everything under [team/](../../team/) — roles, skills, rules, commands, workflows — into a single `AGENTS.md` with a table of contents and `<!-- BEGIN: -->` / `<!-- END: -->` markers around each source file so you can locate things.

## Note on size

This file gets large. Codex reads it on session start, but you may not want everything in context every turn. If your project is narrowly scoped (e.g., backend-only), consider:

1. Maintaining a custom `AGENTS.md.template` that only lists the roles/skills relevant to the project
2. Or using the Claude Code adapter (which uses lazy-loaded skills) instead

## Editing convention

**Never edit `AGENTS.md` directly.** It's regenerated. Edit `team/` and re-run sync.
