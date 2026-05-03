---
slug: REPLACE-WITH-SHORT-SLUG
type: team-improvement
priority: P2
deadline: ""
target_repo: "/Users/amansingh/Documents/theaiteam"   # this team itself
ai_provider: claude-code
gap_id: G-NNN                                          # the gap this brief addresses
---

# Improvement Brief — <Title>

> An improvement brief is a project brief whose subject is **theaiteam itself**. The team-maintainer leads; relevant role(s) review.

## 1. Goal (1–3 sentences)

What change to theaiteam, and why does it matter?

> Example: Add a top-level `team/skills/security/owasp-review/SKILL.md` so the Security Engineer has a vendored MIT-licensed OWASP review skill (today only the CC BY-SA `_trailofbits/` set is present).

## 2. Affected files / surfaces

- List specific paths that will be created, edited, or removed.
- Note whether changes touch user-facing docs (CLAUDE.md, README, GETTING_STARTED).
- Note whether changes affect the adapter outputs.

## 3. Success criteria

- [ ] Concrete outcome 1
- [ ] Concrete outcome 2
- [ ] Validation suite passes (frontmatter, links, adapter sync)
- [ ] If user-facing: docs updated to match

## 4. Roles needed

- **Required**: team-maintainer (default lead)
- **Reviewer**: <which existing role should review the change?> (e.g., security-engineer for security skill changes; tech-writer for doc changes)
- **Excluded**: typically all other 11 roles

## 5. Risks

- What could break? What's the blast radius if this goes wrong?
- Is there a license concern (e.g., touching `_trailofbits/` content carries CC BY-SA obligations)?
- Is there a breaking change to the directory layout / adapter contract / role-skill cross-refs?

## 6. Out of scope

Explicitly list adjacent improvements you're NOT making in this brief. Keeps the change focused.

## 7. References

- Gap entry in `_team-gaps.md`: G-NNN
- Upstream sources (if vendoring new content)
- Citations for any "world drift" claim (URLs)

## 8. Notes

Anything else relevant — competing options considered, prior art, etc.
