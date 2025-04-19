#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/update-project.sh

set -e

# Actualizar un proyecto existente en ArgoCD
update_project() {
    echo "🔧 Actualizando un proyecto existente en ArgoCD..."

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
    read -p "Selecciona el número del proyecto a actualizar: " PROJECT_INDEX
    if ! [[ "$PROJECT_INDEX" =~ ^[0-9]+$ ]] || ((PROJECT_INDEX < 1 || PROJECT_INDEX > ${#PROJECT_ARRAY[@]})); then
        echo "❌ Error: Selección inválida."
        exit 1
    fi

    PROJECT_NAME="${PROJECT_ARRAY[$((PROJECT_INDEX - 1))]}"
    echo "🔧 Proyecto seleccionado: $PROJECT_NAME"

    echo "Opciones para actualizar:"
    echo "1) Añadir un nuevo destino"
    echo "2) Añadir una nueva fuente"
    echo "3) Añadir un nuevo recurso de clúster"
    read -p "Selecciona una opción (1, 2 o 3): " OPTION

    case "$OPTION" in
        1)
            read -p "Nuevo destino (puedes ingresar solo el namespace o el formato completo server,namespace): " NEW_DEST
            SERVER="https://kubernetes.default.svc"
            if [[ "$NEW_DEST" == *,* ]]; then
                # Si se proporciona el formato completo, separar servidor y namespace
                SERVER=$(echo "$NEW_DEST" | cut -d',' -f1)
                NEW_DEST=$(echo "$NEW_DEST" | cut -d',' -f2)
            fi
            if [[ -z "$NEW_DEST" ]]; then
                echo "❌ Error: El namespace no puede estar vacío."
                exit 1
            fi
            if ! argocd proj add-destination "$PROJECT_NAME" "$SERVER" "$NEW_DEST"; then
                echo "❌ Error: Falló al añadir el destino '$SERVER, $NEW_DEST' al proyecto '$PROJECT_NAME'."
                exit 1
            fi
            echo "✅ Destino '$SERVER, $NEW_DEST' añadido exitosamente al proyecto '$PROJECT_NAME'."
            ;;
        2)
            read -p "Nueva fuente (ejemplo: https://github.com/tu-repo.git): " NEW_SRC
            if [[ -z "$NEW_SRC" ]]; then
                echo "❌ Error: La fuente no puede estar vacía."
                exit 1
            fi
            if ! argocd proj add-source "$PROJECT_NAME" "$NEW_SRC"; then
                echo "❌ Error: Falló al añadir la fuente '$NEW_SRC' al proyecto '$PROJECT_NAME'."
                exit 1
            fi
            echo "✅ Fuente '$NEW_SRC' añadida exitosamente al proyecto '$PROJECT_NAME'."
            ;;
        3)
            read -p "Grupo del recurso (deja vacío para el grupo principal): " RESOURCE_GROUP
            read -p "Tipo de recurso (ejemplo: ConfigMap, Secret): " RESOURCE_KIND
            if [[ -z "$RESOURCE_KIND" ]]; then
                echo "❌ Error: El tipo de recurso no puede estar vacío."
                exit 1
            fi
            if ! argocd proj allow-cluster-resource "$PROJECT_NAME" "$RESOURCE_GROUP" "$RESOURCE_KIND"; then
                echo "❌ Error: Falló al añadir el recurso '$RESOURCE_GROUP/$RESOURCE_KIND' al proyecto '$PROJECT_NAME'."
                exit 1
            fi
            echo "✅ Recurso '$RESOURCE_GROUP/$RESOURCE_KIND' añadido exitosamente al proyecto '$PROJECT_NAME'."
            ;;
        *)
            echo "❌ Opción inválida. Abortando."
            exit 1
            ;;
    esac
}

# Ejecutar la función de actualización
update_project