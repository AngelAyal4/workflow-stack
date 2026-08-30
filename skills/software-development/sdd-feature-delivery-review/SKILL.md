---
name: sdd-feature-delivery-review
description: "Use when reviewing SDD app features before commit/push."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [sdd, nextjs, code-review, verification, delivery, obsidian]
    related_skills: [app-quality-gates, requesting-code-review, github-pr-workflow]
---

# SDD Feature Delivery Review

A class-level workflow for reviewing a completed feature built through:

```text
Propose → Apply → Archive → Review → Deliver
```

Use this when an executor/ coding agent says a feature is finished and the user wants a
real review, commit, push, and project-note synchronization. The goal is evidence-backed
delivery, not a plausible summary.

## 1. Establish the review contract

1. Read the project constitution and the approved feature spec(s).
2. Read `AGENTS.md` and identify project commands, architecture, security rules, and
   documentation locations.
3. Inspect `git status`, recent commits, the complete diff, renamed/deleted routes, and
   all untracked files. Do not assume the executor's summary is accurate.
4. Build a requirement matrix: each functional requirement, acceptance criterion,
   migration concern, and out-of-scope boundary must have code/tests/evidence or an
   explicit finding.
5. When the spec came from an external agent or a brainstorm, do not accept its
   assumptions on faith — verify each against the codebase before scoping: model fields
   that actually exist, DB-level constraints (e.g. unique singleton indexes enforcing
   single-user), auth/register flows, and the real deployment surface. Be honest about
   what is not applicable, with file evidence, and salvage only the reusable concepts
   (e.g. a split/settle model) while rejecting incompatible architecture (e.g. multi-user
   workspaces in a single-user local app). The user values this critical reading over
   rubber-stamping ("se sincero").
6. Division of roles: in this user's SDD flow the USER runs the orchestrator/executor
   agents themselves (opencode). Your deliverable is specs + prompts + the review;
   if the user says "ya lo estoy ejecutando", do NOT start executing that work yourself
   — finish only what was asked (e.g. the side question they still want answered) and
   wait for their report before reviewing, committing, and syncing Obsidian.

## 2. Review data and business semantics

For monthly, archival, budget, reporting, or dashboard features, explicitly inspect:

- Inclusive/exclusive date boundaries and leap/month transitions.
- Business timezone versus server/browser timezone.
- Active versus archived records in every read, aggregate, update, and delete query.
- Idempotence and concurrency: unique keys, duplicate-key handling, and repeated requests.
- Historical snapshots: whether they capture the state at close time rather than a later
  state; whether they preserve required currency/category metadata.
- Persistent configuration versus monthly measurements.
- Empty, error, unauthorized, invalid-input, not-found, and redirect states.
- UI formatting for per-item currencies, percentages above 100%, negative balances, and
  fixed/variable category semantics.

Green tests do not replace this semantic pass. When a defect is demonstrated, patch it
and add a focused regression test before proceeding.

## 3. Run evidence-producing gates

For a Next.js project, prefer the complete verifier first:

```bash
hermes verify --json
```

Then run or inspect the canonical project gates as needed:

```bash
npm install
npm run test
npm run test:coverage
npm run lint
npm run build
npm audit --audit-level=high
```

Also perform a smoke test against the running app for critical behavior:

- legacy-route redirects,
- unauthenticated page redirects,
- unauthenticated API responses,
- readiness HTTP status,
- newly added route registration in the production build.

For flows that only make sense end-to-end (password recovery, dashboard widgets fed by
new API fields), verify against the live server — not only unit tests:

- Capture the server log in a file (`npm start > /tmp/server.log 2>&1`); process previews
  truncate long lines and `kill` on `npm start` leaves an orphaned `next start` refusing
  the port — free it with `fuser -k <port>/tcp` before relaunching.
- Tool output redacts secret-looking strings (a recovery token prints as `eyJhbG...2thM`);
  the file holds the full value — prove it by line length/segment count and use the value
  in-shell without printing it.
- If the runtime click does not fire a React handler, dispatch the click from the page
  context (`browser_console` + `btn.click()` on a DOM query) — that is a real user click.
- The test suite may or may not share the dev DB: check `src/test/setup.ts` first — a
  `MONGODB_URI` pinning to a `*_test` DB means gates leave dev data (and the manual-test
  account) untouched; without isolation the gates leave test-fixture users. Inspect the
  real state with the DB shell (`docker exec <mongo> mongosh ... db.users.find({})`)
  instead of assuming which user exists, and clean up fixture records created during
  verification.
- For thin/visual-only widgets (8px progress bars, tiny % labels) the vision model's
  proportions are unreliable and can invert the semantics entirely (read "bar ~1/5
  full" when the DOM had 80%+). Ground truth is the DOM: `browser_console` +
  `querySelector` reading `style.width` and the class of the fill element.
- A UI-polish batch can carry stale unit tests that only go red AFTER the last edit
  (tests assert the replaced implementation: Tremor classes, old color names, old
  width semantics). Update them to the new INTENDED behavior with real math (e.g.
  remaining = 100 − usagePercent), then re-run ALL gates.
- UI-convention batches (e.g. "primary button always right: `[Cancelar] [Primaria]` +
  `justify-end`") need TWO review passes beyond the diff, both caught by the user in
  real usage:
  - Mobile/responsive: page-level header CTAs ("Nuevo movimiento", "Registrar aporte")
    sit in `flex-col` layouts on phones and land LEFT-aligned. The convention must
    reach them too: `justify-end` on the button row container, and wrap loose header
    buttons in `<div className="flex justify-end">`. The user tests on a real phone
    and WILL catch omissions.
  - Sibling scan: confirmations that are NOT modals (inline "¿Eliminar? [Sí][No]"
    rows inside cards) follow the same ordering rule — reorder to `[No][Sí]`. Grep
    `>Sí<` / `>No<` over `src/` to find every inline confirm, not just the modals in
    the diff.
- Ghost DOM in a remote browser: the a11y snapshot can show buttons that do not exist
  in source (an inline confirm rendered as "Sí"/"No" while the code says otherwise).
  Ground truth is the element itself — dump `outerHTML` of the dialog/area via
  `browser_console` before concluding the delivery is wrong.
- Additive Mongoose fields: vitest transpiles without full type-checking, so an
  interface typed `field?: T` while the schema persists `default: null` passes tests AND
  lint but kills `next build` (TS2322 at the assignment, then TS2769/TS2339 cascade as
  the union collapses to `never`). Check `src/types/index.ts` against the schema diff
  first; the fix is `field?: T | null` (details in
  `references/nextjs-sdd-review-notes.md`).

If bootstrap fails because a known peer dependency conflict is reproducible (for example,
Tremor 3.x declares React 18 while the application uses React 19), make installation
reproducible in the repository with a documented `.npmrc` setting such as:

```ini
legacy-peer-deps=true
```

Rerun the complete verifier after that fix. Do not report success based only on a manual
`npm install --legacy-peer-deps` command that future contributors cannot reproduce.

Treat non-blocking warnings separately from failures. Record test count, coverage,
build result, audit result, and smoke-test responses.

## 4. Security and hygiene

- Run the project's `SECURITY-CHECKLIST.md` (workflow-stack, **16 items v2**) with evidence:
  rate limiting on public endpoints (N rapid requests → 429), auth on every private
  route (401 without session), errors shown to users are generic (no stack/DB leaks),
  no secrets in tracked files or git history, `NEXT_PUBLIC_*` only for public values,
  DB not publicly reachable, `npm audit --audit-level=high` clean, no debug/admin
  routes exposed in prod, CORS restricted to defined origins, file uploads validated
  by real type/size (not extension), payment webhook signature verified, security
  headers (CSP/nosniff/X-Frame-Options/HSTS) present, and 2FA on infra (owner task,
  not code). Mark each item resolved or `N/A — motivo` in the report. Items 11-16 are
  the JUANA IA merge; the 9 ready-to-paste prompts live in
  `workflow-stack/docs/seguridad-juanaia-prompts.md`.
- Scan added code for secrets, credentials, unsafe eval, injection, and unsafe file paths.
- Confirm `.env` is ignored and only placeholders exist in `.env.example`.
- Tracked direnv files (`.envrc`) commonly survive `.env*` ignore patterns and show up in
  the secrets grep with dev-placeholder values (`dev-secret-change-in-production`). Report
  them as a hygiene finding — dev placeholders are acceptable, real secrets are blockers;
  state which one it is in the review.
- Ensure all API inputs are validated server-side and auth boundaries are enforced in both
  proxy/middleware and handlers where the project convention requires it.
- Use selective staging; do not accidentally include `.env`, build output, coverage, or
  unrelated changes.
- Run `git diff --check` before committing.

## 4.1 Public quality / anti-vibecoding gate

The core ten security items are not enough for a public web release. Run the 20-point
public-quality gate in `references/public-quality-anti-vibecoding.md` as a separate
review layer covering HTML delivery, SEO, accessibility, runtime hygiene, and bundle
performance. It is mandatory for public/indexable surfaces and must classify each item
as resolved, `N/A — motivo`, or a tracked follow-up.

At minimum, verify the following with real evidence:

- `*.vercel.app` is acceptable only as a documented staging/testing URL; require a
  domain before final public launch.
- View Source is meaningful, and a branded `not-found.tsx` is not replaced silently by
  assuming Next's generated `/_not-found` route is sufficient.
- Route titles and descriptions are descriptive and unique; add Open Graph metadata,
  canonical URLs, and JSON-LD only where the public page type justifies them.
- Every content/error/empty page has exactly one meaningful H1; `<html lang>` and image
  alternatives are correct.
- `robots.txt`, `sitemap.xml`, and `llms.txt` have explicit, safe policies and never
  expose private routes or data.
- Public source-map requests fail in production, browser console verification is done
  in a real browser, and bundle size is reported against a declared raw/gzip budget.

Static searches and build output are useful evidence but do not replace runtime checks:
`console.*` in source does not prove a browser-console error, local `.next/server/*.map`
files do not prove public exposure, and a response status of 404 does not prove that the
404 UX is intentionally designed.

### Strict review additions for public-quality batches

- **Make environment-sensitive tests deterministic.** If metadata is computed at module import from `NEXT_PUBLIC_APP_URL`, run the test once with the variable unset and once with a production-like value. Tests must explicitly stub/unstub the environment before importing the module; a test that passes only when the shell variable is absent is a delivery blocker.
- **Inspect generated public assets visually, not only by MIME/dimensions.** For OG images, check text bounds against safe margins/frame geometry and look for clipping, overlap, unreadable contrast, or a script that computes layout values but never uses them. A valid `1200×630` PNG can still fail the public-quality gate.
- **Audit evidence provenance.** A file labelled baseline must show the clean pre-change tree and commands actually run before implementation. If a baseline log contains the final uncommitted files, reject it as stale/mislabeled and require a regenerated baseline or an explicit explanation.
- **Match the production runtime to the build mode.** With Next `output: 'standalone'`, do not treat a `next start` run that emits the standalone warning as definitive evidence; run `.next/standalone/server.js` (or build with `VERCEL=1` before `next start`) and capture the warning/status explicitly.
- **Separate first-spec acceptance from known hardening follow-ups.** Fingerprinting headers, seed/debug endpoints, browser-console automation, source-map exposure, and bundle budgets may belong to a second runtime-hardening spec. Report their current state and evidence separately rather than failing the metadata/SEO spec for out-of-scope work; never silently mark them resolved.

When a pre-deploy review produces several findings across different concerns, write separate specs before implementation instead of one oversized "polish" batch. A useful
split is: (a) public surface/metadata/SEO (404, titles, descriptions, OG, JSON-LD,
canonical, robots, sitemap, llms) and (b) runtime hardening/performance (fingerprinting
headers, seed/debug routes, browser console, source maps, bundle budgets). For private
single-user apps, define the indexability policy explicitly: do not make dashboards,
financial data, or auth-protected pages indexable merely to satisfy a generic SEO list.
Use `noindex` and crawler exclusions where appropriate, and classify a sitemap with no
public URLs as an intentional result rather than inventing public content. Include the
exact policy and the evidence needed for each item in the spec's acceptance criteria.

## Recovering from Unrequested Local Agent Changes

When the user explicitly says an agent changed the local project without authorization and
wants the GitHub version restored, stop feature review and switch to a destructive-recovery
workflow:

1. Inspect `git status`, recent commits, remotes, then run `git fetch origin` before claiming
   the remote is current. If fetch/authentication fails, state that `origin/main` is only the
   last cached remote ref, not proof of live GitHub state.
2. Preserve `git diff --binary` and all non-ignored untracked files in `/tmp` before deleting
   them, while never archiving `.env*` or ignored secret material.
3. Only after explicit user authorization, run `git reset --hard origin/main` and
   `git clean -fd`; otherwise use selective cleanup.
4. Verify `git status -sb`, `HEAD`, and `origin/main`; report the exact SHA and any fetch
   authentication blocker. Do not push or re-commit the reset unless asked.

This is distinct from ordinary review cleanup: never discard uncommitted work merely because
it is unrelated or because a clean tree is convenient.

## 5. Delivery sequence

1. Patch only demonstrated defects and add regressions.
2. Re-run the complete gates after the final edit — this includes TINY edits made during
   the review itself (e.g. a 4-line lint fix); recorded evidence must match the final
   tree or the freshness check will flag it.
3. Stage only intended project files.
4. Commit with Conventional Commits and a message describing the feature.
5. Push to the intended branch.
6. Verify local SHA equals the remote SHA and the worktree is clean.
7. Update project notes (Obsidian or the repository's equivalent) with:
   - current state and completed requirements,
   - remaining backlog,
   - commands and evidence,
   - commit/remote reference,
   - important architecture decisions.

Never claim a commit, push, or documentation sync without a verifiable path, SHA, or
on-disk confirmation.

## 6. Reporting style

The user prefers Spanish and values concrete verification over "ok". Report:

- what was reviewed,
- any defects fixed and why,
- exact gates and observed results,
- commit/push SHA and clean-tree status,
- documentation synchronized,
- non-blocking warnings or remaining risks.

Keep the report structured and direct; do not fabricate missing output.

## References

- `references/git-restore-after-unrequested-agent.md` — destructive but authorized recovery of a local checkout to the remote-tracking source of truth, including pre-delete audit backup and fetch-auth caveats.
- `references/ui-button-conventions-review.md` — button-convention review playbook:
  3 layers to check (modal rows, mobile page CTAs, inline card confirms), browser
  ground-truth rules (DOM-click fallback, outerHTML vs phantom snapshots, session
  invalidation on rebuild), authenticated visual verification without the password
  (forgot/reset via container logs), and dropping the quick-tunnel stack
  (`docker compose rm -sf` + commit-before-user-edits flow).
- `references/nextjs-sdd-review-notes.md` — reusable notes from the Next.js monthly-cycle,
  snapshot, budget, route-migration, peer-dependency, and additive-field/enum-extension
  review patterns.
- `references/public-quality-review-heuristics.md` — strict recipes for environment-sensitive metadata tests, OG-image bounds, baseline provenance, standalone-runtime verification, source-map reachability, and split-spec reporting.
- `references/manual-e2e-verification.md` — live-server verification recipes: log
  capture, orphaned `next start` cleanup, redacted-token handling, browser click
  fallback, dev-DB state after the test suite, cleanup of verification records,
  before/after measurement probes for progress bars/counters (budget `usedAmount`),
  DOM-style ground truth for thin UI widgets, stale-test fixes after semantics-changing
  UI edits, and creating a memorable test account when the suite wiped the users.
- `references/deploy-spec-prechecks.md` — HTTPS/containerization seams to verify by
  reading code BEFORE writing a production spec: cookie secure flags, relative SW URLs,
  dead NEXT_PUBLIC vars, JWT_SECRET requirement, LAN-safe port bindings, DB volume
  continuity, test-DB isolation — and post-execution verification of an executor's
  deploy report (tunnel curl + remote IP, `docker compose ps`, secrets scan,
  `restart` vs `up -d` for env_file, lint hygiene on new scripts).
- `references/vercel-and-domain-migration.md` — Vercel serverless-readiness pre-check
  (db.ts global cache, no fs, lazy rollover, conditional standalone + two-build
  verification), Atlas M0 costs, backup-script portability pitfall (production backup must
  not depend on the dev docker stack — disposable `docker run --rm mongo:7` for remote
  URIs), "separate back/front" vs all-in-Vercel rationale for Next.js fullstack,
  Mongo-backed rate limiting without npm deps (fixed window + TTL + atomic upsert +
  route-signature-change pitfall), Vercel-vs-VPS decision matrix, domain purchase guidance
  (Cloudflare at-cost, .com.ar free), quick-tunnel operational facts (efímera URL, PWA
  re-install, PC-off semantics, single-user 409 + demo-instance options), the
  verification freshness rule (full gates after ANY review edit), Atlas URI loading via
  direct shell assignment (the user's terminal cannot paste into `read -s`; assignment is
  the requested method), region migration (new Atlas project required — DB user + IP access
  list do NOT carry over between projects), and hung-login diagnostics (fast 401s are
  proxy-pre-Mongo; a hung public login endpoint means the function cannot reach Mongo).
