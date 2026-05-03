# Conventions (always follow)

## File frontmatter

All role, skill, command, and workflow files use YAML frontmatter:

```yaml
---
name: kebab-case-name
description: One sentence describing what this is for
type: role | skill | command | workflow | rule
# additional fields per type
---
```

Roles add: `tools`, `model`, `default-skills`.
Skills add: `when-to-use`, `related-skills`.
Commands add: `args`.
Workflows add: `triggers` (which brief types this matches), `roles`.

## File naming

- Lowercase, kebab-case: `product-manager.md`, `seo-audit.md`
- Skills nested by domain: `team/skills/<domain>/<skill>.md`
- Marketing nested twice: `team/skills/marketing/<category>/<skill>.md`
- ADRs: `workspace/<slug>/plans/adr/0001-pick-postgres.md` (zero-padded, kebab-case title)

## Markdown style

- H1 for the file title; H2 for major sections
- Bullets over prose for lists of considerations
- Code fences with language hints
- Link style: `[link text](relative/path.md)` for internal, full URL for external
- Tables for matrices (role × responsibility, severity × action, etc.)

## Workspace state

- Single source of progress: `workspace/<slug>/task-board.md`. Roles update it before handoff.
- Handoff packets: `workspace/<slug>/handoffs/<from>-to-<to>-<n>.md`
- Plans: `workspace/<slug>/plans/`
- Artifacts grouped by discipline: `workspace/<slug>/artifacts/{code,design,docs,marketing,qa,security,devops}/`

## Communication

- When a role hits ambiguity, **stop and write** — don't guess. Either:
  - Update `workspace/<slug>/plans/decisions.md` with an "open question" entry, OR
  - File a question in the task board with the affected role tagged
- Status updates go in the task board, not in handoff packets
- Handoff packets include: what's done, what's next, what to watch out for, links to artifacts

## Content style

- Active voice. "The endpoint returns X" not "X is returned by the endpoint."
- Specific over general. "150ms p95" not "fast."
- No marketing-ese in technical docs and vice versa.
- Show, don't list. One example beats three abstract bullets.
