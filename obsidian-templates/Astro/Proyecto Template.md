---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: astro
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **Frontend:** Astro 5
- **Islas:** React
- **CSS:** Tailwind
- **CMS:** WordPress Headless (REST / WPGraphQL)
- **DB:** MySQL 8
- **Deploy:** Vercel

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
# Contexto del Proyecto: <% tp.file_name %>

## Stack
- Tipo: Astro Headless CMS
- Frontend: Astro 5
- Backend/CMS: WordPress (REST API / WPGraphQL)
- DB: MySQL 8
- Deploy: Vercel

## Reglas de Codificacion
1. CMS headless: WordPress solo gestiona contenido via API, no renderiza
2. Consultar contenido con WPGraphQL o REST en .astro/server
3. Usar estatico (SSG) con pages/ para contenido que no cambia
4. Componentes interactivos como islands de React (client:load)
5. No tocar la DB de WordPress directamente; usar la API

## Comandos
- `npm run dev` — Astro dev server (localhost:4321)
- `npm run build` — Build estatico/SSR
- `npm run preview`
- `npm run check`
- `docker compose up -d` — WordPress en localhost:8080

## No editar
- /dist/
- /node_modules/
- /src/content/frontmatter autogenerato

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