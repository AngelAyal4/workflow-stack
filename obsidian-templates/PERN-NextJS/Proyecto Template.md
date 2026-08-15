---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: pern-nextjs
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **Frontend:** Next.js 15 (App Router), TypeScript strict, TailwindCSS 4
- **Backend:** Next.js API Routes (Route Handlers), Zod
- **DB:** PostgreSQL 16 (Docker local / Supabase / Neon)
- **ORM:** Prisma o `pg` (según preferencia del proyecto)
- **Auth:** JWT en cookies httpOnly (o NextAuth si aplica)
- **Deploy:** Vercel + Supabase/Neon (free tier)

## Estado del Proyecto
`INPUT[status]`

## Criterios de Exito
- [ ] Criterio 1
- [ ] Criterio 2
- [ ] Criterio 3

## Links
- [Tareas](Tareas.md)
- [Criterios de Exito](Criterios%20de%20Exito.md)

## AGENTS.md
```markdown
# Contexto del Proyecto: <% tp.file.title %>

## Stack
- Tipo: PERN + Next.js (fullstack en un solo app)
- Frontend: Next.js 15 (App Router), TypeScript strict
- Backend: Next.js API Routes / Route Handlers
- CSS: Tailwind 4
- DB: PostgreSQL 16 (Docker local: `docker compose up postgres`)
- ORM: Prisma o pg (parametrizado SIEMPRE, jamás SQL crudo concatenado)
- Validación: Zod
- Auth: JWT en cookies httpOnly

## Reglas de Codificacion
1. Server Components por defecto; "use client" solo donde hace falta interactividad
2. Validar TODO input con Zod en los Route Handlers
3. Queries a Postgres: vía Prisma/pg con parámetros ($1, $2) — jamás interpolación
4. Migrations versionadas (prisma migrate o node-pg-migrate); nunca editar SQL aplicado
5. JWT en cookies httpOnly, no en localStorage
6. .env con DATABASE_URL y secretos; .env.example versionado con placeholders
7. npm audit limpio antes de commit

## Comandos
- `npm run dev` — Next.js dev (localhost:3000)
- `npm run build` — build
- `npm run lint`
- `npm test`
- `docker compose up postgres` — levanta la DB local

## No editar
- /node_modules/
- /.next/
- /migrations/*.sql (solo via CLI)

## Reglas de Calidad (obligatorias, ver skill app-quality-gates)
1. Codigo limpio: nombres auto-explicativos, funciones <30 lineas, sin codigo muerto
2. Accesible: HTML semantico, labels en formularios, alt en imagenes, focus visible
3. Responsive: mobile-first, unidades rem/%, probar en 320/768/1280px, sin overflow
4. Seguridad: validar TODO input server-side, parametrizar SQL, escapar output (anti-XSS)
5. JAMAS hardcodear secretos: tokens/keys/passwords solo via variables de entorno (.env gitignored)
6. .env.example versionado con placeholders; .env y .env.local gitignored
7. Sin headers inseguros (CSP, X-Frame-Options) ni dependencias con CVEs (npm audit)
```

## Notas
