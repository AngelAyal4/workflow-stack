# 🚀 Workflow Stack — Entorno de Desarrollo Full-Stack Compartido

Bootstrap reproducible para el entorno de desarrollo del equipo: **Ubuntu + tmux + VS Code + OpenCode + Hermes + Obsidian + direnv + Ollama + Docker**.

> Cloná → ejecutá → tenés el mismo workflow que el resto del equipo. Incluye 5 stacks de proyectos listos para usar.

> 🛡️ **`SECURITY-CHECKLIST.md`** — checklist de seguridad **obligatoria** (10 items): se aplica a todo proyecto y se verifica con evidencia en la Review de cada feature.

---

## 📋 Requisitos previos

- **Ubuntu 22.04 / 24.04** (o WSL2 con Ubuntu)
- Usuario con `sudo`
- Mínimo **8 GB RAM** (para Ollama + Docker)
- [Obsidian](https://obsidian.md/) instalado (app de escritorio)

---

## 🚀 Instalación (una sola vez)

```bash
git clone https://github.com/AngelAyal4/workflow-stack.git
cd workflow-stack
./setup.sh
```

El script instala y configura **automáticamente**:

| # | Componente | Qué hace |
|---|-----------|----------|
| 1 | Paquetes base | git, curl, fzf, ripgrep, direnv, tmux, docker |
| 2 | Node.js LTS | v20 con npm |
| 3 | Ollama | modelos locales (llama2-uncensored, llama3.1:8b) |
| 4 | Shell | aliases (`ws`, `obs`, `zj`, `zjl`, `tml`, `tma`, `da`, `dr`, `oc`, git) + hook direnv |
| 5 | tmux | multiplexor principal; `ws` lanza `ws-<stack>-<proyecto>` (config en `configs/tmux.conf`) |
| 6 | Scripts | `start-workspace.sh`, `backup-obsidian.sh`, `obsidian-context-bridge.py` |
| 6b | OpenCode Desktop | detecta la app GUI (se abre con cada proyecto) |
| 7 | Obsidian | plantillas `02-Templates` (proyecto + por stack) |
| 8 | OpenCode | config base con provider Ollama |
| 9 | Cron | backup diario del vault a las 02:00 |
| 10 | Vault | detecta si hay que clonar el vault compartido |

### Después de instalar
```bash
# 1. Cerrar y reabrir la terminal (aplica aliases + docker + direnv)

# 2. Autenticar GitHub CLI
gh auth login

# 3. Clonar el VAULT compartido (si el equipo usa uno)
git clone <URL-del-vault> ~/obsidian-vault

# 4. Configurar MCP servers de opencode (obsidian-context, github)
opencode   # y seguí el setup de MCP

# 5. En Obsidian: activá los plugins Tasks, Kanban, Dataview, Templater
```

---

## 🧰 Uso diario

### Crear un proyecto nuevo
```bash
ws mern mi-app          # crea (o abre) proyecto MERN y lanza el workspace
ws astro mi-sitio      # stack Astro (SSG estatico: portfolios/landings)
```

`ws` crea automáticamente:
- Estructura de carpetas + dependencias (`package.json` con scripts dev/test/build)
- `.envrc` con variables de proyecto (direnv)
- Notas en Obsidian: `01-Projects/<stack>/<proyecto>/` → Tareas, Criterios, Logs
- `docker-compose.yml` (DB o WordPress) y lo levanta
- `AGENTS.md` con reglas de calidad (código limpio, a11y, responsive, seguridad, anti-secretos)
- `memory/` + `MEMORY.md` — sistema de memoria del proyecto (tipo Anthropic: user/feedback/project/reference)
- Abre **VS Code + OpenCode + terminal + Hermes** en tmux, y **OpenCode Desktop** (GUI) aparte

> Los prompts de Orquestador/Ejecutor con modelos distintos están en `prompts/` (ver arriba) — se generan automáticamente con los datos del proyecto en el flujo v2.

### Comandos útiles
| Comando | Acción |
|---------|--------|
| `ws <stack> <proyecto>` | Crear/abrir workspace (lanza tmux) |
| `obs` | Abrir Obsidian |
| `zj` / `zjl <stack>` | Zellij (secundario) / con layout |
| `tml` / `tma <sesión>` | tmux list / attach |
| `da` / `dr` | direnv allow / reload |
| `oc` | OpenCode |
| `gs` `ga` `gc` `gp` `gl` | Git rápido |
| `~/scripts/backup-obsidian.sh` | Backup manual del vault |

### Stacks disponibles
| Stack | Stack técnico |
|-------|---------------|
| **php** | WordPress (tema hijo, ACF, CPT) + MySQL |
| **mern** | MongoDB + Express + React + Node |
| **pern** | PostgreSQL + Express + React + Node |
| **python** | Python 3.12 + venv + pytest |
| **astro** | Astro 7 + Tailwind 4 (SSG estático) — portfolios y landings |

---

## 🔐 Seguridad — Checklist obligatoria

> Todo proyecto y feature debe cumplir la **`SECURITY-CHECKLIST.md`** (raíz del repo, 10 items).
> Cada item va **resuelto o `N/A` con justificación**, y se verifica **con evidencia** en la Review de cada feature (flujo SDD).

1. **Rate limiting** — límites por IP + por usuario en endpoints abiertos (`login`, `register`, `forgot`, `reset`) y protección en edge (Cloudflare WAF / Vercel). Verificar: ráfaga de requests → `429`.
2. **API keys y secretos** — rotación periódica, scopes mínimos, secrets manager; jamás en el repo ni en el historial git.
3. **RLS / autorización** — deny by default: cada ruta privada exige sesión **y** propiedad del recurso (el usuario solo ve/edita lo suyo).
4. **`.env`** — nunca en el build del cliente; solo runtime injection (env vars / `env_file`); `NEXT_PUBLIC_*` únicamente para valores públicos.
5. **Inputs** — validar TODO server-side (Zod/Joi), sanitizar output (anti-XSS), proteger contra SQLi/NoSQLi (ORM + queries parametrizadas).
6. **Base de datos** — sin acceso público (bind `127.0.0.1` / IP allowlist) y roles separados `read` / `readWrite` / `admin`.
7. **Auth** — JWT con expiración corta + refresh (o cookie httpOnly con rotación), middleware en **TODAS** las rutas privadas, protección CSRF en mutaciones.
8. **Errores** — logs internos detallados; al usuario solo errores **genéricos** (sin stack, driver de DB ni internals).
9. **Admin / debug** — eliminar en prod o proteger con **IP allowlist + 2FA**.
10. **Logging + monitoreo** — logging centralizado con alertas (Sentry/Datadog) y detección de anomalías (ráfagas de `5xx`, `429`, logins fallidos).

**Integración con el flujo SDD:** Specify (§4 enumera los items aplicables) → Plan (orquestador) → Implement (ejecutor) → Review (verificación con evidencia). Los comandos de verificación están en `SECURITY-CHECKLIST.md`.

---

## 🤝 Cómo colaborar

1. **Agregar un stack nuevo:** creá el caso en `scripts/start-workspace.sh`, y la plantilla en `obsidian-templates/<stack>/`.
2. **Mejorar el setup:** PR al `setup.sh`.
3. **Compartir el vault:** mantené `~/obsidian-vault` como repo git aparte (no va en este repo).

### Estructura del repo
```
workflow-stack/
├── setup.sh               # instalador (idempotente)
├── README.md              # este archivo
├── SECURITY-CHECKLIST.md  # checklist de seguridad obligatoria (10 items, ver §Seguridad)
├── docs/
│   └── Workflow de Desarrollo.md   # documentación completa del workflow
├── configs/               # ejemplos de config (SIN secretos)
│   ├── bashrc-workflow.sh     # aliases + hooks de shell
│   ├── opencode.example.json  # config de OpenCode + MCP
│   ├── envrc.example          # variables de proyecto (direnv)
│   └── tmux.conf              # multiplexor principal
├── scripts/               # start-workspace, backup, bridge MCP
├── prompts/               # plantillas de prompts Orquestador/Ejecutor (OpenCode)
│   ├── orquestador.md     #   → agente plan (razona, descompone, NO escribe código)
│   └── ejecutor.md        #   → agente build (implementa el plan archivo por archivo)
├── spec-kit/              # Spec Driven Development — Constitution + Specify
│   ├── constitution.md    #   → reglas inmutables del proyecto (autoridad superior)
│   └── specify.md         #   → plantilla de feature spec (qué y por qué, no cómo)
└── obsidian-templates/    # plantillas del vault
```

---

## 🏗️ Spec Driven Development (SDD)

Este flujo integra **Spec Kit** (GitHub) con el workflow existente. SDD significa que escribís una **especificación ANTES** de escribir código — la spec es la fuente de verdad para el humano y la IA.

> **División de trabajo por herramienta:** **DEFINIR = Hermes** (organiza, define arquitectura/specs/prompts; **solo crea los `.md` de definición — no ejecuta código ni scaffold sin pedido explícito**) → **ORQUESTAR = `opencode plan`** (plan técnico read-only) → **EJECUTAR = `opencode build`** (implementa) → **TESTEAR = `opencode test`** (QA + seguridad, reporta con evidencia).

### El flujo SDD integrado

```
Constitution → Specify → Plan → Tasks → Implement
   (1)           (2)       (3)     (4)        (5)
```

| Fase | Qué hace | Quién | Herramienta |
|------|----------|-------|-------------|
| **1. Constitution** | Define reglas inmutables del proyecto (arquitectura, stack, estándares, seguridad, calidad UI) | Humano (aprobar) | `spec-kit/constitution.md` |
| **2. Specify** | Describe el feature: problema, solución, usuarios, flujos, requisitos, criterio de aceptación | Humano + IA (borrador) | `spec-kit/specify.md` |
| **3. Plan** | Convierte la spec en plan técnico por fases (READ-ONLY) | IA (modelo potente) | `prompts/orquestador.md` |
| **4. Tasks** | Divide en tareas implementables y testables | IA | `prompts/ejecutor.md` |
| **5. Implement** | Ejecuta tarea por tarea con validación | IA (modelo eficiente) | `prompts/ejecutor.md` |

### Cómo se usa

```bash
# 1. Crear proyecto (incluye Constitution + Specify templates)
ws mern taskboard

# 2. Constitution: definir reglas inmutables (una sola vez)
#    Editar spec-kit/constitution.md con el stack y principios

# 3. Specify: para cada feature nueva
#    Crear spec desde template: cp spec-kit/specify.md specs/<feature>.md
#    Completar: problema, usuarios, flujos, requisitos

# 4. Plan: pasar la spec al orquestador (OpenCode con modelo potente)
#    → genera el plan técnico por fases

# 5. Implement: pasar el plan al ejecutor (OpenCode con modelo eficiente)
#    → ejecuta tarea por tarea

# 6. Review: verificar que la implementación cumple la spec
```

### Dónde van los artefactos

```
<proyecto>/
├── constitution.md          # copia de spec-kit/constitution.md (customizada)
├── specs/
│   ├── feature-auth.md      # spec del feature de auth
│   └── feature-tasks.md     # spec del feature de tareas
├── memory/                  # memoria del proyecto (tipo Anthropic)
└── ...
```

### Integración con herramientas existentes

- **OpenCode**: orquestador (plan) + ejecutor (implement) con LLMs distintos
- **Hermes**: **DEFINE** (organiza; crea los `.md` de specs/prompts) — no ejecuta código sin pedido explícito; en revisiones aplica `app-quality-gates` con evidencia
- **Obsidian**: specs y plans como notas vinculadas al proyecto
- **Git**: cada feature = una spec + un branch corto

---

## ❓ Troubleshooting

| Problema | Solución |
|----------|----------|
| `docker: permission denied` | Cerrá y reabrí la terminal (grupo docker) |
| OpenCode no ve Ollama | `ollama serve` en segundo plano + `curl localhost:11434/api/tags` |
| Hermes rechaza modelo local por contexto <64K | Usá `llama3.1:8b` (128K nativo) en `.envrc` y config |
| Alias no funcionan | `source ~/.bashrc` o reabrir terminal |
| `ws` no crea el proyecto | Asegurate de pasar `s` cuando pregunta "crear? (s/n)" |

---

## 🧠 Regla del equipo

> Cuando un miembro pide crear un proyecto por chat (Hermes/Telegram), **primero se hacen preguntas** (tipo, propósito, requerimientos) y **recién después** se crea. Nunca crear sin aclarar.
