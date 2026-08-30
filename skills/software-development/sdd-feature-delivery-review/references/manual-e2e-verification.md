# Manual E2E verification (live server)

Context: verifying SDD features end-to-end on the running Next.js app (dev or `next start`)
— beyond unit/integration tests. Proven during the PWA/notifications and
gastos-de-pareja + password-recovery delivery reviews.

## Launching and owning the server

- Build fresh (`npm run build`), then run `npm start > /tmp/<app>-server.log 2>&1` in
  background so the real log lands on disk (process previews truncate long lines).
- `process kill` on the `npm start` session does NOT kill the `next start` grandchild —
  the port stays bound (EADDRINUSE on relaunch). Free it with `fuser -k 3000/tcp`
  (or the app's port), verify the port is free, then relaunch.
- Check readiness with `curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/<route>`
  before driving the browser.

## Reading tokens / secrets from server logs

- Tool output (terminal, read_file, process preview) redacts secret-looking strings: a
  printed JWT shows as `eyJhbG...2thM` even though the file holds the full token.
- Prove the full value is present without printing it:
  - line length: `awk '/RECUPERACIÓN/{print length($0)}' /tmp/server.log` (a JWT line is ~300+ chars)
  - JWT segment count: `echo "$TOKEN" | tr -cd '.' | wc -c` → 2 dots = 3 segments (valid HS256 JWT)
- Use the secret in-shell without echoing it:
  `TOKEN=$(grep -oP 'eyJ[A-Za-z0-9._-]+' /tmp/server.log | tail -1)` then pass into the
  next `curl` (`-d "{\"token\":\"$TOKEN\",...}"`); print only status codes.
- One-time semantics can be proven live: reuse the same token on a second request and
  expect 400.

## Browser-driven flows

- If the automation runtime's click does not transition a React state (button stays put),
  dispatch a real click from the page context — this is what a real user does:
  `browser_console` expression:
  `([...document.querySelectorAll('button')].find(b => b.textContent.trim() === 'X')).click()`
- The browser session can drop to `about:blank` between calls (subsequent clicks/types are
  blocked with "targets a private or internal address"). Re-navigate with browser_navigate;
  re-login afterwards (the session cookie lives in the ephemeral browser profile).
- Create fixture data from the page context (`fetch` same-origin → cookie sent
  automatically), reload the page, and compare rendered numbers to hand-computed
  expectations (e.g. couple balance: paidByMe + 50% of shared − paidByPartner).

## DB state after the test suite

- FIRST check whether the suite is isolated: `src/test/setup.ts` pinning
  `process.env.MONGODB_URI` to a `*_test` database (e.g. `cashinsightapp_test`) means the
  gates run against a SEPARATE DB — dev data and the manual-test account survive intact
  (proven: 201-test run left `prueba@cashinsight.app` fully working). In that case
  "login 401 after gates" has another cause (wrong email, wrong password, expired
  session); inspect, don't assume.
- Only when the suite shares the dev DB (`deleteMany({})` in `beforeEach`) will the
  gates leave whatever the last test file wrote (test emails) instead of the real user.
- Inspect actual state instead of guessing:
  `docker exec <mongo-container> mongosh --quiet cashinsightapp --eval 'db.users.find({}).toArray().map(u => ({email: u.email}))'`
- Manual login verification must use an email that actually exists (from that query).

## Cleanup after manual verification

- Delete records created for verification through the API with a cookie jar:

```bash
JAR=$(mktemp)
curl -s -c "$JAR" -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' -d '{"email":"<real-test-email>","password":"..."}' -o /dev/null
curl -s -b "$JAR" 'http://localhost:3000/api/transactions?month=YYYY-MM' > /tmp/txs.json
# select your fixture ids (e.g. description prefix) and:
for id in <ids>; do curl -s -b "$JAR" -X DELETE "http://localhost:3000/api/transactions/$id" -o /dev/null; done
rm -f "$JAR" /tmp/txs.json
```

- If a test-user's password was changed during recovery verification, it does not matter:
  the next test run recreates the user. Only restore passwords for real users' data.

## Feature probes: before/after measurement (progress bars, counters)

For anything countable (budget `usedAmount`, `usagePercent`, balances, feeds), prove it
with a measurement harness instead of eyeballing:

1. Login once with a cookie jar, snapshot the before-state of the affected endpoint
   (`GET /api/budgets` → per category: usedAmount, usagePercent, status).
2. Create one fixture per entity via the API (`POST /api/transactions` with a distinct
   description prefix like `Verificación budget X`), one at a time, per category.
3. Re-fetch and assert the delta equals the fixture amount exactly, per category.
4. Re-run the endpoint variant the feature's page actually uses (e.g.
   `/api/budgets?behavior=variable` for the Control page) — the numbers must match the
   unfiltered read.
5. Cross-check the rendered UI with `browser_vision` (bar length, % text) against the API
   values — but compare against the API decimals, NOT the displayed integer: the card
   renders `usagePercent.toFixed(0)`, so 0.24% shows as "0%" (rounding, not a bug).
   CAUTION: vision is unreliable for thin widgets (h-2 = 8px bars) — one session it
   described bars as "~1/5 full / almost empty" while the DOM read 80.6%–99.78% width,
   fully inverting the used-vs-remaining semantics. When bars are thin or vision
   contradicts the API numbers, take ground truth from the DOM instead:

   ```js
   // browser_console — read the fill element's real style/class:
   const section = [...document.querySelectorAll('section')]
     .find(s => s.getAttribute('aria-label') === 'CONTROLA TUS LÍMITES' /* match label */);
   [...section.querySelectorAll('.h-2')].map(b => ({
     width: b.firstElementChild.style.width,           // e.g. "97.52%"
     cls: b.firstElementChild.className,               // e.g. "bg-emerald-500"
   }));
   ```

   A bar whose fill width is 100 − usagePercent is a REMANENTE bar (goes DOWN as you
   spend) — verify against the API decimals: usagePercent 2.48 → fill 97.52%.
6. Delete all fixtures afterwards (same cleanup pattern above) and leave the DB as found.

Quick parse of the budgets payload (pipe curl into python3 is fine):

```bash
curl -s -b "$JAR" 'http://localhost:3000/api/budgets' | python3 -c "
import json, sys
data = json.load(sys.stdin)
budgets = data if isinstance(data, list) else data.get('budgets', [])
for b in budgets:
    print(b['category']['name'], b['usedAmount'], b['amount'], b['usagePercent'], b['status'])
"
```

## Stale unit tests after semantics-changing UI edits

A UI-polish batch can land with tests still asserting the REPLACED implementation — the
executor ran gates before the last edits, or the tests target removed internals. Symptom:
after the final edits, full-gate runs go RED in test files the feature diff didn't touch
(example: `budget-card.test.tsx` asserting `.tremor-ProgressBar-progressBar`,
`bg-amber-500`, `bg-rose-500` after the bar was rewritten as a custom div showing the
REMAINING budget with `bg-emerald-500` / `bg-rose-600` only).

Fix rule: rewrite the tests to the new INTENDED behavior with real math (remaining =
100 − usagePercent, floor 0; threshold ≥80% → rose), asserting the semantics the feature
shipped — not merely patching class names to force green, and never deleting assertions
(the regression value would be lost). Then re-run ALL gates (`npm run test`,
`npx tsc --noEmit`, `npm run lint`, `npm run build`) and record the new totals; the test
count itself changes (e.g. 196 → 201), which the report and Obsidian notes must reflect.

## Preflight before build / deploy

- Kill the running server BEFORE `npm run build` (next start serves from `.next` and a
  concurrent build can corrupt/pick it up mid-write) and before `docker compose up`
  (the `3000:3000` bind collides with a residual `next start` → EADDRINUSE inside the
  container/port already allocated). `fuser -k 3000/tcp`, verify free, then build/deploy.
- Leave the port free after verification so the user's deploy or dev server can take it.

## Creating a memorable test account

With an isolated `*_test` DB the suite does NOT wipe dev users — so this is usually
triggered by the USER asking for credentials for manual testing, not by the gates.
Write one directly (single-user app: update the ONE existing doc):

```bash
cd <app-root> && node -e "
const bcrypt = require('bcryptjs');           // require works: package.json is CJS
const mongoose = require('mongoose');
(async () => {
  await mongoose.connect('mongodb://localhost:27017/<db>');
  const users = mongoose.connection.collection('users');
  const hash = await bcrypt.hash('<password>', 10);
  await users.updateOne({}, { \$set: { email: '<email>', passwordHash: hash } });
  await mongoose.disconnect();
})().catch(e => { console.error(e.message); process.exit(1); });
"
```

Then prove login with `curl` returning 200 (with the user payload) before telling the user
the credentials. Password rule: min 8 chars (same as register/reset).