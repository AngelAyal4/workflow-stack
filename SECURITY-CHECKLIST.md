# 🛡️ SECURITY-CHECKLIST — Obligatoria en todo proyecto y feature

> Esta checklist aplica a **todo proyecto creado con este workflow** y a **cada feature** que pase por SDD.
> Cada item debe estar **resuelto o explícitamente marcado `N/A` con justificación** antes de dar una feature por terminada.
> Se evalúa en la fase de **Review** (Hermes) con evidencia real, no de palabra.
>
> **v2 (16/08):** combinada con el checklist de seguridad de JUANA IA (9 puntos para apps vibecodeadas).
> Los items 11-16 son los aportes de ese estándar. Referencia: `docs/seguridad-juanaia-prompts.md`.

---

## 🔥 Los 16 items

### 1. Rate limiting
No alcanza con middleware: usá límites **por IP + por usuario** y protección en edge (Cloudflare WAF / Vercel).
- Aplicá SIEMPRE en los endpoints abiertos: `login`, `register`, `forgot`, `reset`.
- Opciones: Upstash Ratelimit, límite en tabla de DB, o capa WAF.
- **Verificar:** N requests rápidos a un endpoint público → responde `429`.

### 2. API keys y secretos
- Rotación periódica, scopes mínimos por clave, y secrets manager (Doppler, 1Password, AWS Secrets, env vars del panel de Vercel).
- **Nunca** en el repo: ni en código, ni en `.env`, ni en historial git.
- Runtime injection en prod (env vars de Vercel / `env_file` de docker), no en el build.

### 3. RLS / Autorización (deny by default)
- Nadie accede **sin una regla explícita**.
- Cada ruta privada: verifica sesión (JWT/cookie httpOnly) **y** propiedad del recurso (el usuario solo ve/edita lo suyo).
- En apps single-user: respetar el único registro (sin multi-usuario fuga).

### 4. `.env`
- Nunca en el bundle del cliente (build). Solo secret managers + runtime injection.
- `NEXT_PUBLIC_*` SOLO para valores públicos (nombres, URLs). Jamás `MONGODB_URI`, `JWT_SECRET`, tokens.
- `.env` gitignored; `.env.example` versionado con placeholders.

### 5. Inputs (validación + sanitización)
- Validar TODO en servidor (Zod/Joi): tipos, rangos, formato, tamaño máximo.
- Sanitizar output (anti-XSS): escapar por defecto, jamás `dangerouslySetInnerHTML` con datos de usuario.
- Proteger contra SQLi/NoSQLi: ORM/Mongoose y queries parametrizadas, nunca concatenar input.

### 6. Base de datos
- **Sin acceso público**: bind a `127.0.0.1` (docker) o IP allowlist de la plataforma (Atlas/Vercel).
- Roles separados: `read` / `readWrite` / `admin` — nunca un superusuario desde la app.
- Credenciales fuertes; jamás en código ni en el cliente.

### 7. Auth
- JWT con expiración corta + refresh tokens (o cookie httpOnly con rotación), logout server-side.
- Middleware/guard en **TODAS** las rutas privadas (que ninguna quede sin verificar).
- Protección CSRF en mutaciones (SameSite, tokens).

### 8. Errores
- Logs internos **detallados** (stack, contexto, trace id).
- Al usuario SOLO errores **genéricos** (`{ error: string }` amigable). Nunca leaks de stack, driver de DB ni internals.

### 9. Admin / debug
- Eliminar en prod, o proteger con **IP allowlist + 2FA**.
- Cero rutas `/admin`, `/debug`, `/_dev`, endpoints de purga o seed en producción (o detrás de flag + allowlist).

### 10. Logging centralizado + monitoreo
- Logging estructurado + alertas (Sentry, Datadog, o logs de función + analítica).
- Detección de anomalías: ráfagas de `5xx`, `429`, intentos de login fallidos, picos de latencia.

### 11. CORS (restricción de API) — aporte JUANA IA
- Cada endpoint sensible exige autenticación; los públicos (login/register) están limitados.
- CORS: solo permitir los dominios definidos (`Access-Control-Allow-Origin` explícito, jamás `*` con credenciales).
- **Verificar:** request desde origen no permitido → bloqueado (sin `Access-Control-Allow-Origin` en la respuesta).

### 12. Dependencias actualizadas — aporte JUANA IA
- `npm audit` (o pip-audit) en **0 vulnerabilidades** antes de cada commit/feature.
- Dependencias críticas se actualizan ya; las seguras sin romper el proyecto se actualizan en el momento.
- **Verificar:** `npm audit --audit-level=high` → 0 hallazgos.

### 13. Subida de archivos — aporte JUANA IA
- Validar el **tipo real** (magic bytes / content-type, no solo extensión) y **tamaño máximo**.
- Los archivos subidos NUNCA pueden ejecutarse como código en el servidor (fuera de carpetas públicas ejecutables, sin doble extensión, servir con headers `X-Content-Type-Options: nosniff`).
- **Verificar:** subir un `.html`/`.svg` malicioso disfrazado de `.jpg` → rechazado; archivo en carpeta pública no se ejecuta.
- `N/A` justificado si el proyecto no tiene uploads.

### 14. Webhooks de pagos — aporte JUANA IA
- Verificar la **firma/secreto del webhook** en CADA petición antes de procesar el evento.
- Ninguna acción de pago (activar acceso, marcar como pagado) depende de datos enviados desde el frontend.
- **Verificar:** evento firmado inválido → `400` y no procesa; acción de pago imposible de forjar desde el cliente.
- `N/A` justificado si el proyecto no procesa pagos.

### 15. Headers de seguridad + sanitización — aporte JUANA IA
- Headers básicos configurados: `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY/SAMEORIGIN`, `Strict-Transport-Security`.
- Ningún endpoint devuelve contenido del usuario **sin sanitizar** (riesgo XSS) — escapar por defecto.
- **Verificar:** `curl -i` a la app → headers presentes; input con `<script>` no se renderiza.

### 16. 2FA en la infraestructura — aporte JUANA IA (tarea del dueño, NO de código)
- 2FA activado en: hosting (Vercel), proveedor de DB (Supabase/Neon/Atlas), registrador de dominio (NIC Argentina/registrar) y email principal.
- Ningún prompt de IA puede blindar la app si alguien entra directo a la infraestructura.
- **Verificar:** es un pendiente del dueño del proyecto, se marca en cada Review hasta confirmarse.

---

## 🧭 Calidad pública, SEO y anti-vibecoding — 20 items

> Estos controles complementan la seguridad técnica. Evitan que una app llegue a
> producción con señales de prototipo generado sin revisión: HTML vacío, SEO roto,
> accesibilidad incompleta, errores silenciosos o bundles innecesariamente pesados.
> El punto 1 es una **excepción explícita**: una URL `*.vercel.app` está permitida
> durante la prueba de producción; deja de ser suficiente cuando la app se publica
> oficialmente y debe reemplazarse por un dominio propio.

| # | Control | Criterio de aceptación | Evidencia mínima |
|---:|---|---|---|
| 1 | URL temporal de hosting | `*.vercel.app` permitido solo para staging/prueba; dominio propio requerido para publicación final. | URL y estado documentados; dominio definido antes del lanzamiento público. |
| 2 | View Source | El HTML inicial contiene estructura, título, contenido esencial y no es un documento vacío dependiente solo de JS. | `curl`/View Source; verificar tamaño, `<title>`, landmarks y contenido. |
| 3 | Página 404 | Existe una 404 intencional, útil y coherente con la marca; no se muestra una pantalla genérica del proveedor. | Request a ruta inexistente → `404` + contenido de la app. |
| 4 | Stack coherente | El framework y build usados coinciden con la arquitectura definida; no queda un scaffold Vite/React accidental o una segunda app sin motivo. | `package.json`, configuración, rutas y build revisados. |
| 5 | Títulos de página | Cada ruta HTML importante tiene un `<title>` descriptivo y único; no se reutiliza el mismo título genérico en toda la app. | HTML de cada ruta o `metadata`/`generateMetadata` por segmento. |
| 6 | Meta description | Cada ruta indexable tiene una descripción única, concreta y útil. | `<meta name="description">` en HTML generado. |
| 7 | Open Graph | Las páginas compartibles definen al menos `og:title`, `og:description`, `og:url` y `og:image` válida. | Metadata generada + URL de la imagen responde correctamente. |
| 8 | Datos estructurados | Se agrega JSON-LD válido cuando el tipo de página lo justifica (sitio, producto, artículo, FAQ, etc.); no inventar schema para pantallas privadas. | `<script type="application/ld+json">` validable y coherente. |
| 9 | Un H1 | Cada documento tiene como máximo un `<h1>` y representa el tema principal. | Conteo del DOM/HTML por ruta. |
| 10 | H1 presente | Cada página de contenido tiene exactamente un encabezado principal; no se depende solo de texto estilizado. | Conteo del DOM/HTML por ruta, incluyendo estados vacíos y error. |
| 11 | Canonical | Cada ruta indexable define canonical absoluto y consistente; las rutas privadas/no indexables se marcan adecuadamente o se excluyen. | `<link rel="canonical">` y política de indexación revisados. |
| 12 | `llms.txt` | Existe `/llms.txt` con una descripción breve y controlada del sitio si el proyecto es público; no expone secretos ni datos privados. | `curl /llms.txt` → `200` y contenido revisado. |
| 13 | `robots.txt` | Existe una política explícita: no bloquear accidentalmente buscadores ni agentes de IA; excluir rutas privadas, APIs y artefactos internos según corresponda. | `curl /robots.txt` + revisión de `allow`/`disallow`. |
| 14 | Favicon e iconos | Favicon real y, si aplica, iconos PWA válidos en tamaños/purposes correctos. | `favicon.ico`/metadata/manifest → `200`, formato válido. |
| 15 | Sitemap | Existe `/sitemap.xml` para rutas públicas indexables; nunca listar dashboards privados ni APIs. | `curl /sitemap.xml` → XML válido y URLs verificadas. |
| 16 | Idioma del documento | `<html lang="…">` corresponde al idioma principal de la página; atributos `lang` adicionales solo cuando cambia el idioma. | HTML inicial y revisión de contenido. |
| 17 | Texto alternativo | Toda imagen informativa tiene `alt` descriptivo; las decorativas usan `alt=""`; iconos interactivos tienen nombre accesible. | DOM + revisión de componentes `img`/`Image`/SVG. |
| 18 | Source maps | Los source maps no quedan accesibles públicamente en producción; si se necesitan para observabilidad, se suben a un proveedor privado. | Requests a `*.js.map` → `404`/bloqueado; revisar artefactos públicos. |
| 19 | Consola limpia | No hay errores ni warnings introducidos por la app en navegación o flujos principales; errores esperables se manejan sin ruido. | Console del navegador limpia por ruta/flujo, con evidencia de las excepciones. |
| 20 | Bundle de JavaScript | El bundle inicial tiene un presupuesto definido; librerías pesadas se cargan bajo demanda y no se envía código innecesario a rutas que no lo usan. | Build analyzer/tamaños raw+gzip, comparación contra presupuesto y revisión de imports. |

### ✅ Verificación rápida de calidad pública

```bash
# HTML inicial, metadata, idioma y 404
curl -sS http://localhost:3000/ > /tmp/page.html
curl -sS -o /tmp/404.html -w '%{http_code}\n' http://localhost:3000/ruta-inexistente
grep -iE '<title|meta[^>]+description|og:image|rel="canonical"|<html[^>]+lang=|<h1' /tmp/page.html

# Robots, sitemap, llms y favicon
for path in /robots.txt /sitemap.xml /llms.txt /favicon.ico; do
  curl -sS -o /dev/null -w "$path %{http_code} %{content_type}\n" "http://localhost:3000$path"
done

# Source maps publicados accidentalmente
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:3000/_next/static/chunks/app.js.map

# Bundle: registrar tamaños y compararlos con el presupuesto del proyecto
du -ah .next/static/chunks 2>/dev/null | sort -h | tail -20
```

---

## 🔗 Cómo se integra al flujo SDD

| Fase | Qué exige la checklist |
|------|------------------------|
| **Constitution** | El template de AGENTS.md referencia la checklist (regla de seguridad). |
| **Specify** | §4 No-Funcionales → "Seguridad" debe **enumerar los items aplicables**; §6 valida que estén contemplados. |
| **Plan (orquestador)** | Cada fase del plan considera los items aplicables; si uno no aplica → `N/A — motivo`. |
| **Implement (ejecutor)** | Respeta la checklist: inputs validados, sin secretos hardcodeados, rutas privadas con auth, errores genéricos. |
| **Review (Hermes)** | Se verifica item por item **con evidencia** (curl 401/429, git grep de secretos, `npm audit`, revisión de rutas). |

## ✅ Verificación rápida en Review (evidencia)

```bash
# auth en rutas privadas (esperado 401 sin cookie)
curl -i http://localhost:3000/api/transactions | head -1

# rate limiting (esperado 429 tras N intentos)
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code} " -X POST http://localhost:3000/api/auth/login; done; echo

# secretos en el repo
git grep -inE 'GITHUB_TOKEN|JWT_SECRET=|MONGODB_URI=|BEGIN (RSA|OPENSSH) PRIVATE KEY' -- ':!.env.example' || echo "limpio"
git log --all --oneline -- '.env*'   # solo .env.example

# dependencias con CVEs
npm audit --audit-level=high
```