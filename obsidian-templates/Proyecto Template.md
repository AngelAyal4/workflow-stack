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
```

## Notas
