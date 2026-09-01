# Plan Maestro — [Proyecto]

## Criterios de Éxito Globales (OBLIGATORIO)
- [ ] [Criterio 1: ej. App desplegada en producción]
- [ ] [Criterio 2: ej. Tests E2E pasan]
- [ ] [Criterio 3: ej. Documentación completa]

## Criterios de Éxito por Spec
Cada spec en `agentWorkspace/{area}/specs/` contiene sus propios criterios de éxito. El plan maestro referencia los specs pero los criterios detallados viven en cada spec.

## Fases

### Fase 1: Fundación (sin dependencias)
- [ ] [area]-[spec-id] — [descripción corta]

### Fase 2: [Nombre de fase] (depende de Fase 1)
- [ ] [area]-[spec-id] — [descripción corta] depends_on: [lista]

### Fase 3: [Nombre de fase] (depende de Fase 2)
- [ ] [area]-[spec-id] — [descripción corta] depends_on: [lista]

### Fase 4: [Nombre de fase] (depende de Fase 3)
- [ ] [area]-[spec-id] — [descripción corta] depends_on: [lista]

### Fase 5: [Nombre de fase] (depende de Fase 4)
- [ ] [area]-[spec-id] — [descripción corta] depends_on: [lista]

## Ejecución Paralela
Dentro de una fase, los specs sin dependencias entre sí se ejecutan en paralelo.

## Decisiones Arquitectónicas
- [Decisión 1: ej. Usar JWT en lugar de sesiones]
- [Decisión 2: ej. PostgreSQL como DB principal]
