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

## Comandos
- `npm run dev`
- `npm test`

## No editar
- /dist/**
- /coverage/**
```

## Notas
