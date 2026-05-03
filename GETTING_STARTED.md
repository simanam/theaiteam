# Getting started — theaiteam in 10 minutes

For someone who's never seen this repo before. Read top-to-bottom.

---

## 1. What this is (30 seconds)

**theaiteam is a workforce, not a tool.** It contains 11 role-based AI agents (PM, Architect, Backend, Frontend, Mobile, Designer, QA, Security, DevOps, Tech Writer, Marketing Strategist), 108 skills they can use, and an orchestrator that routes work between them.

You write a project brief. The orchestrator picks the right roles and dispatches them. They write code, docs, tests, designs, and marketing — all coordinated through a shared `workspace/`.

It runs on Claude Code, Codex CLI, or Gemini CLI — the team's source-of-truth lives in [team/](team/), and adapters in [adapters/](adapters/) translate to whatever provider you use.

---

## 2. The mental model (1 minute)

```
You write:        briefs/<project>.md           (a structured project brief)
                            │
                            ▼
You run:          /kickoff <project>            (orchestrator takes over)
                            │
                            ▼
Orchestrator:     picks a workflow              (greenfield-feature | bug-fix | …)
                  creates workspace/<project>/  (shared scratchpad)
                  dispatches roles              (sequential or parallel)
                            │
                            ▼
Roles:            read brief + handoffs         (each role knows its job)
                  use skills                    (TDD, OWASP review, copywriting…)
                  write code/docs/designs       (into target_repo or workspace/)
                  open PRs                      (with proper test plans)
                  hand off                      (via task-board.md)
                            │
                            ▼
You ship.
```

Three things **you** touch: [briefs/](briefs/), the `/kickoff` command, [workspace/](workspace/) (to read what happened).
Three things you'd edit if **customizing**: [team/](team/) (roles, skills, rules), then run `./adapters/sync-all.sh`.

---

## 3. Try it on the included example (3 minutes)

There's a worked-through example brief at [briefs/example-link-shortener.md](briefs/example-link-shortener.md). Run it:

```bash
cd /Users/amansingh/Documents/theaiteam

# 1. Make sure provider configs are synced (already done once; safe to re-run)
./adapters/sync-all.sh

# 2. Open Claude Code in this directory and run:
#    /kickoff example-link-shortener
```

**What happens:**
1. The orchestrator reads [briefs/example-link-shortener.md](briefs/example-link-shortener.md)
2. It picks the [greenfield-feature workflow](team/workflows/greenfield-feature.md)
3. It creates `workspace/example-link-shortener/` with a task-board, plans/, artifacts/, handoffs/
4. It dispatches the **product-manager** role first (per the workflow)
5. The PM reads the brief, writes a PRD into `workspace/example-link-shortener/plans/prd.md`, decomposes it into stories, and hands off to the **architect**
6. … and so on through the workflow

You'll see progress in `workspace/example-link-shortener/task-board.md` after each role finishes.

---

## 4. Use it for your own project (5 minutes)

Two patterns. Pick the one that fits.

### Pattern A — "Use theaiteam as a template" (recommended for one project at a time)

Copy theaiteam into your project root or alongside it. The team operates on **your project's brief and target repo**, with all per-project state living in `workspace/<your-slug>/`.

```bash
# 1. Clone or copy theaiteam to a new location for your project
cp -r /Users/amansingh/Documents/theaiteam ~/myproject-team
cd ~/myproject-team

# 2. Write your brief
cp briefs/_template.md briefs/myproject.md
$EDITOR briefs/myproject.md
# Fill in: goal, target users, success criteria, stack, deliverables.
# Set target_repo to your existing repo path or git URL (or leave blank if greenfield).

# 3. Sync the provider configs to your chosen AI CLI
./adapters/sync-all.sh

# 4. Open Claude Code (or Codex / Gemini) in this directory and run
#    /kickoff myproject
```

The orchestrator opens PRs in your `target_repo` and writes per-project docs/plans into `workspace/myproject/`.

### Pattern B — "One central team, many projects" (for managing multiple projects)

Keep `~/Documents/theaiteam/` as your single team repo. Each project gets its own brief in `briefs/` and its own `workspace/<slug>/`. Target repos live elsewhere on disk.

```bash
cd ~/Documents/theaiteam

# Project 1
cp briefs/_template.md briefs/saas-mvp.md && $EDITOR briefs/saas-mvp.md
# /kickoff saas-mvp

# Project 2 (later)
cp briefs/_template.md briefs/marketing-site.md && $EDITOR briefs/marketing-site.md
# /kickoff marketing-site

# Both live side-by-side in workspace/
ls workspace/
# saas-mvp/  marketing-site/
```

This is what the current `/Users/amansingh/Documents/theaiteam/` setup is wired for.

---

## 5. The brief is the contract (1 minute)

The orchestrator only knows what's in the brief. **Vague brief → noisy output.** A specific brief produces specific work.

[briefs/_template.md](briefs/_template.md) tells you exactly what fields to fill. Minimum signal:
- **Goal** (1–3 sentences) — what changes for whom
- **Success criteria** — testable bullets the team can verify
- **Stack** — language, framework, host, integrations
- **Deliverables** — code? docs? marketing kit? all?
- **target_repo** — where the code lands; blank if greenfield

[briefs/example-link-shortener.md](briefs/example-link-shortener.md) is the gold-standard reference.

---

## 6. What to read next (by your role)

| If you are… | Read |
|---|---|
| **Just trying it out** | [briefs/example-link-shortener.md](briefs/example-link-shortener.md) → run `/kickoff example-link-shortener` |
| **Onboarding the team to a real project** | [briefs/_template.md](briefs/_template.md) → fill it in → kick off |
| **Curious how it works under the hood** | [docs/how-it-works.md](docs/how-it-works.md) |
| **Wanting to customize a role** | [team/roles/](team/roles/) → edit the role file → `./adapters/sync-all.sh` |
| **Adding a new skill** | [team/skills/README.md](team/skills/README.md) → "Adding a new skill" |
| **Defining a new workflow** | [team/workflows/](team/workflows/) → copy an existing one as a template |
| **Switching AI providers** | [adapters/](adapters/) → run the right sync script |
| **Worried about licensing / attribution** | [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) |
| **Architect of theaiteam itself** | [docs/plans/theaiteam-design.md](docs/plans/theaiteam-design.md) |

---

## 7. The team improves itself

Software rots. Rules go stale. Vendored skills drift from upstream. Languages release new majors. theaiteam handles its own decay.

### Three commands

- **`/log-gap <severity> <title>`** — any role, mid-task, when it notices something wrong (stale Swift version, broken link, missing skill). Appends to [_team-gaps.md](_team-gaps.md). 30 seconds — keep working.
- **`/audit`** — Maintainer runs a read-only sweep: internal consistency, frontmatter, coverage, staleness vs. world, upstream drift, adapter drift. Populates the gap log. Doesn't change anything.
- **`/self-improve`** — Maintainer drains the gap log. Trivial gaps (typos, version pin bumps, broken links) → auto-edited and committed with `fix(team):`. Non-trivial gaps → filed as briefs in [improvement-briefs/](improvement-briefs/) for the user to kick off.

### The Swift example

The mobile-engineer reads [team/rules/languages/swift.md](team/rules/languages/swift.md). It says "Swift 5.9+." But the world has moved on. Two ways this gets fixed:

**Reactive** (during project work):
```
mobile-engineer:  /log-gap trivial swift-version-pin-stale
                  → appends to _team-gaps.md, keeps building the iOS app
[later, user runs:] /self-improve
team-maintainer:  → WebFetches swift.org, confirms Swift 6 is current
                  → edits team/rules/languages/swift.md (5.9 → 6.0)
                  → commits "fix(team): bump Swift pin to 6.0 (gap G-007)"
                  → updates _team-gaps.md status to fixed-in-<sha>
```

**Proactive** (scheduled maintenance):
```
[user runs:] /audit
team-maintainer:  → six audit passes, finds 12 gaps including swift-version-pin-stale
                  → appends them all to _team-gaps.md
[user runs:] /self-improve
team-maintainer:  → fixes the trivial ones (commits each separately)
                  → files improvement briefs for the rest
```

### Safety rails

- The Maintainer is the **only** role allowed to edit theaiteam's source files. Every other role logs gaps; they don't fix.
- Trivial vs. moderate vs. structural is auto-classified by [meta/apply-self-fix](team/skills/meta/apply-self-fix/SKILL.md) — only trivial + high-confidence-moderate get auto-fixed. Anything bigger goes through a real workflow with user sign-off.
- Validation runs after every edit (frontmatter, links, adapter sync). Failed validation reverts the change.
- Never auto-fixes [licenses/](licenses/), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), or `_trailofbits/` content (CC BY-SA — surfaces to user instead).

### Cadence

There's no schedule enforced. Realistic rhythm:
- Every role uses `/log-gap` opportunistically during projects
- User runs `/audit` monthly or when something feels off
- User runs `/self-improve` quarterly or after a `/audit` shows real drift

---

## 8. FAQ

**Q: Do I need Claude Code? Can I use Codex or Gemini instead?**
Yes — run `./adapters/codex/sync.sh` or `./adapters/gemini/sync.sh` to generate the provider-specific configs from the same `team/` source. Claude Code is the primary integration; Gemini's adapter is a starter you may need to extend per your CLI version.

**Q: Where does the actual code go?**
Into your `target_repo` (the path or git URL you set in the brief). Roles open PRs there. If `target_repo` is blank, scaffolded code lands in `workspace/<slug>/artifacts/code/`.

**Q: Can I run multiple roles in parallel?**
Yes, where the workflow says so. [orchestrator/routing.md](orchestrator/routing.md) lists which role pairs are safe to parallelize. The orchestrator handles dispatch.

**Q: A role got stuck — what do I do?**
Check `workspace/<slug>/task-board.md` for the blocker. Roles record what they're stuck on. The orchestrator will escalate to you when it can't unblock itself. You can also run `/standup <slug>` to get a status summary.

**Q: Can I skip the orchestrator and just talk to a single role?**
Yes — the role files in [team/roles/](team/roles/) work as standalone personas. Open one and have a conversation. You lose the cross-role coordination but it's useful for focused work (e.g., "act as the architect and review this design").

**Q: How do I add my own role (e.g., a Data Engineer)?**
1. Copy an existing role file (e.g., [team/roles/backend-engineer.md](team/roles/backend-engineer.md)) to `team/roles/data-engineer.md`
2. Edit mission, responsibilities, default skills, handoffs
3. If a workflow needs to dispatch this role, edit the relevant workflow in [team/workflows/](team/workflows/)
4. Run `./adapters/sync-all.sh`

**Q: What if my project doesn't fit any of the 4 starter workflows?**
Add a new workflow in [team/workflows/](team/workflows/) using an existing one as a template. Add a `triggers: [your-type]` line so briefs with `type: your-type` route to it. Update [orchestrator/orchestrator.md](orchestrator/orchestrator.md)'s workflow-selection table.

**Q: My role file edits aren't being picked up.**
Run `./adapters/sync-all.sh`. The provider configs (`.claude/`, `AGENTS.md`, `.gemini/`) are generated. Don't edit them directly.

**Q: I want to throw out one of the 5 vendored upstream sets.**
Each upstream's content is identifiable — see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for which directories came from where. Delete what you don't want, then re-sync.

**Q: How do I keep this in sync with future updates from the upstream repos?**
There's no automatic update channel. Re-clone the upstream and diff against the vendored copy when you want fresh content. The current snapshot is captured in `licenses/` (LICENSE files were copied at vendor time).

---

## 9. Common pitfalls

- **"It generated a generic plan" →** Your brief was generic. Add specificity to success criteria + constraints.
- **"Two roles are fighting over the same file" →** They missed the workspace protocol. Re-read [orchestrator/workspace-protocol.md](orchestrator/workspace-protocol.md); each role writes into its own artifact dir.
- **"The PR has no test plan" →** Use the `/ship` command instead of opening a PR manually — it enforces the format.
- **"The orchestrator is rewriting the same file every turn" →** It probably never finished a stage. Check the task-board; mark stages `done` deliberately.
- **"I edited `.claude/agents/foo.md` and nothing changed" →** That's a symlink. Edit `team/roles/foo.md` (or `team/agents-extra/foo.md`) instead.

---

## 10. Where to ask for help

- **Brief writing:** start from [briefs/_template.md](briefs/_template.md) and the worked example
- **Role behavior:** the role file is the prompt; edit it
- **Workflow logic:** [team/workflows/](team/workflows/) files are the dispatch rules
- **Architecture questions:** [docs/plans/theaiteam-design.md](docs/plans/theaiteam-design.md) explains the why
