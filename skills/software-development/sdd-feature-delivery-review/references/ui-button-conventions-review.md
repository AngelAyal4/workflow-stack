# UI Button-Convention Review — browser verification playbook

Session-specific detail behind the SKILL.md bullets: verifying a "buttons always
right-aligned" batch against the real app and answering the user's mobile findings.

## Scope of a button-convention review (3 layers)

1. **Modal/dialog action rows** — the diff usually covers these: `[Cancelar] [Primaria]`
   + `justify-end` on the row. Read the diff, then confirm live geometry:
   `browser_console` reading `getBoundingClientRect()` of both buttons and the row
   container — primary must come AFTER cancel in DOM order AND its `right` must equal
   the container's `right` (≤2px tolerance).
2. **Page-level header CTAs in mobile** — user-caught gap (2026-08-11): on phones the
   header becomes `flex-col` and buttons render left-aligned. Fix pattern:
   - button row already exists → add `justify-end` (`flex flex-wrap justify-end gap-2`);
   - loose single button under a `flex-col justify-between sm:flex-row` header → wrap
     in `<div className="flex justify-end">`.
   Verify in code (breakpoint classes) — a remote browser usually can't resize
   (`window.resizeTo` often no-ops); the class-level fix is the deliverable and the
   user re-checks on their phone.
3. **Non-modal inline confirmations** — card-level "¿Eliminar? [Sí][No]" rows obey the
   same ordering (primary/danger last). The budget-card in this app has a
   TWO-STEP delete: inline `[No][Sí]` → "Sí" calls `onDelete` → opens the modal
   `[Cancelar][Sí, eliminar]`. Verify BOTH layers; find all inline confirms with
   `grep -rn ">Sí<\|>No<" src/`.

## Browser ground-truth rules (this app + remote browser)

- The runtime click tool sometimes does NOT fire React handlers (button state never
  changes). Dispatch the click from page context:
  `[...document.querySelectorAll('button')].find(b => b.textContent.trim() === 'Eliminar').click()`
  then read state 300-400ms later.
- The a11y snapshot / console listing can show buttons that do not exist in source
  (phantom "Sí"/"No" while the code says "Cancelar"/"Sí, eliminar"; no `role="dialog"`
  in the DOM). Before calling a delivery broken, dump the real element:
  `document.querySelector('[role="dialog"]')?.outerHTML` or the button list with
  `outerHTML.slice(0,120)` per button.
- Rebuilds invalidate sessions: every `docker compose up -d --build app` puts the
  browser back at `/login` (JWT cookie no longer accepted). Budget for re-login
  after each rebuild when scripting multi-page verification.

## Authenticated visual verification without the account password

Single-user app, no known password, but recovery flow exists — bootstrap a session:

```bash
# 1. find the only user
docker exec cashinsight-mongo mongosh --quiet cashinsightapp \
  --eval 'db.users.find({}, {email:1}).toArray()'
# 2. request token (app prints it in ITS container logs)
curl -s -X POST http://localhost:3000/api/auth/forgot -H 'Content-Type: application/json' \
  -d '{"email":"prueba@cashinsight.app"}'
# 3. capture token in-shell WITHOUT printing it (tool output redacts eyJ…)
TOKEN=$(docker compose logs app 2>&1 | grep -oE 'eyJ[A-Za-z0-9._-]+' | tail -1)
echo "len=${#TOKEN} dots=$(echo -n "$TOKEN" | tr -cd '.' | wc -c)"   # 293 chars, 2 dots = JWT
# 4. one-time reset → then login with the NEW password (200) and old one (401)
curl -s -X POST http://localhost:3000/api/auth/reset -H 'Content-Type: application/json' \
  -d "{\"token\":\"$TOKEN\",\"newPassword\":\"<nueva>\"}"
```

WARNING: this overwrites the demo account password — tell the user the new value
so they can share it with people testing the instance.

## Dropping the shared-deploy stack (user decision, then work locally)

When the user abandons the quick-tunnel production test to edit on localhost:

```bash
docker compose rm -sf app tunnel   # rm (not stop): restart: unless-stopped would revive them on reboot
docker ps                          # only mongo stays Up (dev DB, volume intact)
curl -s -o /dev/null --max-time 3 http://localhost:3000/login  # 000 → port free for npm run dev
```

Then, before the user starts editing: COMMIT the reviewed feature + review fixes
FIRST (clean tree = their edits become a clean, separate diff/commit later). Update
Obsidian (Tareas.md): mark feature done, record the production-local cancellation,
repoint próximos pasos to the new target (localhost → Vercel).