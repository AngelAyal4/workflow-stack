---
created: <% tp.date.now("YYYY-MM-DD") %>
stack: python
status: active
priority: <% tp.system.suggester("Prioridad", ["Urgente", "Alta", "Media", "Baja"]) %>
---

# <% tp.file.title %>

## Descripcion
<% tp.file.cursor(1) %>

## Stack
- **Python:** 3.12
- **Entorno:** venv
- **Testing:** pytest

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
- Tipo: Python
- Python: 3.12
- Entorno: venv

## Reglas de Codificacion
1. type hints en funciones publicas
2. docstrings con Google style
3. black para formateo
4. pytest para tests

## Comandos
- `python -m venv .venv`
- `source .venv/bin/activate`
- `pytest`
- `black .`

## No editar
- __pycache__/
- .pytest_cache/
- .venv/
```

## Notas