# Vercel migration + domain + quick-tunnel ops (Next.js fullstack)

Context: a Next.js fullstack app (API routes + Mongoose) deployed locally via Docker
Compose + Cloudflare quick tunnel. Next phase chosen by the user: **Vercel + Atlas M0**.
This note is the decision/migration knowledge bank; pair with `deploy-spec-prechecks.md`.

## Serverless-readiness pre-check (read code, never assume)

Vercel runs Next API routes as native serverless functions — no separate backend needed
when the "back" lives in `src/app/api/*`. Before writing a Vercel spec, verify:

- **Mongoose connection cache**: `src/lib/db.ts` must use the global-cache singleton
  (`cached.conn`/`cached.promise` on `global.mongoose`) so each cold function reuses one
  connection. This pattern is already serverless-correct — confirm, don't rewrite.
- **No server-side filesystem**: `grep -rn "fs\.\|process\.cwd\|writeFile\|readFile" src/`
  (exclude tests). Zero hits = safe on ephemeral functions.
- **No server cron**: a lazy, request-triggered monthly rollover (idempotent, first request
  of the month) is serverless-friendly; a scheduled job would need Vercel Cron.
- **`MONGODB_URI` env var** (with localhost fallback) already in place → point it at Atlas.
- **Conditional `output: 'standalone'`**: keep standalone for the Docker self-host,
  disable on Vercel (own pipeline):
  `output: process.env.VERCEL ? undefined : 'standalone'` — Docker build unaffected since
  `VERCEL` is unset there. Verify BOTH pipelines (executor-report criterion, never trust
  the claim): `rm -rf .next && VERCEL=1 npm run build` → `.next/standalone/server.js`
  must NOT exist; plain `npm run build` → it MUST exist (Docker runner copies it).
- **Password-recovery token prints to console** → on Vercel it lands in the function's
  dashboard logs (same flow, different window). Document in the spec.

## Cost/limits facts (2026)

- Vercel Hobby: $0, 100GB bandwidth/mo, HTTPS + stable URL auto (`*.vercel.app` or domain).
- Atlas M0 (free forever): 512MB, **NO automatic backups** → adapt the local backup script
  from `docker exec <mongo> mongodump --uri 127.0.0.1...` to `mongodump --uri <ATLAS_URI>`
  (run from any machine / cron). **Pitfall (found in review)**: an executor may keep
  `docker exec <dev-container> mongodump` for the Atlas URI "because the container has
  internet" — that couples the ONLY production safety net to the dev stack (backup fails
  when docker compose is down). Fix pattern: branch on the URI — local
  (`mongodb://127.0.0.1*|localhost*|mongo*`) keeps `docker exec <dev-container>`, remote
  uses a disposable container `docker run --rm mongo:7 mongodump --uri "$DB_URI" --archive`
  (zero dev-stack dependency). Read the URI from env with `./.env` fallback, never print it
  (contains the password); verify with `gunzip -t`; run the local branch end-to-end and
  delete the test artifact.
- Vercel + Atlas M0 = $0/month total; VPS would be $5-10/mo + your own maintenance
  (security updates) but zero code changes (same compose). Decision matrix for the user:
  single-user + $0 + no infra chores → Vercel wins; Mongo under full control / filesystem
  features (temp CSV/PDF export) later → VPS stays the alternative.

## "Separate back/front" advice vs all-in-Vercel (Next.js fullstack)

When the user gets the generic recommendation "deploy the back on Railway/Render and the
front on Vercel": in Next.js fullstack there IS no separate back — API routes live in
`src/app/api/*` in the same repo/process. Splitting means rewriting the API layer as a
standalone Express/Fastify service, converting every relative `fetch('/api/...')` to an
absolute URL + CORS, and losing the httpOnly SameSite cookie (cross-site cookies need
SameSite=None + Secure + credentials — a security/config tax). Costs more (Railway has no
real free tier ~$5/mo; Render free sleeps with 30-60s cold starts), adds a network hop,
and buys zero scaling for a single-user MVP. Vercel serverless ALREADY runs each API route
as an independent function — the split is de facto built in. Reject the advice with this
reasoning; the split only pays when a real standalone backend exists (jobs/queues, mobile
clients, third-party API consumers) — and that is a separate project, not a pre-deploy step.

## Rate limiting without external deps (serverless, Mongo-backed)

Checklist item #1 (rate limiting on public endpoints) in a serverless app can be done with
zero npm deps: fixed window by (route, ip) persisted in Mongo. Pattern that worked:
- Model: `ratelimits` collection `{ key (unique), count (default 0), resetAt }` with
  `index({ resetAt: 1 }, { expireAfterSeconds: 0 })` (TTL auto-cleanup).
- Key: `${route}:${ip}:${windowStart}` where
  `windowStart = Math.floor(Date.now() / WINDOW_MS) * WINDOW_MS` (clock-aligned window).
- One atomic op: `findOneAndUpdate({ key }, { $inc: { count: 1 }, $setOnInsert: { resetAt } },
  { upsert: true, returnDocument: 'after' })` → blocked when `doc.count > MAX`.
- IP: first hop of `x-forwarded-for` (Vercel sets it; first value is the real client),
  fallback `'unknown'`.
- Integration: `await connectDB()` THEN `isRateLimited(...)` at the TOP of the try, BEFORE
  body parsing, in login/register/forgot/reset only. **Pitfall**: changing route signature
  `POST()` → `POST(request: Request)` breaks existing tests that call the route with no
  args — update them in the same commit.
- Window constants exported for tests; test matrix: 11th attempt → 429 with exact message,
  different IP not blocked, private routes unaffected, per-route isolation (login blocked
  does not block register).

## Domain purchase guidance (es-AR user)

- **Cloudflare Registrar** sells at cost: `.com` ≈ USD 10.45/yr, renewal == first year
  (no promo traps). Ideal when already using Cloudflare Tunnel — DNS + named tunnel in one
  panel. Buy at `domains.cloudflare.com` (account + international card; AR banks add their
  own fees/impuestos).
- **Porkbun**: second option, more TLDs, similar renewals.
- **Namecheap/Spaceship**: cheap FIRST year ($1-3) but renewal ~$12-15 — only worth it for
  a 1-year trial. `.xyz/.online/.site` same trap.
- **`.com.ar` is free** via NIC Argentina but requires CUIT + a state form (titular alta);
  works with Cloudflare (delegate nameservers). More trámite, zero cost.
- Named-tunnel wiring once a domain exists: `cloudflared tunnel login` →
  `cloudflared tunnel create <name>` → DNS CNAME `<uuid>.cfargotunnel.com` → compose
  tunnel service runs `tunnel --no-autoupdate run <name>` with `~/.cloudflared` volume.

## Quick-tunnel operational facts (local phase)

- URL is efímera: changes on every tunnel service recreation. Re-read with
  `docker compose logs tunnel | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' | head -1`.
- A PWA installed from a quick-tunnel origin must be RE-installed when the URL changes
  (different origin = different SW). The domain fixes this permanently.
- `restart: unless-stopped` + docker systemd service = containers auto-recover on boot;
  PC off = service down everywhere (localhost AND tunnel). "¿apago la pc?" → the honest
  answer is: nothing is reachable while off; on boot everything returns with zero manual
  steps, only the tunnel URL may have changed.
- Single-user app behind a public tunnel: a friend CANNOT register (unique singleton
  index → 409). Two demo paths: share the single account (same live data, full edit
  access) or a disposable second instance (separate compose project via
  `docker compose -p <name>`, override `container_name` + port + volume + own tunnel),
  torn down with `down -v` — safe because it is demo-only, never on the real project.

## Atlas M0 UI setup + least-privilege migration checklist

When guiding a user through the Atlas UI, distinguish the Atlas project/cluster scope from
the MongoDB database-user scope. The Atlas UI may offer only global built-in roles in the
**Built-in Role** dropdown (`Atlas admin`, `readWriteAnyDatabase`, `readAnyDatabase`). Do
**not** choose `readWriteAnyDatabase` just because it is the closest label.

Use **Specific Privileges** instead:

1. Add the `readWrite` role on database `cashinsightapp` with collection left blank (all
   non-system collections in that database).
2. Remove the selected global built-in role. If the UI will not remove the only selected
   built-in role, cancel the edit and recreate the database user with only the specific
   privilege; deleting a database user does not delete cluster data.
3. Restrict the user to the `CashinsightApp` cluster when the UI offers resource scoping.
   Cluster scoping is not database scoping: verify the final row says
   `readWrite@cashinsightapp`, not `readWriteAnyDatabase@admin` or `All Resources`.
4. `0.0.0.0/0` is required for a Vercel Hobby/serverless deployment without fixed egress,
   but record it as an explicit risk accepted with a database-scoped user, strong password,
   application rate limiting, and no admin role.

If Atlas has loaded its sample dataset, check the Data Explorer/database names before
migration. Remove only databases whose names begin with `sample_`; never drop `admin`,
`config`, `local`, or `cashinsightapp`. The sample dataset can consume a material portion
of an M0's 512 MB limit, so clean it before restoring the application's dump.

For migration, capture local counts and a verified local dump first, then restore to Atlas
using a disposable `mongo:7` container so the operation does not depend on the dev app
stack. Compare `users`, `categories`, `transactions`, `savingsgoals`, `budgets`,
`financialprofiles`, and `monthlysnapshots` counts before deploying Vercel. Never paste the
Atlas URI/password into chat, git, or evidence logs.

## Atlas URI loading, region migration & hung-login diagnostics (verified 2026-08-14/15)

### Cargar URI de Atlas en la terminal — método preferido del usuario

- NO proponer `read -r -s -p '...' VAR` para pegar URIs: en la terminal del usuario el
  portapapeles falla (clic izquierdo no pega; Ctrl+Shift+V / Shift+Insert dependen de la
  terminal) y el usuario cree que "no pegó". El usuario pidió explícitamente la
  **asignación directa con comillas simples**:

```bash
ATLAS_URI='mongodb+srv://USER:PASS@cluster.mongodb.net/cashinsightapp?appName=CashinsightApp'
export ATLAS_URI
```

- Migración entre dos bases: cargar `ATLAS_URI_VIEJA` y `ATLAS_URI_NUEVA` con el mismo patrón.
- Verificar sin imprimir credenciales: `[ -n "$ATLAS_URI" ] && echo "URI cargada"`.
- La URI queda en el historial de la sesión → `history -c` o cerrar terminal al terminar.
- Errores típicos que confunden: `Invalid URI: docker run ...` (la variable quedó con el
  comando pegado), `ECONNREFUSED 127.0.0.1` (variable vacía), `mongosh: no se encontró la
  orden` (falta `docker run --rm mongo:7`; el host no tiene mongosh), `not allowed to do
  action [find] on test.users` (falta `/cashinsightapp` en la URI → conectó a la DB `test`).
- Ejecutar SIEMPRE desde el directorio del proyecto (`cd`), no desde `~`: los scripts y
  `backups/` son relativos.

### Cambiar de región del cluster Atlas (Vercel Hobby)

- Vercel Hobby corre en us-east-1; Atlas en otra región (ej. sa-east-1) agrega ~130-200ms
  RTT por request (medido: login 1.34s y summary 0.83s vs objetivo ~0.6s / 0.3-0.5s warm).
- Atlas permite **1 solo M0 por proyecto** → mover región = crear un **proyecto nuevo**.
- ⚠️ **El usuario DB y el IP access list NO se copian entre proyectos**: hay que recrearlos
  en el proyecto nuevo (`readWrite` sobre la DB + `0.0.0.0/0`). Si la URI nueva referencia
  un usuario inexistente en el proyecto nuevo, la conexión se cuelga (timeout 60-90s) en
  vez de fallar rápido — síntoma idéntico al de "Vercel lento".
- Procedimiento: backup fresco del Atlas viejo
  (`MONGODB_URI="$ATLAS_URI_VIEJA" ./scripts/backup.sh`) → restore al nuevo con
  `gunzip -c ... | docker run --rm -i mongo:7 mongorestore --uri "$ATLAS_URI_NUEVA" --archive --drop`
  → verificar conteos → cambiar `MONGODB_URI` en Vercel (Production + Preview) → **Redeploy**
  (las env vars no se toman sin redeploy).

### Diagnóstico de lentitud / login colgado en Vercel

- Medir con `curl -w` (`time_total`, `time_starttransfer`) por endpoint; comparar 1er hit
  (cold start de Hobby) vs segundo (warm).
- El proxy corta `/api/*` sin sesión con 401 **antes de tocar Mongo** → 401 rápidos
  (150-250ms) NO indican problemas de DB. Los endpoints públicos (login/register/forgot/reset)
  sí llegan a la función.
- Login que da timeout (0 bytes, 60-90s) = la función no conecta a Mongo. Revisar en orden:
  (1) estado del cluster (Active vs Creating), (2) usuario DB + IP access en el PROYECTO
  correcto (ver pitfall de región), (3) ping desde la máquina
  (`docker run --rm mongo:7 mongosh "$URI" --quiet --eval 'db.runCommand({ping:1})'`),
  (4) logs de la función en Vercel (MongoServerSelectionError / Authentication failed).
- El dashboard `/` sirve el shell rápido (SSR ~180ms) y carga los datos por fetch del
  cliente a `/api/reports/summary` — un solo request pesado (connectDB + rollover lazy +
  5 queries en Promise.all) que define la latencia percibida.

## Verification freshness rule

After ANY edit during a review — including a 4-line lint fix in a helper script — re-run
the complete gate set (test / tsc / lint / build) and a runtime boot check
(`next start` + curl `/login`, manifest, sw.js → 200) so the recorded evidence matches the
final tree. Freshness of evidence is enforced; don't report gates from before the last edit.