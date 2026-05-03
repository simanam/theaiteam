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

## Future gaps go here

Append below. Increment G-NNN globally.
