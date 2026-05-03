# Skills library — actual catalog

108 skills vendored from 5 upstream repos (see [THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md)).

## Structure

Each skill is a directory containing `SKILL.md` (instructions + frontmatter) and optional auxiliary files (scripts/, examples/, references/, METHODOLOGY.md).

```
team/skills/<domain>/<skill-name>/SKILL.md
team/skills/marketing/<bucket>/<skill-name>/SKILL.md
team/skills/<domain>/_trailofbits/<skill-name>/SKILL.md   ← CC BY-SA, kept grouped
```

## Catalog

### engineering/ (15 skills)
**From superpowers (MIT):**
- [test-driven-development](engineering/test-driven-development/SKILL.md)
- [systematic-debugging](engineering/systematic-debugging/SKILL.md)
- [verification-before-completion](engineering/verification-before-completion/SKILL.md)
- [requesting-code-review](engineering/requesting-code-review/SKILL.md)
- [receiving-code-review](engineering/receiving-code-review/SKILL.md)
- [finishing-a-development-branch](engineering/finishing-a-development-branch/SKILL.md)
- [using-git-worktrees](engineering/using-git-worktrees/SKILL.md)

**From anthropic-skills (Apache 2.0):**
- [mcp-builder](engineering/mcp-builder/SKILL.md) — build MCP servers
- [claude-api](engineering/claude-api/SKILL.md) — Claude API integration patterns

**From everything-claude-code (MIT):**
- [backend-patterns](engineering/backend-patterns/SKILL.md)
- [code-tour](engineering/code-tour/SKILL.md)
- [agent-introspection-debugging](engineering/agent-introspection-debugging/SKILL.md)
- [blueprint](engineering/blueprint/SKILL.md)
- [canary-watch](engineering/canary-watch/SKILL.md)

**theaiteam original:**
- [search-first](engineering/search-first/SKILL.md)

**`_trailofbits/` (CC BY-SA 4.0):** second-opinion, spec-to-code-compliance, fp-check, sharp-edges, modern-python

### architecture/ (2 skills)
- [api-design](architecture/api-design/SKILL.md) — ECC
- [architecture-decision-records](architecture/architecture-decision-records/SKILL.md) — ECC

### product/ (2 skills + 1 trailofbits)
- [brainstorming](product/brainstorming/SKILL.md) — superpowers
- [writing-plans](product/writing-plans/SKILL.md) — superpowers
- `_trailofbits/`: ask-questions-if-underspecified

### design/ (7 skills)
**From anthropic-skills:**
- [frontend-design](design/frontend-design/SKILL.md) — bold UI design avoiding generic aesthetics
- [brand-guidelines](design/brand-guidelines/SKILL.md)
- [canvas-design](design/canvas-design/SKILL.md) — visual art generation (.png/.pdf)
- [algorithmic-art](design/algorithmic-art/SKILL.md) — generative art via p5.js
- [theme-factory](design/theme-factory/SKILL.md)
- [web-artifacts-builder](design/web-artifacts-builder/SKILL.md) — React + Tailwind + Shadcn artifacts

**From everything-claude-code:**
- [accessibility](design/accessibility/SKILL.md)

### qa/ (4 skills + 2 trailofbits)
- [webapp-testing](qa/webapp-testing/SKILL.md) — Playwright (anthropic)
- [browser-qa](qa/browser-qa/SKILL.md) — ECC
- [ai-regression-testing](qa/ai-regression-testing/SKILL.md) — ECC
- [click-path-audit](qa/click-path-audit/SKILL.md) — ECC
- `_trailofbits/`: mutation-testing, property-based-testing

### security/ (12 trailofbits skills)
- `_trailofbits/`: variant-analysis, static-analysis, semgrep-rule-creator, semgrep-rule-variant-creator, supply-chain-risk-auditor, insecure-defaults, agentic-actions-auditor, audit-context-building, building-secure-contracts, constant-time-analysis, differential-review, zeroize-audit
- For role-level guidance see [team/roles/security-engineer.md](../roles/security-engineer.md) and the OWASP rule in [team/rules/common/security.md](../rules/common/security.md)

### devops/ (placeholder)
The DevOps role file ([team/roles/devops-engineer.md](../roles/devops-engineer.md)) is the primary guidance until domain-specific skills are added. Open candidates to vendor or write:
- ci-cd-setup
- deployment
- observability
- infra-as-code

### docs/ (2 skills)
- [internal-comms](docs/internal-comms/SKILL.md) — status reports, FAQs, newsletters (anthropic)
- [doc-coauthoring](docs/doc-coauthoring/SKILL.md) — anthropic

### marketing/ (40+ skills, all MIT from coreyhaines31)
**strategy/** (6): customer-research, launch-strategy, marketing-ideas, marketing-psychology, pricing-strategy, product-marketing-context

**content/** (8): cold-email, content-strategy, copy-editing, copywriting, email-sequence, image, social-content, video

**seo/** (7): seo-audit, ai-seo, site-architecture, schema-markup, programmatic-seo, competitor-alternatives, aso-audit

**cro/** (6): page-cro, signup-flow-cro, onboarding-cro, form-cro, popup-cro, paywall-upgrade-cro

**paid-ads/** (2): paid-ads, ad-creative

**growth/** (3): free-tool-strategy, lead-magnets, community-marketing

**analytics/** (1): analytics-tracking

**sales-revops/** (4): revops, sales-enablement, directory-submissions, competitor-profiling

### meta/ (7 skills)
- [skill-creator](meta/skill-creator/SKILL.md) — anthropic
- [agent-eval](meta/agent-eval/SKILL.md) — ECC
- [agentic-engineering](meta/agentic-engineering/SKILL.md) — ECC
- [subagent-driven-development](meta/subagent-driven-development/SKILL.md) — superpowers
- [dispatching-parallel-agents](meta/dispatching-parallel-agents/SKILL.md) — superpowers
- [executing-plans](meta/executing-plans/SKILL.md) — superpowers
- [writing-skills](meta/writing-skills/SKILL.md) — superpowers

## How a role finds and uses a skill

1. Role file lists `default-skills` in frontmatter (e.g., `engineering/test-driven-development`)
2. Role reads the skill's `SKILL.md` and follows its steps
3. Skill may reference auxiliary files in its directory (scripts, examples)
4. Skills compose: `code-review` skill may reference `static-analysis` skill

## Adding a new skill

```bash
mkdir team/skills/<domain>/<new-skill>
$EDITOR team/skills/<domain>/<new-skill>/SKILL.md
./adapters/sync-all.sh
```

Frontmatter pattern:
```yaml
---
name: kebab-case-name
description: When the user wants … / when a role needs to … (be specific — this drives auto-loading)
type: skill
when-to-use: <one paragraph>
related-skills: [other/skill-name]
metadata:
  version: 1.0.0
  origin: theaiteam | upstream:<repo-name>
---
```
