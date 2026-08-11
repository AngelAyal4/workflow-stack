---
name: spec-template
description: "Plantilla para especificar un feature ANTES de planificarlo. Se completa en la fase Specify de SDD."
---

# SPEC — {{FEATURE_NAME}} v{{VERSION}}

> Feature spec: qué se construye y por qué (no cómo).
> Se valida contra la CONSTITUCIÓN del proyecto antes de pasar a Plan.

## 1. Visión del Feature

**Problema:** {{PROBLEMA}}  
**Solución:** {{SOLUCION}}  
**Usuarios afectados:** {{USUARIOS}}  
**Outcome de éxito:** {{OUTCOME}}

## 2. User Journey / Flujos

### 2.1 Flujo principal
1. {{PASO_1}}
2. {{PASO_2}}
3. {{PASO_3}}

### 2.2 Flujos alternativos
- {{ALT_1}}
- {{ALT_2}}

### 2.3 Edge cases
- {{EDGE_1}}
- {{EDGE_2}}

## 3. Requisitos Funcionales

| ID | Requisito | Prioridad | Aceptación |
|----|-----------|-----------|------------|
| FR-01 | {{REQ}} | Must | {{CRITERIO}} |

## 4. Requisitos No-Funcionales

- **Rendimiento:** {{PERF}} (ej: <200ms p95)
- **Seguridad:** {{SEC}} — enumerar los items de SECURITY-CHECKLIST.md que aplican (ej: rate limiting en login, errores genéricos, secretos solo por env)
- **Accesibilidad:** {{A11Y}} (ej: WCAG AA)
- **Responsive:** {{RESPONSIVE}}

## 5. Alcance

**Incluido:** {{INCLUIDO}}  
**Excluido:** {{EXCLUIDO}}  
**Dependencias:** {{DEPENDENCIAS}}

## 6. Constitución Check

- [ ] ¿Viola algún principio de la constitución?
- [ ] ¿Los estándares de código son respetados?
- [ ] ¿Los requisitos de seguridad están contemplados? (según SECURITY-CHECKLIST.md)
- [ ] ¿Es testable?

## 7. Criterio de Aceptación (Definition of Done)

- [ ] {{DONE_1}}
- [ ] {{DONE_2}}
- [ ] {{DONE_3}}
