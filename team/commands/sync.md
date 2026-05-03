---
name: sync
description: Refresh provider-specific configs from the team/ source-of-truth. Run after editing roles, skills, rules, or commands.
type: command
args: [optional: --provider <claude-code|codex|gemini|all>]
---

# /sync [--provider <name>]

Run [adapters/sync-all.sh](../../adapters/sync-all.sh) (or a single-provider sync) to regenerate per-provider configs from `team/`.

## Steps

1. Determine target: argument or default to `all`.
2. Run the sync script:
   - All: `./adapters/sync-all.sh`
   - Single: `./adapters/<provider>/sync.sh`
3. Report the diff: which files were created, updated, removed.

## When to use

- After editing any file in `team/`
- After vendoring new content from an upstream
- After switching the active provider for a project

## Anti-patterns

- Editing `.claude/`, `.codex/`, or `.gemini/` files directly. They are generated.
- Running sync without first running it in dry-run mode if the diff might be large.
