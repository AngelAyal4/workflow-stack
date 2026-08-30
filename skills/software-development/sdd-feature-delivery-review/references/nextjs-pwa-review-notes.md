# PWA + notificaciones locales — review notes (Next.js 16)

Conocimiento validado revisando la feature "PWA instalable + notificaciones" de una app
Next.js 16 (App Router, Turbopack, localhost single-user). Las guías oficiales viven en el
propio paquete instalado — leerlas ANTES de evaluar viabilidad:
`node_modules/next/dist/docs/01-app/02-guides/progressive-web-apps.md`,
`offline-support.md`, y `.../01-metadata/manifest.md`.

## Manifest nativo (no plugins)

- `src/app/manifest.ts` exportando `MetadataRoute.Manifest` — Next inyecta el
  `<link rel="manifest" href="/manifest.webmanifest">` solo; NO tocar el layout.
- En producción queda prerendered como ruta estática (`○ /manifest.webmanifest` en el tree
  del build). Verificar: `curl -I /manifest.webmanifest` → 200, `application/manifest+json`,
  y el JSON trae `icons` con 192/512 o SVG `sizes:"any"`.
- Íconos: PNG 192/512 requiere ImageMagick (`which convert`); si no hay, SVG con
  `sizes:'any', type:'image/svg+xml'` es válido para instalar en Chrome. `maskable` exige
  safe-zone: contenido dentro del 80% central, fondo full-bleed. SVG plano con paths (no
  `<text>` con fuentes externas) = determinista y <1KB.

## Service Worker estático (`public/sw.js`)

- Servido por Next sin config especial; en `next.config.ts` agregar headers solo para
  `/sw.js`: `Content-Type: application/javascript; charset=utf-8` y
  `Cache-Control: no-cache, no-store, must-revalidate` (el SW se actualiza con el registro).
- Registro desde un Client Component con guards (`'serviceWorker' in navigator`,
  `typeof window !== 'undefined'`), `document.readyState === 'complete'` o listener `load`,
  `register('/sw.js', { scope: '/' })`, catch silencioso. Inofensivo en SSR/jsdom.
- **Fetch handler que NO rompe Next**: solo `request.method === 'GET'`,
  `url.origin === self.location.origin`, **`/api/` siempre a red** (nunca cachear datos),
  y distinguir `request.mode === 'navigate'` (cache-first del shell + revalidación en
  background, fallback a `caches.match('/')`) del resto — los fetch RSC de las
  soft-navigations NO son `mode:'navigate'`, así no se interceptan.
- Precache en `install` con `Promise.allSettled` (una URL que devuelve redirect de auth —
  p.ej. `/` → `/login` — no aborta la instalación; `cache.add` sigue el redirect y guarda
  la respuesta final).
- `notificationclick`: close + `clients.matchAll({type:'window', includeUncontrolled:true})`
  → focus + `navigate(data.url)`, si no `clients.openWindow`. `notificationclose` no-op.

## Notificaciones locales vs push remoto

- Para una app local single-user SIN servidor 24/7 ni cron, push remoto (web-push/VAPID/
  suscripción PushManager) no tiene disparadores reales: queda out of scope. Las
  **notificaciones locales** (`registration.showNotification` tras `navigator.serviceWorker.ready`)
  cubren el caso (usuario con la app abierta, umbrales superados). Disparadores por umbrales
  en el cliente, sin polling.
- Guard triple en el wrapper: soporte (`'Notification' in window` + serviceWorker) +
  `getPermission() === 'granted'` + flag opt-in persistente en localStorage
  (`isEnabled`/`setEnabled` con try/catch — el permiso del navegador NO se puede revocar
  desde JS, el flag es el opt-out de la app). Wrapper "nunca lanza".
- Separar la lib en dos: wrappers de browser API (`notifications.ts`, side-effects, fuera
  del gate de coverage — precedente: componentes) y evaluadores puros de umbrales
  (`notification-triggers.ts`, testeable en environment `node`, dentro del gate — precedente:
  `format.ts`).

## Pitfall real encontrado en review: dedupe optimista

`dispatchAlerts` agregaba la key al `Set` de dedupe ANTES de `await showNotification(...)`.
Si al evaluar no había permiso/flag (usuario que todavía no activó), la key quedaba marcada
y el aviso se perdía para toda la sesión aunque después activara las notificaciones.
**Fix**: `const delivered = await showNotification(...); if (delivered) { set.add(key) }` —
marcar SOLO lo que realmente se mostró. Test de regresión con
`mockResolvedValueOnce(false)` → dispatch; luego `mockResolvedValueOnce(true)` → dispatch
de nuevo DEBE notificar. Si el reviewer no lo ve, el usuario percibe "activé las
notificaciones y nunca me avisó".

## Otros pitfalls Next 16 / jsdom

- El plugin `react-hooks` de Next 16 (`react-hooks/set-state-in-effect`) rechaza
  `setState` dentro de `useEffect` para derivar estado sincrónico → usar
  `useSyncExternalStore(subscribeLocal, getSnapshot, serverSnapshotFalso)` con un
  `Set` de listeners + `emitChange()` tras las acciones; `subscribe` devuelve cleanup.
- ESLint de Next puede NO tener activa `no-undef` → `sw.js` (globals de SW: `self`,
  `caches`, `clients`) puede pasar sin `globalIgnores` en `eslint.config.mjs`; probar
  lint antes de agregar ignores.
- Recharts en jsdom: warning de stderr "width(0) and height(0) of chart" — inofensivo,
  el test pasa; documentar como no-bloqueante.
- Hermes terminal: no mezclar `docker ps ... || docker compose up` en un comando (el guard
  lo interpreta como server long-lived y lo rechaza); verificar el estado con `docker ps`
  solo, y levantar por separado.

## Verificación manual PWA (revisión real)

1. `npm run build` → levantar `next start` (el SW en `next dev` con Turbopack NO es
   referencia confiable; validar siempre en build+start).
2. `curl -I /manifest.webmanifest` (200 + content-type), `curl -I /sw.js`
   (content-type js + no-store), `curl -s -L <url-login> | grep 'rel="manifest"'`.
3. Chromium real con browser tools: `browser_navigate` a la app → `browser_console` dos
   pasos (expresión async guarda en `window.__check`, segunda llamada lee el JSON):
   `navigator.serviceWorker.getRegistration()` → `{scope, active.state}` y
   `navigator.serviceWorker.controller?.scriptURL`. "activated" + controller presente =
   instalabilidad Chrome cumplida (manifest válido + SW activo). El prompt de instalación
   nativo no es verificable programáticamente — reportar que sus prerequisitos sí.
4. El disparo real de notificación requiere permiso nativo del navegador: cubrirlo con
   tests unit (guard triple) y reportar honestamente que el E2E manual quedó en tests.