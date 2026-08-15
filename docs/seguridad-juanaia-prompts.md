# 🛡️ Prompts de seguridad — JUANA IA (referencia para Review)

> Fuente: "JUANA IA — Serie de Seguridad: 9 correcciones concretas para los fallos de seguridad más comunes en apps vibecodeadas" (`checklist-seguridad-juanaia.pdf`, recibido 16/08).
> Integrados a la SECURITY-CHECKLIST.md del workflow-stack como items 11-16 (y reforzando 1-10).
> Uso: en la fase de **Review**, si un proyecto falla en algún item, se puede pasar el prompt correspondiente al ejecutor (opencode build) para que lo corrija.
> Regla: **revisar siempre el diff antes de aceptar cambios** — pedir que expliquen qué cambiaron y por qué, y probar en staging.

---

## 1. Control de acceso (IDOR) — checklist item 3
> "Revisa todos los endpoints de mi API que reciben un ID (usuario, pedido, documento, etc.) por parámetro de URL o body. Verifica que cada uno compruebe que el usuario autenticado es realmente el dueño del recurso o tiene permiso para acceder a él, antes de devolver o modificar datos. Si encuentras endpoints donde solo se confía en el ID sin validar propiedad/permisos, corrígelos añadiendo esa comprobación y explícame qué cambiaste y por qué."

## 2. Restricción de API (auth, CORS, rate limiting) — checklist items 1 y 11
> "Audita mis endpoints de API y dime cuáles no tienen autenticación o autorización, cuáles aceptan peticiones desde cualquier origen (CORS abierto), y cuáles no tienen rate limiting. Corrige lo necesario para que: (1) cada endpoint sensible exija autenticación, (2) CORS solo permita los dominios que yo defina, (3) haya rate limiting en tus endpoints. CORS básico en endpoints públicos o de login."

## 3. Dependencias desactualizadas — checklist item 12
> "Analiza el package.json (o requirements.txt/composer.json/etc.) de este proyecto, identifica dependencias desactualizadas o con vulnerabilidades conocidas (usa npm audit / pip-audit / el equivalente), y dime cuáles son críticas de corregir ya. Actualiza las que sean seguras de actualizar sin romper el proyecto y avísame con cuáles requieran cambios de código."

## 4. Subida de archivos — checklist item 13
> "Revisa la lógica de subida de archivos de mi app. Añade validación de tipo real de archivo (por contenido/magic bytes, no solo por extensión), límite de tamaño máximo, y asegúrate de que los archivos subidos no se puedan ejecutar como código en el servidor. Si guardo los archivos en una carpeta pública, dime si eso es un riesgo y cómo mitigarlo."

## 5. Inyección SQL — checklist item 5
> "Revisa todas mis consultas a la base de datos y dime si alguna concatena o interpola directamente datos del usuario dentro de la query (riesgo de inyección SQL). Corrige todas esas consultas para que usen parámetros/prepared statements o el ORM correctamente, en vez de construir la query con strings."

## 6. Tokens de sesión — checklist item 7
> "Revisa cómo estoy guardando y manejando los tokens de autenticación en el frontend. Si están en localStorage o sessionStorage, migra el manejo de sesión a cookies HttpOnly, Secure y SameSite, y ajusta el backend para setearlas y validarlas correctamente. Explícame qué cambia en el flujo de login/logout."

## 7. Webhooks de pagos — checklist item 14
> "Revisa la lógica que recibe webhooks de mi proveedor de pagos (Stripe, PayPal, etc.). Verifica que se esté validando la firma/secreto del webhook en cada petición antes de procesar cualquier evento de pago, y que ninguna acción de pago (activar acceso, marcar como pagado, etc.) dependa únicamente de datos enviados desde el frontend. Corrige lo que falte."

## 8. Headers y sanitización — checklist item 15
> "Revisa mi API/servidor y dime si tengo configurados headers de seguridad básicos (Content-Security-Policy, X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security). Añade los que falten con una configuración razonable. Además, revisa si algún endpoint devuelve directamente contenido introducido por el usuario sin sanitizar (riesgo de XSS) y corrígelo."

## 9. 2FA en tu infraestructura — checklist item 16 (NO es código)
> "Esto no se arregla con un prompt — es tarea tuya, hoy. Activa 2FA en tu cuenta de hosting, tu proveedor de base de datos, tu registrador de dominio y tu cuenta de email principal. Ningún prompt de IA puede blindar tu app si alguien entra directamente a tu infraestructura por ahí."

---

## 🚨 Antes de subir a producción
- Pide siempre que te expliquen el cambio **antes** de aplicarlo.
- Pruébalo en **staging** primero.
- Revisa el diff completo; no aceptes cambios a ciegas.
