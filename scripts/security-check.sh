#!/bin/bash
# security-check.sh — Guardrails de seguridad para el workflow
# Verifica que no se suban secrets, credenciales o archivos sensibles al repo.

set -euo pipefail

# Archivos sensibles que NUNCA deben estar en staging
DENY_PATTERNS=(
    "\.env$"
    "\.env\.local$"
    "\.env\.production$"
    "\.env\.development$"
    "\.ssh/"
    "\.gnupg/"
    "\.aws/credentials$"
    "\.config/gcloud/"
    "id_rsa$"
    "id_ed25519$"
    "\.pem$"
    "\.p12$"
    "\.pfx$"
    "credentials\.json$"
    "service-account.*\.json$"
    ".*secret.*"
    ".*api.?key.*"
    ".*token.*"
    ".*password.*"
)

# Patrones de contenido sospechoso (API keys, tokens hardcodeados)
CONTENT_PATTERNS=(
    "sk-[a-zA-Z0-9]{20,}"
    "AKIA[0-9A-Z]{16}"
    "ghp_[a-zA-Z0-9]{36}"
    "gho_[a-zA-Z0-9]{36}"
    "xoxb-[a-zA-Z0-9]{10,}"
    "xoxp-[a-zA-Z0-9]{10,}"
    "AIza[a-zA-Z0-9_-]{35}"
    "Bearer [a-zA-Z0-9_\-\.]{20,}"
    "password\s*=\s*['\"][^'\"]+['\"]"
    "api_key\s*=\s*['\"][^'\"]+['\"]"
    "secret\s*=\s*['\"][^'\"]+['\"]"
)

ERRORS=0

# Función: verificar archivos en staging
check_staging_files() {
    echo "=== Verificando archivos en staging ==="
    
    local staged_files
    staged_files=$(git diff --cached --name-only 2>/dev/null || true)
    
    if [[ -z "$staged_files" ]]; then
        echo "  No hay archivos en staging."
        return 0
    fi
    
    for file in $staged_files; do
        for pattern in "${DENY_PATTERNS[@]}"; do
            if echo "$file" | grep -qiE "$pattern"; then
                echo "  ❌ ARCHIVO SENSIBLE EN STAGING: $file (patrón: $pattern)"
                ((ERRORS++))
            fi
        done
    done
}

# Función: verificar contenido de archivos en staging
check_staging_content() {
    echo "=== Verificando contenido en staging ==="
    
    local staged_files
    staged_files=$(git diff --cached --name-only 2>/dev/null || true)
    
    if [[ -z "$staged_files" ]]; then
        return 0
    fi
    
    for file in $staged_files; do
        # Solo verificar archivos de texto
        if file "$file" 2>/dev/null | grep -q "text"; then
            for pattern in "${CONTENT_PATTERNS[@]}"; do
                if git show ":$file" 2>/dev/null | grep -qiE "$pattern"; then
                    echo "  ❌ POSIBLE SECRET EN: $file (patrón: $pattern)"
                    ((ERRORS++))
                fi
            done
        fi
    done
}

# Función: verificar .gitignore existe y tiene las entradas mínimas
check_gitignore() {
    echo "=== Verificando .gitignore ==="
    
    if [[ ! -f ".gitignore" ]]; then
        echo "  ❌ .gitignore no existe"
        ((ERRORS++))
        return
    fi
    
    local required_patterns=("node_modules/" ".env" "coverage/" "dist/" ".astro/")
    for pattern in "${required_patterns[@]}"; do
        if ! grep -qF "$pattern" .gitignore 2>/dev/null; then
            echo "  ⚠️  .gitignore falta: $pattern"
        fi
    done
}

# Función: verificar que no hay .env en el repo
check_env_files() {
    echo "=== Verificando archivos .env ==="
    
    local env_files
    env_files=$(git ls-files | grep -E "\.env(\..+)?$" 2>/dev/null || true)
    
    if [[ -n "$env_files" ]]; then
        for file in $env_files; do
            if [[ "$file" != ".env.example" && "$file" != ".env.template" ]]; then
                echo "  ❌ ARCHIVO .ENV EN REPO: $file"
                ((ERRORS++))
            fi
        done
    fi
}

# Función: verificar permisos de archivos sensibles
check_file_permissions() {
    echo "=== Verificando permisos de archivos ==="
    
    # Verificar que los scripts ejecutables tengan permisos correctos
    find . -maxdepth 2 -name "*.sh" -perm -o+w 2>/dev/null | while read -r file; do
        echo "  ⚠️  Script con permisos de escritura para otros: $file"
    done
}

# Función principal
run_checks() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           🔒 Security Check — Workflow Stack                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_staging_files
    echo ""
    check_staging_content
    echo ""
    check_gitignore
    echo ""
    check_env_files
    echo ""
    check_file_permissions
    echo ""
    
    if [[ $ERRORS -gt 0 ]]; then
        echo "❌ $ERRORS error(es) de seguridad encontrados."
        echo "   Corregí los problemas antes de hacer commit."
        return 1
    else
        echo "✅ Todas las verificaciones de seguridad pasaron."
        return 0
    fi
}

# CLI
case "${1:-check}" in
    check)
        run_checks
        ;;
    pre-commit)
        run_checks || exit 1
        ;;
    *)
        echo "Uso: $0 {check|pre-commit}"
        exit 1
        ;;
esac
