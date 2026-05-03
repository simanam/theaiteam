# Routing — brief sections → roles

How the orchestrator decides who picks up what.

## By deliverable

| Deliverable in brief | Lead role | Supporting roles |
|---|---|---|
| Working code (PR) | Backend / Frontend / Mobile (per stack) | Architect (review), QA, Security |
| Tests | QA | Engineer of domain |
| API documentation | Tech Writer | Backend / Architect |
| User-facing docs | Tech Writer | PM |
| System design / ADRs | Architect | PM (signoff) |
| UX flows / mockups | Designer | Frontend / Mobile |
| Marketing kit | Marketing Strategist | Designer (assets), Tech Writer (clarity) |
| Deployment runbook | DevOps | Tech Writer (polish) |
| Security review | Security | Architect (design-time), Engineer (code-time) |

## By brief signal

| Brief mentions… | Add role |
|---|---|
| "iOS" / "Android" / "mobile" / "SDK" | mobile-engineer |
| "dashboard" / "web" / "client portal" / "frontend" | frontend-engineer |
| "API" / "backend" / "service" / "database" / "schema" | backend-engineer |
| "user research" / "interviews" / "validate" | product-manager (customer-research mode) |
| "design system" / "brand" / "UX" / "mockups" | designer |
| "launch" / "GTM" / "positioning" / "marketing" / "growth" | marketing-strategist |
| "compliance" / "GDPR" / "SOC 2" / "HIPAA" / "auth" / "PII" | security-engineer (early) |
| "deploy" / "infra" / "CI/CD" / "scaling" / "monitoring" | devops-engineer |
| "docs" / "API reference" / "integration guide" / "runbook" | technical-writer |

## Excluded by default

| Brief mentions… (or doesn't) | Exclude role |
|---|---|
| Pure backend, no UI | frontend-engineer, designer, mobile-engineer |
| No user-facing surface | marketing-strategist (unless internal launch) |
| Internal-only tool, no compliance | security-engineer (still does code review, but skips threat-modeling phase) |

## Override rules

A brief's "Roles needed" section overrides defaults:
- `Required: <role>` forces inclusion
- `Excluded: <role>` forces exclusion (orchestrator must justify if a workflow strictly needs it)
- `Lead: <role>` overrides the workflow's default lead

## Parallelism boundaries

These pairs are safe to run in parallel (different artifact dirs, no read-after-write between them):

- Backend ‖ Frontend (after architect's API contract is finalized)
- Backend ‖ Designer (designer reads PRD, not code)
- Frontend ‖ Mobile (different platforms)
- Tech Writer ‖ Marketing Strategist (after PRD and feature is shipped)
- DevOps ‖ Security (audit) ‖ Tech Writer (during launch-prep)
- QA's regression test authoring ‖ Engineer's bug fix (QA writes the failing test; engineer fixes; merge when both are ready)

These pairs are sequential:

- PM → Architect (PRD must exist before design)
- Architect → Backend / Frontend / Mobile (design must exist before implementation)
- Backend → QA E2E (need a working endpoint to test against)
- Engineer → Security code review (need code to review)
- All of above → DevOps deploy

## When in doubt

Default to sequential. Parallel saves time only when both branches have everything they need to start. A "parallel" task that's actually waiting on the other is just a slower sequential.
