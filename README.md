# 🚀 Workflow Stack — Entorno de Desarrollo Full-Stack Compartido

Bootstrap reproducible para el entorno de desarrollo del equipo: **Ubuntu + Zellij + VS Code + OpenCode + Hermes + Obsidian + direnv + Ollama + Docker**.

> Cloná → ejecutá → tenés el mismo workflow que el resto del equipo. Incluye 5 stacks de proyectos listos para usar.

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
| 1 | Paquetes base | git, curl, fzf, ripgrep, direnv, zellij, docker |
| 2 | Node.js LTS | v20 con npm |
| 3 | Ollama | modelos locales (llama2-uncensored, llama3.1:8b) |
| 4 | Shell | aliases (`ws`, `obs`, `zj`, `zjl`, `da`, `dr`, `oc`, git) + hook direnv |
| 5 | Zellij | layouts `php/mern/pern/python/astro.kdl` |
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
ws astro mi-blog        # stack Astro + WordPress Headless
```

`ws` crea automáticamente:
- Estructura de carpetas + dependencias (`package.json` con scripts dev/test/build)
- `.envrc` con variables de proyecto (direnv)
- Notas en Obsidian: `01-Projects/<stack>/<proyecto>/` → Tareas, Criterios, Logs
- `docker-compose.yml` (DB o WordPress) y lo levanta
- Abre **VS Code + OpenCode + terminal + Hermes** en Zellij, y **OpenCode Desktop** (GUI) aparte

### Comandos útiles
| Comando | Acción |
|---------|--------|
| `ws <stack> <proyecto>` | Crear/abrir workspace |
| `obs` | Abrir Obsidian |
| `zj` / `zjl <stack>` | Zellij / con layout |
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
| **astro** | Astro 5 + React + Tailwind + WordPress headless |

---

## 🔐 Seguridad

- **No subir tokens/keys** a este repo. El setup genera configs **sin secretos**.
- Variables sensibles van en `.env` / `.envrc` locales (gitignored).
- `opencode.json` ya existente en tu máquina **no se sobreescribe**.

---

## 🤝 Cómo colaborar

1. **Agregar un stack nuevo:** creá el caso en `scripts/start-workspace.sh`, el layout en `zellij-layouts/`, y la plantilla en `obsidian-templates/<stack>/`.
2. **Mejorar el setup:** PR al `setup.sh`.
3. **Compartir el vault:** mantené `~/obsidian-vault` como repo git aparte (no va en este repo).

### Estructura del repo
```
workflow-stack/
├── setup.sh               # instalador (idempotente)
├── README.md              # este archivo
├── docs/
│   └── Workflow de Desarrollo.md   # documentación completa del workflow
├── configs/               # ejemplos de config (SIN secretos)
│   ├── bashrc-workflow.sh     # aliases + hooks de shell
│   ├── opencode.example.json  # config de OpenCode + MCP
│   └── envrc.example          # variables de proyecto (direnv)
├── scripts/               # start-workspace, backup, bridge MCP
├── zellij-layouts/        # layouts .kdl por stack
└── obsidian-templates/    # plantillas del vault
```

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
