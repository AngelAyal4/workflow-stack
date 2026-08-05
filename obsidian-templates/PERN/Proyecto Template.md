---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: pern
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **PostgreSQL:** 16
- **Express:** 4.x
- **React:** 18
- **Node:** 20

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
- Tipo: PERN
- PostgreSQL: 16
- Express: 4.x
- React: 18
- Node: 20

## Reglas de Codificacion
1. Usar pg o Prisma para queries SQL
2. Validar con express-validator
3. JWT en cookies httpOnly
4. Migrations con node-pg-migrate

## Comandos
- `npm run dev`
- `npm test`
- `npm run migrate up`

## No editar
- /dist/
- /coverage/
- /migrations/*.sql (solo via CLI)
```

## Notas