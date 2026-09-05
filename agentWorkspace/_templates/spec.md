---
id: [area]-[feature-name]
area: [backend|frontend|qa|devops|docs|design-uiux|security]
depends_on: [[area]-[feature-name], ...]
estimated_time: [Xm|Xh]
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

### Escenario 1: [Nombre del escenario]
- **Given** [contexto inicial]
- **When** [acción o evento]
- **Then** [resultado esperado]

### Escenario 2: [Nombre del escenario]
- **Given** [contexto inicial]
- **When** [acción o evento]
- **Then** [resultado esperado]

## Reglas (RFC 2119)
- MUST: [regla obligatoria]
- SHOULD: [regla recomendada]
- MAY: [regla opcional]

## Contexto Adicional
- [Referencias a código existente, modelos, dependencias]
- [Notas para el ejecutor]
