# Next.js SDD review notes

## Recurring checks

- Verify the constitution/spec contract before reviewing the diff.
- For monthly rollover, use a business timezone consistently in month keys, ranges,
  `dateToString`, UI labels, and transaction filters.
- Use half-open ranges `[start, end)` for month queries to avoid end-of-day gaps.
- Keep snapshots idempotent with a unique `monthKey`; handle duplicate-key races without
  turning the second concurrent request into a user-visible error.
- Separate active queries (`archived != true`) from historical snapshot queries (which must
  include archived rows). This distinction must be checked inside every `$lookup` too.
- Verify that persisted budgets/configuration survive rollover while progress is scoped to
  the active cycle.
- When data contains per-item currencies, format each item with its own currency rather
  than the page's default currency.
- Test legacy route redirects and protected route/API behavior after route migrations.

## Reproducible peer resolution

Tremor 3.x declares a React 18 peer while modern Next.js scaffolds install React 19. If
that exact conflict blocks a clean bootstrap, keep the chosen compatibility policy in the
project (`.npmrc` with `legacy-peer-deps=true`) and rerun the complete verifier. A one-off
manual install flag is not sufficient evidence of reproducibility.

## Additive fields and enum extensions

When a spec adds an optional field or a new enum value to an existing model:

- Give the field a behavior-preserving default (`null`, `false`) and prove regression 0
  with a test exercising the old flow untouched.
- Restrict the field to the types where it makes sense with a Zod `discriminatedUnion` on
  `type` (one branch per literal) so an explicit value on the wrong type returns 400
  instead of being silently ignored.
- For a new enum value (e.g. a `settlement` type), audit EVERY consumer: aggregate
  `$match`/`$group` pipelines feeding totals, the all-time balance, monthly snapshots
  (exclude it or the archived history changes), frontend labels/sign filters, and the
  conditional `required` of other fields (category/goal). Exclude the new value from
  business aggregates explicitly — "it is never read" is not a guarantee.
- New response fields on existing endpoints must be additive (the old frontend ignores
  unknown keys); extend the shared `types/index.ts` contracts with optional fields.
- Edit endpoints must clear derived fields when the type changes (convert an expense to
  income → `paidBy` resets to null) while preserving them when the type is unchanged.

### Mongoose field with `default: null` requires `T | null` in the TS interface

When an additive field's Mongoose schema uses `default: null` (or includes `null` in its
enum), the shared interface in `src/types/index.ts` MUST declare `field?: T | null` — not
`field?: T`. Executors routinely type it without `null`, and the result is a green test
suite + green lint with a RED `next build`:

- `transaction.field = null` → `TS2322: Type 'null' is not assignable to type 'T | undefined'`
- `Transaction.create({ ...data })` where the Zod discriminated union produces
  `field?: null | undefined` → `TS2769: No overload matches this call` cascading into
  `TS2339: Property 'populate' does not exist on type 'never'` and `TS7006: implicit any`
  on downstream code (the union collapses to `never`).

Key review insight: vitest transpiles without full type-checking, so `npm run test` + `npm
run lint` can both pass while `next build` fails — for additive model fields the build is
the only gate that catches interface/schema mismatch. Always check the interface when the
schema change was part of the diff; the fix is one line and mirrors sibling fields that
already persist null (e.g. `paidBy?: PaidBy | null`).

## Evidence to preserve

Record the actual test count, coverage percentages, TypeScript/lint/build results, audit
result, HTTP smoke responses, commit SHA, remote SHA, clean worktree, and documentation
paths. Mention any harmless Vitest/Vite configuration warning separately from failures.
