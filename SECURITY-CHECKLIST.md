# 🛡️ SECURITY-CHECKLIST — Obligatoria en todo proyecto y feature

> Esta checklist aplica a **todo proyecto creado con este workflow** y a **cada feature** que pase por SDD.
> Cada item debe estar **resuelto o explícitamente marcado `N/A` con justificación** antes de dar una feature por terminada.
> Se evalúa en la fase de **Review** (Hermes) con evidencia real, no de palabra.

---

## 🔥 Los 10 items

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