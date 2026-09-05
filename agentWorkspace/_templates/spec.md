---
id: [area]-[feature-name]
area: [backend|frontend|qa|devops|docs|design-uiux|security]
depends_on: [[area]-[feature-name], ...]
estimated_time: [Xm|Xh]
version: 0.1.0
---

# [Título de la funcionalidad]

## Objetivo
[Una frase clara de qué se logra con este spec]

## Stack & Convenciones
- [Tecnología/lenguaje]
- [Framework/librería]
- [Patrón/convención específica]

## Funcionalidad

### [Componente/Endpoint/Módulo 1]
- Input: [descripción]
- Output: [descripción]
- Errores: [códigos y condiciones]

### [Componente/Endpoint/Módulo 2]
- Input: [descripción]
- Output: [descripción]
- Errores: [códigos y condiciones]

## Criterios de Éxito (OBLIGATORIO)
- [ ] [Criterio verificable 1]
- [ ] [Criterio verificable 2]
- [ ] [Criterio verificable 3]
- [ ] Tests pasan (cobertura >80%)
- [ ] No hay secrets hardcodeados

## Escenarios (OpenSpec — Given/When/Then)

### Escenario 1: [Nombre del escenario - caso feliz]
- **Given** [contexto inicial completo]
- **When** [acción o evento específico]
- **Then** [resultado esperado medible]

### Escenario 2: [Nombre del escenario - caso de error]
- **Given** [contexto inicial]
- **When** [acción que produce error]
- **Then** [resultado esperado: error específico]

### Escenario 3: [Nombre del escenario - edge case]
- **Given** [contexto límite]
- **When** [acción en el límite]
- **Then** [comportamiento esperado]

## Reglas (RFC 2119)

### MUST (Obligatorio)
- MUST: [regla obligatoria sin excepciones]
- MUST NOT: [prohibición absoluta]

### SHOULD (Recomendado)
- SHOULD: [regla recomendada con justificación]
- SHOULD NOT: [práctica desaconsejada]

### MAY (Opcional)
- MAY: [regla opcional cuando aplica]

## Tareas (mapeo a plan maestro)

| Tarea | Fase | Dependencias |
|-------|------|--------------|
| [Tarea 1] | [Fase] | [specs] |
| [Tarea 2] | [Fase] | [specs] |

## Contexto Adicional
- [Referencias a código existente, modelos, dependencias]
- [Notas para el ejecutor]
- [Links a documentación relevante]
