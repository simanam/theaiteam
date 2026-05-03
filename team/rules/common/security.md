# Security baseline (always follow)

## Secrets

- Never commit secrets. `.env.example` only.
- Use the host's secret store (Railway env, GitHub Actions secrets, Vault).
- Rotate on any suspected exposure. Document the rotation in `workspace/<slug>/artifacts/security/incidents.md`.
- Don't log secrets. Don't print them in error messages. Don't include them in URLs.

## Authentication

- Use a battle-tested library. Don't roll your own crypto, JWT signing, or password hashing.
- Hash passwords with bcrypt/argon2 (never plain or fast hashes).
- Tokens have an expiration. Refresh tokens have a longer one but a rotation policy.
- Multi-factor where the threat model warrants it.

## Authorization

- Check authorization at every endpoint that returns or mutates data.
- IDOR is the #1 silent bug. Always verify the actor has access to the specific resource (object-level), not just the type (function-level).
- Default deny. Explicitly grant.
- Role checks happen server-side. Hiding a button on the frontend is UX, not security.

## Input validation

- Validate at the boundary. Once it's inside the system, treat it as trusted.
- Reject by allowlist when feasible (UUIDs, enums, known shapes); fall back to deny-list for free-form text.
- Length limits everywhere. Set body size limits on the web framework.
- Parameterized queries always. No string-built SQL.

## Output encoding

- Auto-escape in templates. If you bypass it, justify in a comment.
- JSON responses set `Content-Type: application/json`. Don't reflect untrusted strings into HTML / scripts.
- Set CSP headers. Set HSTS. Set `X-Content-Type-Options: nosniff`.

## Data handling

- Encrypt at rest (DB-level) and in transit (TLS 1.2+).
- PII inventory: list it in `workspace/<slug>/artifacts/security/pii-inventory.md`.
- Retention policy: every PII field has a documented retention period.
- Logs and analytics events scrub PII unless explicitly required.

## Dependencies

- Dependabot / Renovate on every repo.
- High-severity CVEs block release.
- Audit transitive deps for new additions.

## Rate limiting

- Public endpoints have rate limits. Default: 60 req/min per IP, 600 req/min per authenticated user. Tune to the brief.
- Auth endpoints have stricter limits to slow brute force.
- Document limits in API docs.

## CI/CD

- Static analysis runs on every PR (Semgrep, language linter, type checker).
- Container scanners run on every image build.
- SBOM generated and stored on release tags.

## AI-specific

- Never trust LLM output as the source of authorization. The LLM is part of input, not policy.
- Prompt-injection defenses on user-controlled prompt segments: structured tool-calling, output validation, least-privilege tool access.
- AI-generated code reviewed before merge — same bar as human-authored.
