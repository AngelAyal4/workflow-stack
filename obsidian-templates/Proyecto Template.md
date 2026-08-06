---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: <% tp.system.suggester("Stack", ["mern", "pern", "php-wordpress", "python"]) %>
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **Tipo:** `INPUT[stack]`
- **Lenguajes:** 
- **Frameworks:**

## Estado del Proyecto
`INPUT[status]`

## Criterios de Exito
- [ ] Criterio 1
- [ ] Criterio 2
- [ ] Criterio 3

## Links
- [Tareas](Tareas.md)
- [Criterios de Exito](Criterios%20de%20Exito.md)
- [Tests](Tests%20de%20Verificacion.md)

## AGENTS.md
```markdown
# Contexto del Proyecto: <% tp.file.title %>

## Stack
- Tipo: {{stack}}
- Lenguajes: 
- Frameworks:

## Reglas de Codificacion
1. Simplicidad primero
2. Cambios quirurgicos
3. Tests antes que codigo nuevo
4. Codigo limpio: nombres auto-explicativos, funciones <30 lineas, sin codigo muerto
5. Accesible: HTML semantico, labels en formularios, alt en imagenes, focus visible
6. Responsive: mobile-first, unidades rem/%, probar en 320/768/1280px, sin overflow
7. Seguridad: validar TODO input server-side, parametrizar SQL, escapar output (anti-XSS)
8. JAMAS hardcodear secretos: tokens/keys/passwords solo via variables de entorno (.env gitignored)
9. .env.example versionado con placeholders; .env y .env.local gitignored
10. Sin headers inseguros (CSP, X-Frame-Options) ni dependencias con CVEs (npm audit)

## Comandos
- `npm run dev`
- `npm test`

## No editar
- /dist/**
- /coverage/**
- .env, .env.* (secretos reales)

## Memoria del Proyecto (sistema tipo Anthropic)

Al aprender algo del usuario, del proyecto o del trabajo, guardarlo en `memory/` del proyecto, un archivo por tema (kebab-case), con frontmatter:

```markdown
---
name: <slug-kebab-case>
description: <una linea — usada para decidir relevancia, se especifica>
metadata:
  type: user | feedback | project | reference
---

<contenido: para feedback/project: regla/hecho, luego **Why:** (por que — incidente o preferencia) y **How to apply:** (cuando/cuando aplica)>
```

Tipos:
- `user` — rol, objetivos, conocimiento, preferencias del usuario en este proyecto
- `feedback` — correcciones ("no, no asi") Y confirmaciones ("sí, perfecto"); guardar de ambos. Con **Why:** y **How to apply:**
- `project` — decisiones, metas, bugs, incidentes (estado: "quien hace que, por que, para cuando"). Convertir fechas relativas a absolutas ("jueves" → 2026-08-06)
- `reference` — punteros a recursos externos (repos, API docs, tableros, canales)

NO guardar en memoria: patrones de codigo/estructura (se derivan del codigo), git history (autoritativo), recetas de debugging (el fix esta en el codigo + commit), estado efimero de la tarea actual.

Reglas:
- MEMORY.md es un INDICE (lineas < 150 chars: `- [Title](file.md) — hook`), nunca contenido directo
- Confirmar el contenido del indice < 200 lineas
- Actualizar/eliminar memorias viejas o erradas; sin duplicados (actualizar el existente primero)
- "La memoria dice que X existe" ≠ "X existe ahora" — si la memoria nombra archivos/funciones, verificar con el codigo actual antes de recomendar
- Fechas del usuario → absolutas. Secuencia → orden de prioridad.
- Datos sensibles (SSN, cuentas, salud, direccion personal, secretos/tokens) NO se guardan salvo pedido explicito
```

## Notas
