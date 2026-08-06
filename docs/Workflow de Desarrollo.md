---
created: 2026-08-05
tags: [workflow, stack, desarrollo, referencia]
area: desarrollo
---

# Workflow de Desarrollo — Manual de Referencia

> **Qué es:** Pipeline completo para crear y gestionar proyectos full-stack en esta máquina.
> Cada proyecto se crea desde un **stack definido** (plantilla) y se sincroniza entre el código (`~/workspace`), el segundo cerebro (Obsidian), el multiplexor (**tmux**) y las integraciones (direnv, MCP, Docker).

---

## 1. Resumen del flujo

```
Pedís "creame un proyecto X" (Hermes/Telegram)
        │
        ▼
┌─────────────────────────────┐
│ 1. HERMES HACE PREGUNTAS     │ ← flujo v2 (obligatorio ANTES de crear)
│    - ¿Qué tipo de proyecto?  │
│    - ¿Cuál es su propósito?  │
│    - (derivadas: stack exacto, DB, APIs, deploy, features) │
└─────────────────────────────┘
        │ (respuestas aprobadas)
        ▼
┌─────────────────────────────┐
│ 2. Hermes crea el proyecto   │ ← automático, basado en la plantilla del stack
│    - estructura + deps        │
│    - notas Obsidian           │
│    - .envrc (direnv)          │
│    - sesión tmux              │
│    - docker-compose (si aplica)│
└─────────────────────────────┘
        │
        ▼
┌─────────────────────────────┐
│ 3. Trabajo diario con `ws`  │ ← el alias lanza todo
└─────────────────────────────┘
```

---

## 2. Los stacks disponibles

Un **stack** = plantilla de proyecto con estructura, dependencias y config propias.

| Stack | Ventanas tmux | Carpeta proyectos | Caso en `start-workspace.sh` |
|-------|--------------|-------------------|------------------------------|
| **PHP / WordPress** | `php-dev` (vscode+opencode+term) → [`hermes`*] | `~/workspace/projects/php-wordpress/` | `php` |
| **MERN** | `mern-dev` (vscode+opencode) → `mongo` → [`hermes`*] | `~/workspace/projects/mern/` | `mern` |
| **PERN** | `pern-dev` (vscode+opencode+term) → `postgres` → [`hermes`*] | `~/workspace/projects/pern/` | `pern` |
| **Python** | `python-dev` (vscode+opencode+term) → [`hermes`*] | `~/workspace/projects/python/` | `python` |
| **Astro + WP Headless** | `astro-dev` (vscode+opencode+term) → `wp` → [`hermes`*] | `~/workspace/projects/astro/` | `astro` |

> `[hermes*]` = ventana condicional: **no se abre si ya hay una sesión de Hermes activa (24/7)**.

Cada sesión de **tmux** abre: **VS Code + OpenCode + terminal** en la misma consola → ventana de **DB/WordPress** (si aplica) → ventana de **Hermes** (solo si no está corriendo). Además, `start-workspace.sh` abre **OpenCode Desktop** (app GUI) con el proyecto cargado, junto al CLI que vive dentro de tmux. Config en `~/.config/tmux/tmux.conf` (prefijo `C-a`).

---

## 3. Comandos y aliases

Cargados en `~/.bashrc`:

```bash
# Gestión del workspace
ws    # ~/scripts/start-workspace.sh <stack> <proyecto>  → crea y abre el entorno
obs   # obsidian ~/obsidian-vault &                      → abre el vault
zj    # zellij (secundario)
zjl   # zellij --layout <stack>
tml   # tmux ls
tma   # tmux attach -t <sesión>

# direnv
da    # direnv allow
dr    # direnv reload

# Herramientas
oc    # opencode

# Git
gs    # git status
ga    # git add .
gc    # git commit -m "<mensaje>"
gp    # git push
gl    # git log --oneline -10
```

### Uso principal: `ws <stack> <proyecto>`

```bash
# Crear proyecto NUEVO y abrir el workspace
ws mern app-demo

# Si el proyecto NO existe, pregunta si crearlo (s/n).
# Si existe, lo abre directamente.
```

---

## 4. Scripts

| Script | Ruta | Función |
|--------|------|---------|
| **start-workspace** | `~/scripts/start-workspace.sh` | Orquesta todo: crea estructura, copia plantillas, .envrc, direnv, docker-compose y abre tmux |
| **backup-obsidian** | `~/scripts/backup-obsidian.sh` | Backup del vault (rsync + tar.gz), mantiene 10 |
| **obsidian-context-bridge** | `~/scripts/obsidian-context-bridge.py` | MCP server que expone el vault a OpenCode |

### Automatización
```bash
crontab -l   # muestra los cron jobs
# 0 2 * * * backup... → backup diario del vault a las 02:00
# Hermes tiene sus propios cronjobs (asistencia UNI 18:30, etc.)
```

---

## 5. Archivos y directorios clave

```
~/workspace/projects/<stack>/<proyecto>/
├── client/          # frontend (mern)
├── server/          # backend + routes/models/controllers/tests
├── src/             # astro / python
├── package.json     # deps + scripts (dev/test/build)
├── astro.config.mjs # astro
├── docker-compose.yml
├── .gitignore
├── .envrc           # direnv: variables del proyecto
└── AGENTS.md        # contexto para OpenCode/Hermes

~/obsidian-vault/
├── 00-Dashboard/    # Dashboard General, Kanban Global
├── 01-Projects/     # 01-Projects/<stack>/<proyecto>/ (Criterios, Tareas, Logs)
├── 02-Templates/    # Proyecto Template + stack (PHP/PERN/Python/Astro)
├── 03-Areas/ 04-Resources/ 05-Daily/ 06-Archive/
└── ~/.obsidian/      # plugins (dataview, kanban rows, tasks, templater, kanban-status)
```

### `.envrc` (generado automáticamente, ejemplo para MERN)
```bash
export PROJECT_NAME="app-demo"
export PROJECT_TYPE="mern"
export OPENAI_API_KEY="not-needed-local"
export OPENCODE_MODEL="llama2-uncensored"
export OPENCODE_BASE_URL="http://localhost:11434"
export HERMES_MODEL="llama2-uncensored:latest"
export HERMES_PROVIDER="ollama"
export HERMES_BASE_URL="http://localhost:11434"
```
> Nota: modelo local por defecto mientras Ollama usa `llama2-uncensored`. Si usás otro (p. ej. uno de contexto largo para Hermes), se actualiza aquí y en el layout.

---

## 6. Integraciones

- **MCP Obsidian** → el bridge `obsidian-context-bridge.py` expone el vault a OpenCode/agentes vía MCP sobre stdio. Tools: `list_projects`, `read_note`, `get_project_context`, `list_available_vaults`. Config en `~/.config/opencode/opencode.json` → servers `obsidian` y `obsidian-context`.
- **GitHub CLI** → autenticado en la cuenta personal con `GH_TOKEN` (guardado en `~/.bashrc`).
- **Docker / Docker Compose** → para contenedores de bases de datos (MongoDB, MySQL 8, PostgreSQL) y WordPress.

---

## 7. Ejemplos de uso reales

**Ejemplo 1 — Proyecto nuevo (vía Hermes con preguntas)**
```
(usuario) "creame un e-commerce"
(Hermes) ¿Qué tipo de proyecto es? (web, API, CMS...)
         ¿Cuál es su propósito?
         [derivadas según respuestas: stack, DB, APIs, deploy]

→ Hermes crea: estructura, dependencias, plantillas,
  direnv, docker, sesión tmux, notas en Obsidian.
```

**Ejemplo 2 — Crear MERN manual**
```bash
ws mern blog-gpt
# → crea /workspace/projects/mern/blog-gpt
# → inicia vscode/opencode/terminal + hermes
```

**Ejemplo 3 — Backup**
```bash
~/scripts/backup-obsidian.sh
ls ~/backups/obsidian/
```

---

> **Regla de oro:** al crear un proyecto, *siempre* Hermes pregunta primero. No crear sin clarificar tipo + propósito + requerimientos.