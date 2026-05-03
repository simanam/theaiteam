# Third-party notices and attribution

This workspace vendors content from five upstream open-source projects. Each upstream's license is preserved in [licenses/](licenses/). When you copy or modify a vendored skill or agent, retain the attribution header (a short comment naming the upstream and license).

## Upstreams

### 1. Marketing Skills — Corey Haines
- **Source:** https://github.com/coreyhaines31/marketingskills
- **License:** MIT (see [licenses/MIT-marketingskills.LICENSE](licenses/MIT-marketingskills.LICENSE))
- **Vendored into:** [team/skills/marketing/](team/skills/marketing/) — bucketed into our category structure (strategy, content, seo, cro, paid-ads, growth, analytics, sales-revops)
- **Skills imported:** ~40 (copywriting, customer-research, launch-strategy, seo-audit, ai-seo, page-cro, paid-ads, ad-creative, free-tool-strategy, lead-magnets, analytics-tracking, revops, etc.)

### 2. Everything Claude Code — Affaan Mustafa
- **Source:** https://github.com/affaan-m/everything-claude-code
- **License:** MIT (see [licenses/MIT-everything-claude-code.LICENSE](licenses/MIT-everything-claude-code.LICENSE))
- **Vendored into:**
  - [team/agents-extra/](team/agents-extra/) — specialist agents complementing our 11 core roles (planner, code-reviewer, security-reviewer, tdd-guide, build-error-resolver, language reviewers, build resolvers)
  - [team/skills/](team/skills/) — selected skills (api-design, accessibility, browser-qa, agentic-engineering, ADRs, etc.)
  - [team/commands/](team/commands/) — slash entries (code-review, build-fix, feature-dev, quality-gate, plan, checkpoint, evolve, harness-audit)
  - [team/rules/languages-extra/](team/rules/languages-extra/) — additional language rule packs (cpp, csharp, dart, golang, java, perl, php, rust, web, zh)

### 3. Superpowers — Jesse Vincent
- **Source:** https://github.com/obra/superpowers
- **License:** MIT (see [licenses/MIT-superpowers.LICENSE](licenses/MIT-superpowers.LICENSE))
- **Vendored into:** [team/skills/](team/skills/) (engineering, meta, product domains)
- **Skills imported:** test-driven-development, systematic-debugging, verification-before-completion, requesting-code-review, receiving-code-review, finishing-a-development-branch, using-git-worktrees, subagent-driven-development, dispatching-parallel-agents, executing-plans, writing-skills, writing-plans, brainstorming

### 4. Anthropic Skills — Anthropic
- **Source:** https://github.com/anthropics/skills
- **License:** Apache 2.0 for most skills. See [licenses/Apache-2.0-anthropic-skills.LICENSE](licenses/Apache-2.0-anthropic-skills.LICENSE).
- **NOT vendored:** `pdf`, `docx`, `pptx`, `xlsx` (source-available, NOT open source — see upstream README)
- **Vendored into:** [team/skills/](team/skills/) (qa, design, docs, engineering, meta domains)
- **Skills imported:** webapp-testing, frontend-design, brand-guidelines, canvas-design, algorithmic-art, theme-factory, web-artifacts-builder, internal-comms, doc-coauthoring, mcp-builder, claude-api, skill-creator
- Upstream third-party notices preserved in [licenses/anthropic-skills.THIRD_PARTY_NOTICES.md](licenses/anthropic-skills.THIRD_PARTY_NOTICES.md)

### 5. Trail of Bits Skills — Trail of Bits
- **Source:** https://github.com/trailofbits/skills
- **License:** Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) — see [licenses/CC-BY-SA-4.0-trailofbits-skills.LICENSE](licenses/CC-BY-SA-4.0-trailofbits-skills.LICENSE)
- **License obligation:** Derivative works must attribute Trail of Bits and use a compatible license. Vendored skills are kept under `_trailofbits/` subdirectories for license clarity.
- **Vendored into:**
  - [team/skills/security/_trailofbits/](team/skills/security/_trailofbits/) — variant-analysis, static-analysis, semgrep-rule-creator, semgrep-rule-variant-creator, supply-chain-risk-auditor, insecure-defaults, agentic-actions-auditor, audit-context-building, building-secure-contracts, constant-time-analysis, differential-review, zeroize-audit
  - [team/skills/qa/_trailofbits/](team/skills/qa/_trailofbits/) — mutation-testing, property-based-testing
  - [team/skills/engineering/_trailofbits/](team/skills/engineering/_trailofbits/) — second-opinion, spec-to-code-compliance, fp-check, sharp-edges, modern-python
  - [team/skills/product/_trailofbits/](team/skills/product/_trailofbits/) — ask-questions-if-underspecified

## Tools (referenced, not vendored)

### repomix — Yamada Shuji
- **Source:** https://github.com/yamadashy/repomix
- **License:** MIT
- **How we use it:** Invoked at runtime via `npx repomix` from [tools/ingest.sh](tools/ingest.sh). Source code not included.

### Dify — LangGenius
- **Source:** https://github.com/langgenius/dify
- **License:** Modified Apache 2.0 (see upstream LICENSE for details on the additional commercial-use restriction)
- **How we use it:** Reference architecture only. No code or content vendored.

## awesome-claude-skills — Travis VN
- **Source:** https://github.com/travisvn/awesome-claude-skills
- **License:** awesome-list (CC0 / public-domain spirit; see upstream)
- **How we use it:** As an index that pointed us at the skills above. Catalog only; no content vendored from this repo directly.

## Adding new vendored content

1. Confirm upstream license is compatible with our use.
2. Copy the license file into [licenses/](licenses/) with a name that identifies the upstream.
3. Add a section to this file listing what was vendored, where, and from what version (commit SHA preferred).
4. For CC BY-SA content, keep it in a `_<source>/` subdirectory so the license boundary stays visible.
5. Run [adapters/sync-all.sh](adapters/sync-all.sh) so the provider configs pick up the new content.
