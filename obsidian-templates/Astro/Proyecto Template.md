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
- **Frontend:** Astro 7
- **CSS:** Tailwind 4 (plugin `@tailwindcss/vite`, CSS-first)
- **Salida:** SSG estático puro (sin islands, sin server)
- **CMS/DB:** ninguno (contenido curado en el repo)
- **Deploy:** Vercel / Netlify / Cloudflare Pages (hosting $0)

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
- Tipo: Astro SSG estatico (portfolio/landing)
- Frontend: Astro 7
- CSS: Tailwind 4 (@tailwindcss/vite)
- Backend/DB: ninguno (sin server, sin WP)

## Reglas de Codificacion
1. SSG puro: contenido estatico curado en el repo, `output: 'static'`
2. Cero JavaScript si CSS alcanza (nav sin hamburguesa, hover/focus por CSS)
3. Interactividad solo si es imprescindible (island via `npx astro add react`)
4. Imagenes optimizadas con `Image` de astro:assets (alt SIEMPRE)
5. Accesible: HTML semantico, labels en forms, focus visible, contraste AA
6. Responsive: mobile-first, unidades rem/%, probar en 320/768/1280px, sin overflow
7. JAMAS hardcodear secretos; .env gitignored; .env.example con placeholders
8. Seguridad: escapar TODO output (anti-XSS), headers seguros en el host de deploy
9. `npm audit` limpio antes de commit (correr `npm audit fix` post-install: sharp)

## Comandos
- `npm run dev` — Astro dev server (localhost:4321)
- `npm run build` — Build estatico (dist/)
- `npm run preview`
- `npm run check`
- `npm audit` — dependencias (0 vulnerabilidades)

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