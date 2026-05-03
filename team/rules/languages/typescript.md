# TypeScript / JavaScript

## Toolchain

- TypeScript 5.x; `strict: true` in tsconfig.
- Package manager: `pnpm` preferred; `npm` acceptable. No mixing.
- Lint: ESLint with the recommended preset + project rules.
- Format: Prettier; commit-time hook enforces.
- Build: `tsc --noEmit` in CI even if you're using a bundler.

## Types

- No `any` without a comment justifying it. Prefer `unknown` and narrow.
- `strictNullChecks` on. Optional chaining and nullish coalescing for safety.
- Discriminated unions over enums for state machines.
- `as` casts are last-resort. Use type guards.
- Type imports: `import type { Foo } from '...'` to avoid runtime cycles.

## Module system

- ESM only. `"type": "module"` in package.json.
- Path aliases via tsconfig `paths` + bundler config.
- No barrel files (`index.ts` re-exports) for large modules — they hurt tree-shaking.

## React / Next.js

- Functional components + hooks. No class components in new code.
- `use client` directives intentional, not by reflex.
- Server components by default in Next.js App Router.
- State at the right level: local for ephemeral UI, Zustand/Jotai for cross-component, server state via `@tanstack/react-query`.

## Async

- `async/await` over `.then` chains.
- Always handle promise rejection. `void` operator if intentionally ignoring.
- Don't `await` inside loops when concurrent is fine; use `Promise.all`.

## Testing

- Vitest preferred; Jest acceptable.
- Component tests: React Testing Library, not Enzyme.
- E2E: Playwright (per QA's default).
- No `xit` / `xdescribe` left in main.

## Common pitfalls

- `==` vs `===`: always strict equality.
- `for...in` for arrays — don't. Use `for...of` or `.forEach` / `.map`.
- Mutating function args. Don't.
- `Date` math without timezone awareness. Use `date-fns-tz` or `Temporal`.
