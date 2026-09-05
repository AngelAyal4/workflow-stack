#!/bin/bash
# model-router.sh — GGA (Gentleman Guardian AI) para OpenCode
# Selecciona el mejor modelo disponible según tarea y disponibilidad.

set -euo pipefail

# Configuración de modelos por tarea
declare -A MODELS_BRAINSTORM=(
    ["opencode"]="muse-spark-1.2"
    ["nous"]="meituan/longcat-2.0:free"
    ["local"]="ollama/qwen3.5:27b"
)

declare -A MODELS_PLAN=(
    ["opencode"]="glm-5.3-flash"
    ["nous"]="stepfun/step-3.7-flash:free"
    ["local"]="ollama/deepseek-v4-flash"
)

declare -A MODELS_BUILD=(
    ["opencode"]="deepseek-v4-flash"
    ["nous"]="poolside/laguna-xs-2.1:free"
    ["local"]="ollama/llama2-uncensored"
)

declare -A MODELS_TEST=(
    ["opencode"]="qwen3.8-flash"
    ["nous"]="ling-3.0-flash-fin:free"
    ["local"]="ollama/llama2-uncensored"
)

# Función: verificar si OpenCode Go está disponible
check_opencode_go() {
    # Verificar si opencode tiene modelos Go configurados
    if command -v opencode &>/dev/null; then
        # Intentar listar modelos de opencode
        if opencode models 2>/dev/null | grep -q "glm-5\|deepseek\|muse"; then
            return 0
        fi
    fi
    return 1
}

# Función: verificar si Nous Portal está disponible
check_nous_portal() {
    local nous_key="${NOUS_API_KEY:-}"
    if [[ -n "$nous_key" ]]; then
        # Verificar con un ping a la API
        local response
        response=$(curl -s -o /dev/null -w "%{http_code}" \
            "https://inference-api.nousresearch.com/v1/models" \
            -H "Authorization: Bearer $nous_key" 2>/dev/null || echo "000")
        if [[ "$response" == "200" ]]; then
            return 0
        fi
    fi
    return 1
}

# Función: verificar si Ollama está disponible
check_ollama() {
    if command -v ollama &>/dev/null; then
        if curl -s http://localhost:11434/api/tags &>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Función principal: obtener modelo para tarea
get_model_for_task() {
    local task="${1:-build}"
    
    # Seleccionar el array correcto
    local -n models_ref="MODELS_${task^^}"
    
    # Prioridad 1: OpenCode Go
    if check_opencode_go; then
        echo "${models_ref[opencode]}"
        return 0
    fi
    
    # Prioridad 2: Nous Portal
    if check_nous_portal; then
        echo "${models_ref[nous]}"
        return 0
    fi
    
    # Prioridad 3: Local (Ollama)
    if check_ollama; then
        echo "${models_ref[local]}"
        return 0
    fi
    
    # Fallback
    echo "No hay proveedores de IA disponibles" >&2
    return 1
}

# Función: imprimir estado de proveedores
print_status() {
    echo "=== Estado de Proveedores ==="
    
    if check_opencode_go; then
        echo "  OpenCode Go: ✅ disponible"
    else
        echo "  OpenCode Go: ❌ no disponible"
    fi
    
    if check_nous_portal; then
        echo "  Nous Portal:  ✅ disponible"
    else
        echo "  Nous Portal:  ❌ no disponible"
    fi
    
    if check_ollama; then
        echo "  Ollama:       ✅ disponible"
    else
        echo "  Ollama:       ❌ no disponible"
    fi
    
    echo ""
    echo "=== Modelos por Tarea ==="
    for task in BRAINSTORM PLAN BUILD TEST; do
        echo "  $task: $(get_model_for_task "${task,,}" 2>/dev/null || echo "N/A")"
    done
}

# CLI
case "${1:-status}" in
    brainstorm|plan|build|test)
        get_model_for_task "$1"
        ;;
    status)
        print_status
        ;;
    *)
        echo "Uso: $0 {brainstorm|plan|build|test|status}"
        exit 1
        ;;
esac
