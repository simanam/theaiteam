---
name: team-improvement
description: Maintainer-led workflow to keep theaiteam itself healthy. Audit, classify, fix or file, ship.
type: workflow
triggers: [team-improvement]
roles: [team-maintainer, technical-writer, security-engineer, product-manager]
---

# Workflow — Team improvement

The team operates on itself. This workflow runs when:
- A scheduled audit finds gaps
- The user invokes `/audit` or `/self-improve`
- An improvement brief in [improvement-briefs/](../../improvement-briefs/) is opened via `/kickoff`

## Stages

```
1. AUDIT             [team-maintainer]                      sequential
2. TRIAGE            [team-maintainer]                      sequential
3. AUTO-FIX BATCH    [team-maintainer]                      sequential
4. NON-TRIVIAL       [team-maintainer + relevant role]      sequential per brief
5. VERIFY            [team-maintainer]                      sequential
6. DOCS              [technical-writer]                     conditional
7. CLOSE             [team-maintainer]                      sequential
```

## Stage 1 — Audit

- Run [meta/team-audit](../skills/meta/team-audit/SKILL.md) — six passes (consistency, frontmatter, coverage, staleness, upstream drift, adapter drift)
- Append findings to `_team-gaps.md`
- Output: a populated gap log with severities and evidence

## Stage 2 — Triage

- Read every `open` entry in `_team-gaps.md`
- Confirm severity per [apply-self-fix](../skills/meta/apply-self-fix/SKILL.md) decision tree
- Sort: trivial first, then moderate (auto-fix candidates vs brief candidates), then structural (always brief)

## Stage 3 — Auto-fix batch

- Process trivial + high-confidence moderate
- One gap → one commit
- Run validation suite after each edit
- Update gap status to `fixed-in-<sha>`

## Stage 4 — Non-trivial (per brief)

For each filed improvement brief:
- Treat it like any project brief — invoke the relevant role(s) per the brief's deliverables
- Examples:
  - "Rewrite swift.md concurrency section for Swift 6" → maintainer drafts; security-engineer reviews if it touches security; tech-writer polishes
  - "Add devops/ skills (ci-cd-setup, deployment, observability)" → maintainer authors; devops-engineer reviews
  - "Add a new role for Data Engineer" → PM scopes; maintainer scaffolds; security reviews; tech-writer documents
- Each brief gets its own commits / PRs

## Stage 5 — Verify

After all fixes land:
- Run the audit again — every gap that was `open` should now be `fixed-in-<sha>`, `filed-as-improvement-<slug>`, or `won't-fix`
- Run `./adapters/sync-all.sh` and confirm no drift
- Run a smoke test: pick a role file at random, follow its `default-skills` links, confirm they resolve

## Stage 6 — Docs (conditional)

Triggered when changes affect:
- [README.md](../../README.md), [GETTING_STARTED.md](../../GETTING_STARTED.md), [CLAUDE.md](../../CLAUDE.md)
- [docs/how-it-works.md](../../docs/how-it-works.md)
- A role's responsibilities surfaced to users
- The brief template

Tech writer reviews and updates user-facing docs to match.

## Stage 7 — Close

- Maintainer writes a retro entry in [docs/plans/theaiteam-design.md](../../docs/plans/theaiteam-design.md)'s phase log: what was fixed, what was filed, what was deferred
- All `_team-gaps.md` entries from this run are in a closed state
- If any moderate/structural changes shipped, increment the team's "version" in [docs/plans/theaiteam-design.md](../../docs/plans/theaiteam-design.md)

## Failure modes

- **Audit pass fails to complete** → maintainer reverts to read-only mode, surfaces the failure, requires user direction
- **Auto-fix breaks adapter sync** → revert the edit, re-classify gap as moderate, file an improvement brief
- **Improvement brief reveals a deeper structural issue** → escalate to user; some changes need a real human call
- **Upstream sync check finds license-affecting drift** → ALWAYS file as improvement brief and surface to user; never auto-pull

## Customization

For a quick `/audit` run that doesn't apply fixes, only stages 1–2 execute.
For `/self-improve`, all stages execute.
For a single improvement brief invoked via `/kickoff <slug>`, only stages 4–7 execute.
