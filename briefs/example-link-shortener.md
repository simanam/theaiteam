---
slug: link-shortener-mvp
type: greenfield-feature
priority: P1
deadline: 2026-06-15
target_repo: ""
ai_provider: claude-code
---

# Project Brief — Link Shortener MVP

## 1. Goal

Ship a self-hosted link-shortener service with attribution tracking. Replace our team's Bitly usage so we can see UTM-level performance and own our data.

## 2. Target users

Internal marketing team (5 people) sending email campaigns and social posts. They currently log into Bitly, paste URLs, copy short links. Pain: no per-campaign rollup, no audience segmentation, link history scattered across personal accounts.

## 3. Success criteria

- [ ] `POST /api/links` accepts a long URL + UTM params and returns a short URL in <200ms p95
- [ ] `GET /:slug` redirects (302) and logs a click event with referer, UA, country
- [ ] Dashboard shows links + clicks grouped by campaign, with daily totals
- [ ] All 5 marketers can self-serve without engineering help
- [ ] Zero downtime migration plan from Bitly (export → import existing links)

## 4. Stack and constraints

- **Languages / frameworks**: Python 3.12 + FastAPI for backend, Next.js 14 + Tailwind for dashboard
- **Hosting**: Railway (backend) + Vercel (dashboard) + Cloudflare (DNS + caching)
- **Existing systems**: Postgres 16 (Supabase), Google Workspace SSO for dashboard auth
- **Hard constraints**: $50/mo infra budget, GDPR-compliant click logging (no PII beyond what's already in Cloudflare logs)
- **Out of scope**: public sign-up, paid plans, custom domains for end-users (just our own domain), mobile app

## 5. Deliverables

- [x] Working code (PR opened against new repo `link-shortener`)
- [x] Tests (unit + integration; ≥70% coverage)
- [x] API documentation (OpenAPI + a getting-started)
- [x] User-facing docs (dashboard README, marketer's how-to)
- [x] System design doc
- [ ] UX flows / design mockups (lightweight — Tailwind defaults are fine)
- [x] Marketing kit (internal launch announcement, training doc)
- [x] Deployment runbook
- [x] Security review (rate limiting, abuse, OWASP API Top 10)

## 6. Roles needed

- **Required**: product-manager, architect, backend-engineer, frontend-engineer, qa-engineer, security-engineer, devops-engineer, technical-writer, marketing-strategist
- **Excluded**: mobile-engineer, designer (using off-the-shelf components)
- **Lead**: product-manager

## 7. Context and references

- Bitly export of existing links: `workspace/link-shortener-mvp/ingested/bitly-export.csv` (will be added)
- Internal usage data: ~80 links/month, peak ~500 clicks/day
- Reference inspirations: Dub.co, Short.io

## 8. Risks and unknowns

- Cloudflare R2 vs Postgres for click events — pick during architecture
- Rate-limit policy against scrapers / abuse
- Domain decision (subdomain of main site vs. dedicated short domain)

## 9. Notes

Aman is the only stakeholder. No external customers in v1. Ship in 6 weeks max — anything threatening that gets cut to v1.5.
