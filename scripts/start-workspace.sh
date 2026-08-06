#!/bin/bash
# start-workspace.sh — Inicia tu entorno de desarrollo completo

PROJECT_TYPE=$1
PROJECT_NAME=$2

if [ -z "$PROJECT_TYPE" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Uso: start-workspace.sh <php|mern|pern|python|astro> <nombre-proyecto>"
    echo ""
    echo "Proyectos existentes:"
    for stack in php-wordpress mern pern python astro; do
        echo "  $stack:"
        ls ~/workspace/projects/$stack 2>/dev/null | sed "s/^/    - /"
    done
    exit 1
fi

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
        
        echo "export PROJECT_NAME=\"$PROJECT_NAME\"" > "$PROJECT_PATH/.envrc"
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

# 2. Abrir Obsidian
obsidian "$VAULT_PATH" &

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
    echo "⚠️ OpenCode Desktop no instalado (opencode-desktop-linux-amd64.deb). Solo se abre el CLI en Zellij."
fi

# 7. Iniciar Zellij
echo "Iniciando workspace $PROJECT_TYPE/$PROJECT_NAME..."
zellij --layout "$PROJECT_TYPE"

echo "Sesion finalizada."
echo "Recuerda hacer commit:"
echo "  git add . && git commit -m \"feat: descripcion\" && git push"
