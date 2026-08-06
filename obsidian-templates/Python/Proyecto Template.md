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