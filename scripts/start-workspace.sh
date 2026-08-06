#!/bin/bash
# start-workspace.sh — Inicia tu entorno de desarrollo completo

PROJECT_TYPE=$1
PROJECT_NAME=$2

if [ -z "$PROJECT_TYPE" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Uso: start-workspace.sh <php|mern|mern-nextjs|pern|python|astro> <nombre-proyecto>"
    echo ""
    echo "Proyectos existentes:"
    for stack in php-wordpress mern mern-nextjs pern python astro; do
        echo "  $stack:"
        ls ~/workspace/projects/$stack 2>/dev/null | sed "s/^/    - /"
    done
    exit 1
fi

# 0. Purgar estado Zellij viejo.
#    Bug conocido zellij 0.44.3 (#5261/#5440): servers/sockets huerfanos acumulados
#    hacen que un cliente nuevo sea expulsado ("1000 consecutive unknown messages")
#    dejando la terminal en raw mode (cascada de numeros).
#    REGLA: solo se purga si la terminal es FRESCA (fuera de zellij/tmux).
#    Si ya estas dentro de zellij, no se toca nada (evita matar la propia sesion).
cleanup_stale_zellij() {
    if [ -n "$ZELLIJ_SESSION_NAME" ] || [ -n "$STY" ]; then
        echo "  ℹ️  Detectado zellij/tmux activo: sin purga (modo seguro)"
        return
    fi
    echo "  ✓ Terminal limpia: purgando servers Zellij viejos..."
    zellij delete-all-sessions 2>/dev/null          # limpia las sesiones EXITED
    pkill -9 -x zellij 2>/dev/null                  # mata servers fantasma restantes
    rm -rf "/run/user/$(id -u)/zellij" 2>/dev/null  # borra sockets huerfanos colgados
    sleep 1
}
cleanup_stale_zellij

PROJECT_PATH="$HOME/workspace/projects/$PROJECT_TYPE/$PROJECT_NAME"
VAULT_PATH="$HOME/obsidian-vault"

# 1. Verificar que el proyecto existe
if [ ! -d "$PROJECT_PATH" ]; then
    echo "Proyecto no encontrado: $PROJECT_PATH"
    echo "Quieres crearlo? (s/n)"
    read -r respuesta
    if [ "$respuesta" = "s" ]; then
        mkdir -p "$PROJECT_PATH"
        cd "$PROJECT_PATH" || exit
        
        case $PROJECT_TYPE in
                        mern)
                mkdir -p client server/routes server/models server/controllers server/middleware server/tests
                
                # Inicializar Node.js
                npm init -y
                npm install express cors mongoose dotenv bcrypt jsonwebtoken
                npm install --save-dev jest supertest nodemon
                
                # Crear package.json con scripts
                node -e "
                const fs = require('fs');
                const pkg = JSON.parse(fs.readFileSync('package.json'));
                pkg.scripts = {
                    start: 'node server/index.js',
                    dev: 'nodemon server/index.js',
                    test: 'jest --coverage'
                };
                pkg.main = 'server/index.js';
                fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
                "
                
                # Crear .gitignore
                echo 'node_modules/' > .gitignore
                echo '.env' >> .gitignore
                echo 'coverage/' >> .gitignore
                
                echo "version: \"3.8\"" > docker-compose.yml
                echo "services:" >> docker-compose.yml
                echo "  mongo:" >> docker-compose.yml
                echo "    image: mongo:7" >> docker-compose.yml
                echo "    ports:" >> docker-compose.yml
                echo "      - \"27017:27017\"" >> docker-compose.yml
                echo "    volumes:" >> docker-compose.yml
                echo "      - mongo_data:/data/db" >> docker-compose.yml
                echo "volumes:" >> docker-compose.yml
                echo "  mongo_data:" >> docker-compose.yml
                ;;
            mern-nextjs)
                # Crear proyecto Next.js fullstack con App Router
                npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-turbopack --use-npm --yes 2>/dev/null || {
                    echo "create-next-app fallo, creando estructura manual..."
                    npm init -y
                    mkdir -p src/app src/components src/lib src/types src/hooks prisma
                }

                # Instalar dependencias del backend/API
                npm install mongoose dotenv bcryptjs jsonwebtoken zod
                npm install --save-dev @types/bcryptjs @types/jsonwebtoken

                # Instalar Tremor para dashboards/charts
                npm install @tremor/react recharts
                npm install --save-dev nodemon

                # Estructura backend (API routes + models + lib)
                mkdir -p src/app/api/auth src/app/api/transactions src/app/api/categories src/app/api/budgets src/app/api/reports
                mkdir -p src/models src/lib src/middleware src/types

                # package.json con scripts fullstack
                node -e "
                const fs = require('fs');
                const pkg = JSON.parse(fs.readFileSync('package.json'));
                pkg.scripts = {
                    dev: 'next dev',
                    build: 'next build',
                    start: 'next start',
                    lint: 'next lint',
                    test: 'jest --coverage'
                };
                fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
                "

                # .gitignore
                cat > .gitignore <<'EOF'
node_modules/
.next/
out/
build/
.env
.env.local
.env.*.local
coverage/
*.tsbuildinfo
next-env.d.ts
.DS_Store
npm-debug.log*
EOF

                # Docker Compose para MongoDB
                cat > docker-compose.yml <<'EOF'
version: "3.8"
services:
  mongo:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
volumes:
  mongo_data:
EOF

                # .env.example (sin secretos)
                cat > .env.example <<'EOF'
# MongoDB
MONGODB_URI=mongodb://localhost:27017/cashinsightapp
# JWT Secret (generar con: openssl rand -base64 32)
JWT_SECRET=your-jwt-secret-here
# NextAuth (cuando se implemente)
NEXTAUTH_SECRET=your-nextauth-secret
NEXTAUTH_URL=http://localhost:3000
EOF
                ;;
            pern)
                mkdir -p client server/{routes,models,controllers,middleware,tests}
                npm init -y
                npm install express cors mongoose dotenv bcrypt jsonwebtoken
                npm install --save-dev jest supertest nodemon
                
                # Crear package.json con scripts
                node -e "
                const fs = require('fs');
                const pkg = JSON.parse(fs.readFileSync('package.json'));
                pkg.scripts = {
                    start: 'node server/index.js',
                    dev: 'nodemon server/index.js',
                    test: 'jest --coverage'
                };
                pkg.main = 'server/index.js';
                fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
                "
                
                # Crear .gitignore
                echo 'node_modules/' > .gitignore
                echo '.env' >> .gitignore
                echo 'coverage/' >> .gitignore
                
                echo "version: \"3.8\"" > docker-compose.yml
                echo "services:" >> docker-compose.yml
                echo "  postgres:" >> docker-compose.yml
                echo "    image: postgres:16" >> docker-compose.yml
                echo "    environment:" >> docker-compose.yml
                echo "      POSTGRES_USER: user" >> docker-compose.yml
                echo "      POSTGRES_PASSWORD: pass" >> docker-compose.yml
                echo "      POSTGRES_DB: dev" >> docker-compose.yml
                echo "    ports:" >> docker-compose.yml
                echo "      - \"5432:5432\"" >> docker-compose.yml
                echo "    volumes:" >> docker-compose.yml
                echo "      - postgres_data:/var/lib/postgresql/data" >> docker-compose.yml
                echo "volumes:" >> docker-compose.yml
                echo "  postgres_data:" >> docker-compose.yml
                ;;
            php)
                mkdir -p wp-content/themes wp-content/plugins
                ;;
            python)
                mkdir -p src tests notebooks
                python3 -m venv .venv
                ;;
            astro)
                # Inicializar Astro primero (directorio vacio)
                npm create astro@latest -- --template minimal --no-install --yes . 2>/dev/null || {
                    echo "npm create astro fallo, creando package.json manual..."
                    npm init -y
                }
                
                # Carpetas extra que el template minimal no genera
                mkdir -p src/content src/lib
                
                npm install astro @astrojs/react @astrojs/tailwind @astrojs/vercel
                npm install --save-dev @astrojs/check typescript
                
                # Crear package.json con scripts
                node -e "
                const fs = require('fs');
                const pkg = JSON.parse(fs.readFileSync('package.json'));
                pkg.scripts = {
                    dev: 'astro dev',
                    build: 'astro build',
                    preview: 'astro preview',
                    check: 'astro check'
                };
                pkg.main = 'src/index.js';
                fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
                "
                
                # Config de WordPress headless (REST API + WPGraphQL)
                cat > astro.config.mjs <<'EOF'
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [react(), tailwind()],
  output: 'server',
  adapter: (await import('@astrojs/vercel')).default(),
});
EOF

                cat > .env.example <<'EOF'
# WordPress Headless CMS
WP_API_URL=http://localhost:8080/wp-json
WP_GRAPHQL_URL=http://localhost:8080/graphql
WP_USER=admin
WP_APP_PASSWORD=xxxx xxxx xxxx xxxx xxxx xxxx
EOF
                
                # .gitignore
                cat > .gitignore <<'EOF'
node_modules/
dist/
.astro/
.env
EOF
                
                # WordPress headless en Docker
                cat > docker-compose.yml <<'EOF'
version: "3.8"
services:
  db:
    image: mysql:8
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
      MYSQL_ROOT_PASSWORD: rootpass
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
  wordpress:
    image: wordpress:6-php8.3
    depends_on:
      - db
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html
volumes:
  db_data:
  wp_data:
EOF
                ;;
        esac
        
        cp "$VAULT_PATH/02-Templates/Proyecto Template.md" "$PROJECT_PATH/AGENTS.md"
        
                # Sistema de memoria del proyecto (tipo Anthropic): carpeta + indice
                mkdir -p "$PROJECT_PATH/memory"
                if [ ! -f "$PROJECT_PATH/memory/MEMORY.md" ]; then
                    printf '# MEMORY.md — Indice de memoria del proyecto\n\n(Un archivo por tema en memory/, cada entrada: `- [Title](file.md) — hook` <150 chars)\n' > "$PROJECT_PATH/memory/MEMORY.md"
                fi
        
                # Spec Driven Development: constitution + specs
        mkdir -p "$PROJECT_PATH/specs"
        cp ~/workflow-stack/spec-kit/constitution.md "$PROJECT_PATH/constitution.md"
        cp ~/workflow-stack/spec-kit/specify.md "$PROJECT_PATH/specs/_template.md"
        
                echo "export PROJECT_NAME=\\\"$PROJECT_NAME\\\"" > "$PROJECT_PATH/.envrc"
        echo "export PROJECT_TYPE=\"$PROJECT_TYPE\"" >> "$PROJECT_PATH/.envrc"
        echo "export OPENAI_API_KEY=\"not-needed-local\"" >> "$PROJECT_PATH/.envrc"
        echo "export OPENCODE_MODEL=\"llama2-uncensored\"" >> "$PROJECT_PATH/.envrc"
        echo "export OPENCODE_BASE_URL=\"http://localhost:11434\"" >> "$PROJECT_PATH/.envrc"
        echo "export HERMES_MODEL=\"llama2-uncensored:latest\"" >> "$PROJECT_PATH/.envrc"
        echo "export HERMES_PROVIDER=\"ollama\"" >> "$PROJECT_PATH/.envrc"
        echo "export HERMES_BASE_URL=\"http://localhost:11434\"" >> "$PROJECT_PATH/.envrc"
        
        direnv allow "$PROJECT_PATH"
        
        OBS_PROJECT="$VAULT_PATH/01-Projects/$PROJECT_TYPE/$PROJECT_NAME"
        mkdir -p "$OBS_PROJECT/Logs de Sesiones"
        
        cp "$VAULT_PATH/02-Templates/Kanban Template.md" "$OBS_PROJECT/Tareas.md"
        cp "$VAULT_PATH/02-Templates/Criterios Template.md" "$OBS_PROJECT/Criterios de Exito.md"
        
        echo "Proyecto creado en $PROJECT_PATH"
        echo "Notas creadas en $OBS_PROJECT"
    else
        exit 1
    fi
fi

# 2. Abrir Obsidian (solo si no esta ya corriendo — si esta abierto, el 2do lanzamiento queda colgado esperando lock)
if pgrep -x obsidian >/dev/null 2>&1; then
    echo "Obsidian ya esta abierto. Saltando (evita lock colgado)."
else
    obsidian "$VAULT_PATH" &
fi

# 3. Navegar al proyecto
cd "$PROJECT_PATH" || exit

# 4. Cargar direnv
direnv allow 2>/dev/null
eval "$(direnv export bash)"

# 5. Iniciar servicios si hay docker-compose
if [ -f "docker-compose.yml" ]; then
    echo "Iniciando servicios con Docker..."
    docker compose up -d
fi

# 6. Abrir OpenCode Desktop (GUI) ademas del CLI que entra en Zellij
if command -v ai.opencode.desktop >/dev/null 2>&1; then
    echo "Abriendo OpenCode Desktop (GUI)..."
    ai.opencode.desktop "$PROJECT_PATH" >/dev/null 2>&1 &
else
    echo "⚠️ OpenCode Desktop no instalado (opencode-desktop-linux-amd64.deb). Solo se abre el CLI en tmux."
fi

# 7. Previo: matar opencode CLI huerfano (evita procesos zombies)
pkill -9 -u "$USER" -f "opencode -m" 2>/dev/null
pkill -9 -u "$USER" -x opencode 2>/dev/null
sync

# 8. Iniciar workspace en tmux (mas estable que zellij: sin bug de sockets huerfanos)
echo "Iniciando workspace $PROJECT_TYPE/$PROJECT_NAME en tmux..."
SESSION="ws-$PROJECT_TYPE-$PROJECT_NAME"

# Limpiar una sesion tmux previa del mismo proyecto (si existe)
tmux has-session -t "$SESSION" 2>/dev/null && tmux kill-session -t "$SESSION"

# Segun stack: modelo de opencode y ventana de db
OPENCMD="opencode"
DB_KIND=""
case "$PROJECT_TYPE" in
    mern|mern-nextjs|astro) OPENCMD="opencode -m ollama/llama2-uncensored ." ;;
esac
case "$PROJECT_TYPE" in
    mern|mern-nextjs)  DB_KIND="mongo" ;;
    pern)  DB_KIND="postgres" ;;
    astro) DB_KIND="wp" ;;
esac

# Ventana 1: desarrollo (solo terminal de trabajo; VS Code abre como GUI aparte)
tmux new-session -d -s "$SESSION" -c "$PROJECT_PATH" -n "$PROJECT_TYPE-dev"
tmux send-keys -t "$SESSION:1.1" "code ." C-m

# Ventana 2: OpenCode CLI (pantalla completa de su propia ventana)
tmux new-window -t "$SESSION" -n "opencode"
tmux send-keys -t "$SESSION:opencode.1" "$OPENCMD" C-m

# Ventana 3: base de datos (si aplica)
if [ -n "$DB_KIND" ]; then
    tmux new-window -t "$SESSION" -n "$DB_KIND"
    if [ "$PROJECT_TYPE" = "astro" ]; then
        tmux send-keys -t "$SESSION:$DB_KIND.1" "bash" C-m
    else
        tmux send-keys -t "$SESSION:$DB_KIND.1" "docker compose up $DB_KIND" C-m
    fi
fi

# Ventana final: hermes — SOLO si no hay una sesion de Hermes ya activa (24/7)
if pgrep -f "hermes_cli.main" >/dev/null 2>&1 || pgrep -x hermes >/dev/null 2>&1; then
    echo "  ℹ️  Hermes ya esta corriendo (24/7). No abro ventana duplicada."
else
    tmux new-window -t "$SESSION" -n "hermes"
    tmux send-keys -t "$SESSION:hermes.1" "hermes" C-m
fi

# Volver a la ventana de desarrollo y attach
tmux select-window -t "$SESSION:$PROJECT_TYPE-dev"
tmux select-pane -t "$SESSION:$PROJECT_TYPE-dev.1"
# Re-ajusta la ventana al tamano real del terminal antes de plegarse
tmux resize-window -A 2>/dev/null
exec tmux attach -t "$SESSION"

echo "Sesion finalizada."
echo "Para volver a entrar: tmux attach -t $SESSION"
echo "Para listar: tmux ls"
