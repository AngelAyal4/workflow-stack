---
name: constitution
description: "Constitución del proyecto — reglas inmutables que gobiernan TODA la arquitectura y código. Revisada solo cuando cambian principios fundamentales, no por features."
---

# CONSTITUCIÓN — {{PROJECT_NAME}}

> Esta constitución es la fuente de autoridad superior del proyecto.
> Ningún feature, plan o tarea puede violar estas reglas.
> Se modifica SOLO cuando cambian principios fundamentales del proyecto.

## 1. Principios Inmutables

### 1.1 Arquitectura
- **Patrón:** {{PATRON}} (ej: feature-slice, hexagonal, clean architecture)
- **Módulos centrales:** {{MODULOS}}
- **Flujo de datos:** {{FLUJO}} (ej: unidireccional, CQRS)
- **Capas:** {{CAPAS}}

### 1.2 Stack (fijo por proyecto)
- Frontend: {{FRONTEND}}
- Backend: {{BACKEND}}
- Base de datos: {{DB}}
- Auth: {{AUTH}}

### 1.3 Estándares de Código (no negociables)
- Lenguaje principal: {{LANG}}
- Estilo: {{ESTILO}} (ej: Airbnb Standard, PEP8, Prettier)
- Testing: obligatorio para lógica de negocio (mínimo 70% cobertura en nuevos archivos)
- Commits: Conventional Commits (feat:, fix:, refactor:, docs:)
- Branching: trunk-based o feature branches cortos (<3 días)

### 1.4 Seguridad (de app-quality-gates)
- NUNCA hardcodear secretos
- Validar input server-side
- SQL parametrizado / ORM
- XSS: escapar output, no `dangerouslySetInnerHTML`
- Headers de seguridad (CSP, HSTS)
- Dependencias auditadas (`npm audit`)

### 1.5 Calidad de UI (de app-quality-gates)
- Mobile-first, responsive en 320/768/1280px
- HTML semántico + labels + focus visible
- Token system (paleta, tipografía, signature) antes de CSS
- Accesibilidad WCAG AA mínima

## 2. Lo que NO se hace

- No micro-optimización prematura
- No abstracciones hasta 3ra repetición
- No features sin spec aprobada
- No código sin tests asociados (si hay lógica)
- No dependencias sin justificación

## 3. Gobernanza

- Cambios a esta constitución requieren aprobación explícita
- Cada feature spec se valida contra esta constitución (checklist)
- En caso de conflicto: constitución > spec > plan > tarea
