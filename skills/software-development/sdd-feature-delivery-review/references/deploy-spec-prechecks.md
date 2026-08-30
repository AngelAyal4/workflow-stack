# Deploy-spec pre-checks (HTTPS / containerization seams)

Before writing a production/deploy spec (Docker Compose, tunnel, VPS), verify the app's
deployment-sensitive seams by reading code — never assume:

- **Session cookie flags**: check the auth lib for `secure` / `sameSite` / `httpOnly`.
  `secure: process.env.NODE_ENV === 'production'` works automatically under tunnel
  HTTPS, so the spec needs no cookie change — but verify it exists, else the spec must
  include it.
- **Service worker**: `public/sw.js` shell URLs must be RELATIVE (`'/'`, `'/login'`) to
  stay portable across origins (localhost dev vs tunnel/public domain). Absolute
  `http://localhost:3000/...` URLs would break the PWA in production.
- **Manifest**: `manifest.webmanifest` exists, is valid JSON, and is linked via
  `<link rel="manifest">` in layout HTML — PWA installability under HTTPS.
- **`NEXT_PUBLIC_*` vars**: `grep -rn "NEXT_PUBLIC_APP_URL" src/ public/` — a var that
  is configured but never read is NOT a deploy blocker; say so in the spec instead of
  wiring it pointlessly.
- **JWT_SECRET**: if the session lib throws when the secret is missing, `.env.production`
  must carry a generated one (`openssl rand -base64 32`), never committed, never printed.
- **Port bindings**: compose should bind the DB port to `127.0.0.1` (LAN-safe) when only
  the app container needs it; the tunnel service connects over the compose network, not
  the host port.
- **Test isolation**: `vitest.config.ts` + `src/test/setup.ts` pinning `MONGODB_URI` to a
  `*_test` DB means running the gates does not touch dev data — safe to run the suite
  while the dev DB holds the manual-test account.
- **Data continuity**: changing a service's ports in compose recreates the container but
  KEEPS the volume (`mongo_data`). Never write `docker compose down -v` anywhere in the
  spec; the up-steps must preserve the existing volume so dev data survives.
- **Deploy acceptance criteria must be verifiable**: curl status codes, `docker compose
  ps` health, PWA check (manifest + SW `state: activated`) via headless Chromium,
  persistence after `docker compose restart app`, backup produces a non-empty `.gz`.

Demo-exposure note: a single-user app behind a public tunnel (no rate limiting) is an
accepted risk for a trial — mitigate with strong password + rotate after, and stop the
tunnel when unused; document in the runbook.

## Verifying an executor's deploy report (post-execution)

An executor (e.g. running in opencode) claims 10/10 criteria passed. Re-verify with
independent evidence before committing — the deploy surface is live, so this is cheap:

- **Public tunnel URL**: `curl -s -o /dev/null -w '%{http_code} (%{remote_ip})'`
  on `/login`, `/manifest.webmanifest`, `/sw.js` — expect 200 ×3 and the remote IP
  belonging to Cloudflare (104.16.x / 104.17.x), proving traffic really goes outbound.
- **Containers**: `docker ps --format '{{.Names}}: {{.Status}}' | grep <project>` — the
  app/tunnel must be Up and mongo `(healthy)`; count the services the spec promised.
- **Secrets**: `git ls-files | grep -c .env.production` → 0, and grep the NEW files
  (Dockerfile, compose, scripts/, docs/) for `password|secret|jwt_secret|api_key` value
  patterns. `.env.production` being absent from `git status` is not enough — confirm
  `.gitignore` covers it (`backups/`, `evidencia/` too when logs may hold recovery tokens).
- **Lint hygiene on new scripts**: `npm run lint` after an executor's batch can surface a
  warning in a new script (e.g. `verify-pwa.mjs` used a ternary as an expression —
  `@typescript-eslint/no-unused-expressions`). Fix it (if/else) so the gate is 100%
  clean, syntax-check standalone .mjs with `node --check`.
- **Runbook claims**: the executive summary says "restore tested" / "backup works" —
  verify the runbook documents the exact commands (mongodump via `docker exec`,
  restore via descartable container on another port) and that `NUNCA down -v` is stated.
- **compose semantics worth re-checking in the diff**: `docker compose restart` does NOT
  re-read `env_file` (only `up -d` recreates) — a JWT rotation section must use `up -d`;
  removing the `version:` key is fine on Compose v2; healthcheck on mongo must gate
  `depends_on` with `condition: service_healthy`.