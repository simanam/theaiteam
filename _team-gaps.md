# theaiteam — gap log

This is the queue of identified gaps in theaiteam itself. Roles append here when they notice issues during project work via `/log-gap`. Team Maintainer drains the queue via `/audit` and `/self-improve`.

## Conventions

- Each gap has an ID (`G-NNN`), severity, evidence, proposed fix, status, logged-by, logged-date.
- Append-only — never delete entries. Mark `won't-fix` with reason if rejected.
- Numbering is global. `G-001` is the first gap ever; do not reset per audit.
- The Maintainer is the only role that closes entries (sets `fixed-in-<sha>` or `filed-as-improvement-<slug>`).

## Status values

| Status | Meaning |
|---|---|
| `open` | Just logged. Maintainer hasn't triaged yet. |
| `in-progress` | Maintainer is actively fixing. |
| `fixed-in-<sha>` | Edited and committed. SHA references the commit. |
| `filed-as-improvement-<slug>` | Non-trivial fix; brief at `improvement-briefs/<slug>.md`. Run `/kickoff <slug>` to address. |
| `won't-fix` | Rejected with reason in **Notes**. |

---

## Initial gaps (logged at scaffolding time, 2026-05-03)

These are the four gaps surfaced when the team was first built. Maintainer can drain them on first `/self-improve`.

### Gap G-001 — devops-skills-empty
**Severity:** moderate
**Evidence:** `team/skills/devops/` is empty. The DevOps role file expects skills like `ci-cd-setup`, `deployment`, `observability`, `infra-as-code`.
**Proposed fix:** Author 4 skills under `team/skills/devops/` covering CI/CD pipeline setup, repeatable deploys, observability (logs/metrics/alerts), and infra-as-code patterns.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Likely too large for auto-fix; file as improvement brief on first /self-improve.

### Gap G-002 — security-skills-only-trailofbits
**Severity:** moderate
**Evidence:** `team/skills/security/` top level is empty. Only `_trailofbits/` (CC BY-SA 4.0) is present. No top-level Apache/MIT-licensed `owasp-review` or `threat-modeling` skill.
**Proposed fix:** Author 2 skills under `team/skills/security/`: `owasp-review` (API + Web Top 10 checklist) and `threat-modeling` (STRIDE-style design review). MIT-licensed (theaiteam original) so derivatives don't carry CC BY-SA share-alike.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Filed as improvement brief on first /self-improve.

### Gap G-003 — gemini-adapter-stub
**Severity:** moderate
**Evidence:** `adapters/gemini/sync.sh` only writes a `GEMINI.md` pointer + `.gemini/context.md` index. It does not concatenate the team into a usable system-instruction.
**Proposed fix:** Extend the script to mirror `adapters/codex/sync.sh` — concatenate roles + skills + rules + commands + workflows into a single GEMINI.md or per-file system-instruction set.
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Simple extension; auto-fixable on first /self-improve.

### Gap G-004 — language-reviewer-agents-not-symlinked
**Severity:** trivial
**Evidence:** `adapters/claude-code/sync.sh` symlinks top-level `team/agents-extra/*.md` but does not recurse into `language-reviewers/` or `build-resolvers/` subdirs.
**Proposed fix:** Update sync.sh to recurse, OR explicitly list nested agent files. Decide whether to flatten (avoids picker overload) or namespace (e.g., `lang-typescript-reviewer`).
**Status:** open
**Logged by:** scaffolder
**Logged date:** 2026-05-03
**Notes:** Auto-fixable.

---

## Discovered by tools/validate.sh on 2026-05-03

### Gap G-005 — missing-skill-set-architecture
**Severity:** moderate
**Evidence:** `team/roles/architect.md` previously listed `architecture/system-design`, `architecture/data-modeling`, `architecture/tech-stack-selection`, `meta/repomix-ingest` in default-skills; none have `SKILL.md` files. Removed from frontmatter; documented as aspirational.
**Proposed fix:** Author 4 skills under `team/skills/architecture/` and `team/skills/meta/` covering system design, data modeling (ERD + indexing patterns), tech-stack-selection (decision matrix), and repomix-ingest (procedure for using `tools/ingest.sh`).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-006 — missing-skill-engineering-refactoring
**Severity:** moderate
**Evidence:** `team/roles/backend-engineer.md` referenced `engineering/refactoring`; no SKILL.md exists. Removed.
**Proposed fix:** Author `team/skills/engineering/refactoring/SKILL.md` covering safe transformation patterns (extract, inline, split-merge) with tests-as-safety-net.
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-007 — missing-skill-engineering-code-review-canonical
**Severity:** trivial
**Evidence:** Multiple roles (backend, frontend, mobile, security) referenced `engineering/code-review`; vendored set has `engineering/requesting-code-review` and `engineering/receiving-code-review` (separate). Roles updated to use both vendored versions or one as appropriate.
**Proposed fix:** Either author a single `engineering/code-review/SKILL.md` that points to both, OR keep the split and add a meta skill `engineering/peer-review-loop` describing how requesting+receiving compose. Lean toward composing.
**Status:** in-progress (worked around in role frontmatter; proper fix deferred)
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-008 — missing-skill-set-design
**Severity:** moderate
**Evidence:** `team/roles/designer.md` and `team/roles/frontend-engineer.md` referenced `design/design-system` and `design/ux-flow`; neither has a SKILL.md.
**Proposed fix:** Author 2 skills under `team/skills/design/`: `design-system` (tokens + components + rhythm) and `ux-flow` (every screen, every state, every transition).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-009 — missing-skill-set-product
**Severity:** moderate
**Evidence:** `team/roles/product-manager.md` referenced `product/user-story`, `product/roadmap`, `meta/handoff-protocol`; none have SKILL.md files.
**Proposed fix:** Author 3 skills: `product/user-story` (decomposing PRDs into testable stories with acceptance criteria), `product/roadmap` (sequencing work), `meta/handoff-protocol` (the format for `workspace/<slug>/handoffs/*.md`).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-010 — missing-skill-set-qa
**Severity:** moderate
**Evidence:** `team/roles/qa-engineer.md` referenced `qa/test-strategy` and `qa/manual-test-plans`; neither has SKILL.md.
**Proposed fix:** Author 2 skills: `qa/test-strategy` (unit/integration/E2E split per project) and `qa/manual-test-plans` (exploratory + scripted test plan structure).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

### Gap G-011 — missing-skill-set-docs
**Severity:** moderate
**Evidence:** `team/roles/technical-writer.md` referenced `docs/api-docs`, `docs/readme-writing`, `docs/changelog`, `docs/runbook`; ZERO of the 4 have SKILL.md files. Worst-impacted domain.
**Proposed fix:** Author all 4 skills under `team/skills/docs/`. README and runbook are highest-leverage (they're produced for every project).
**Status:** open
**Logged by:** validate.sh
**Logged date:** 2026-05-03

---

## Future gaps go here

Append below. Increment G-NNN globally.
