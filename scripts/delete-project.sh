#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/delete-project.sh

set -e

# Eliminar un proyecto existente en ArgoCD
delete_project() {
    echo "🗑️ Eliminando un proyecto existente en ArgoCD..."

    # Listar proyectos disponibles y permitir selección por número
    echo "ℹ️  Proyectos disponibles en ArgoCD:"
    PROJECTS=$(argocd proj list --output name 2>/dev/null)
    if [[ -z "$PROJECTS" ]]; then
        echo "❌ Error: No se encontraron proyectos en ArgoCD o el comando falló."
        exit 1
    fi

    # Mostrar proyectos con índices
    PROJECT_ARRAY=()
    while IFS= read -r line; do
        PROJECT_ARRAY+=("$line")
    done <<< "$PROJECTS"

    for i in "${!PROJECT_ARRAY[@]}"; do
        echo "$((i + 1))) ${PROJECT_ARRAY[$i]}"
    done

    # Solicitar selección del proyecto
    read -p "Selecciona el número del proyecto a eliminar: " PROJECT_INDEX
    if ! [[ "$PROJECT_INDEX" =~ ^[0-9]+$ ]] || ((PROJECT_INDEX < 1 || PROJECT_INDEX > ${#PROJECT_ARRAY[@]})); then
        echo "❌ Error: Selección inválida."
        exit 1
    fi

    PROJECT_NAME="${PROJECT_ARRAY[$((PROJECT_INDEX - 1))]}"
    echo "🗑️ Proyecto seleccionado: $PROJECT_NAME"

    # Confirmar eliminación
    read -p "¿Estás seguro de que deseas eliminar el proyecto '$PROJECT_NAME'? (sí/si/no): " CONFIRMATION
    if [[ "$CONFIRMATION" != "sí" && "$CONFIRMATION" != "si" ]]; then
        echo "❌ Operación cancelada."
        exit 1
    fi

    # Eliminar el proyecto
    if ! argocd proj delete "$PROJECT_NAME"; then
        echo "❌ Error: Falló al eliminar el proyecto '$PROJECT_NAME'."
        exit 1
    fi

    echo "✅ Proyecto '$PROJECT_NAME' eliminado exitosamente."
}

# Ejecutar la función de eliminación
delete_project