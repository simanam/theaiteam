# Claude Code adapter

Generates `.claude/` from the [team/](../../team/) source-of-truth.

## What it produces

```
.claude/
├── agents/     ← symlinks to team/roles/*.md and team/agents-extra/*.md
├── skills/     ← symlinks to each team/skills/**/SKILL.md (flattened, prefixed by domain)
├── commands/   ← symlinks to team/commands/*.md
└── rules/      ← symlinks to team/rules/common/*.md
```

The root [CLAUDE.md](../../CLAUDE.md) is also picked up automatically by Claude Code.

## How to run

```bash
./adapters/claude-code/sync.sh
```

Or refresh all providers:

```bash
./adapters/sync-all.sh
```

## How Claude Code uses these

- **Agents**: invoked via `Agent({ subagent_type: "<name>" })` or shown in `/agents`.
- **Skills**: auto-loaded based on relevance to the current request, or invoked explicitly via `Skill({ skill: "<name>" })`.
- **Commands**: shown as slash commands, e.g. `/kickoff`, `/standup`, `/ship`.
- **Rules**: referenced in `CLAUDE.md` and applied as always-follow guidance.

## Editing convention

**Never edit `.claude/` directly.** Files there are symlinks. Edit `team/` instead and re-run sync.

## Adding new content

1. Add the file under `team/` in the right category.
2. Run `./adapters/claude-code/sync.sh`.
3. Verify the new symlink appeared in `.claude/`.
