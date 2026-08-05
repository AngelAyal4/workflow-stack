---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: php-wordpress
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **Tipo:** WordPress
- **PHP:** 8.x
- **Tema:** Hijo de tema existente
- **Plugins:** ACF, Custom Post Types

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
- Tipo: WordPress
- PHP: 8.x
- Base de datos: MySQL/MariaDB

## Reglas de Codificacion
1. Usar funciones nativas de WP, no SQL directo
2. Sanitizar inputs con wp_kses, sanitize_text_field
3. Nonces en formularios para seguridad
4. Hooks en lugar de modificar core

## Comandos
- `wp plugin list`
- `wp theme list`
- `wp db export`

## No editar
- /wp-admin/
- /wp-includes/
- /wp-content/uploads/
```

## Notas