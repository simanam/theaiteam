# Gemini adapter

Generates Gemini CLI configs from [team/](../../team/).

## Status

**Starter.** Gemini CLI's expected file layout varies by version. This adapter:

1. Writes `GEMINI.md` at the repo root pointing to the canonical content.
2. Writes `.gemini/context.md` with an index of roles, skills, and rules.

Extend [sync.sh](sync.sh) for your specific Gemini CLI version (e.g., system-instruction files, `.gemini/settings.json`).

## How to run

```bash
./adapters/gemini/sync.sh
```

## To extend

Most users of Gemini CLI use one of:
- A custom system prompt file (point Gemini at the concatenated content like AGENTS.md)
- A `.gemini/system-instructions/` directory with multiple files

The simplest extension is to mirror the Codex adapter — concatenate everything into `GEMINI.md` instead of just an index.

## Editing convention

Edit `team/`. Re-run sync.
