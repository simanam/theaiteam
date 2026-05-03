---
slug: REPLACE-WITH-SHORT-SLUG
type: greenfield-feature   # one of: greenfield-feature | bug-fix | code-review-cycle | launch-prep | research-spike | refactor
priority: P2               # P0 (drop everything) | P1 (this sprint) | P2 (planned) | P3 (someday)
deadline: YYYY-MM-DD       # optional, leave blank if none
target_repo: ""            # absolute path or git URL, blank if greenfield
ai_provider: claude-code   # claude-code | codex | gemini
---

# Project Brief — <Project Name>

## 1. Goal (1–3 sentences)

What is this project supposed to *do* for someone? Who is the someone?

> Example: Build a /api/links endpoint that creates short URLs for our marketing team to use in email campaigns. They currently rely on Bitly which doesn't surface attribution data we need.

## 2. Target users

Who uses this? What's their context? What do they currently do without it?

## 3. Success criteria

How do we know it's done? List concrete, testable outcomes.

- [ ] Outcome 1
- [ ] Outcome 2
- [ ] Outcome 3

## 4. Stack and constraints

- **Languages / frameworks**: e.g., Python 3.12 + FastAPI, Postgres 16, Redis 7
- **Hosting**: e.g., Railway, Cloudflare, Vercel
- **Existing systems to integrate with**: list APIs, DBs, auth providers
- **Hard constraints**: budget, latency, compliance (GDPR, SOC 2, HIPAA), licensing
- **Out of scope**: explicit non-goals

## 5. Deliverables

What artifacts must the team produce? Check all that apply.

- [ ] Working code (PR opened against `target_repo`)
- [ ] Tests (unit + integration coverage threshold: __%)
- [ ] API documentation
- [ ] User-facing docs (README, getting-started)
- [ ] System design doc / architecture decision records
- [ ] UX flows / design mockups spec
- [ ] Marketing kit (positioning, launch checklist, content brief)
- [ ] Deployment runbook
- [ ] Security review
- [ ] Other: ___________

## 6. Roles needed

The orchestrator picks defaults based on `type` and deliverables. Override here if you want specific roles included or excluded.

- **Required**: e.g., backend-engineer, qa-engineer
- **Excluded**: e.g., mobile-engineer, marketing-strategist
- **Lead**: which role drives the project? Default is product-manager.

## 7. Context and references

- Existing docs / specs: paths or URLs
- Related projects: paths
- Customer interviews / research: paths or URLs
- Competitive references: URLs

## 8. Risks and unknowns

What might go wrong? What do we not know yet?

## 9. Notes

Anything else the team should know.
