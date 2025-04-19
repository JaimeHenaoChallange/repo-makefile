#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/create-project.sh

set -e

# Función para validar el formato de los namespaces
validate_namespaces() {
    local namespaces="$1"
    # Eliminar espacios adicionales
    namespaces=$(echo "$namespaces" | tr -d ' ')
    IFS=',' read -ra NS_ARRAY <<< "$namespaces"
    for ns in "${NS_ARRAY[@]}"; do
        if [[ -z "$ns" ]]; then
            echo "❌ Error: Cada namespace debe ser un valor no vacío."
            exit 1
        fi
    done
    echo "$namespaces" # Retornar los namespaces formateados
}

# Solicitar información al usuario
read -p "Nombre del proyecto (ejemplo: poc): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    echo "❌ Error: El nombre del proyecto no puede estar vacío."
    exit 1
fi

read -p "Descripción del proyecto (ejemplo: Proyecto de prueba para aplicaciones): " DESCRIPTION

read -p "Namespaces permitidos (puedes agregar múltiples namespaces separados por comas, ejemplo: default,argocd): " NAMESPACES
NAMESPACES=$(validate_namespaces "$NAMESPACES")

# Construir destinos con la URL estándar y los namespaces
DEST=""
IFS=',' read -ra NS_ARRAY <<< "$NAMESPACES"
for ns in "${NS_ARRAY[@]}"; do
    if [[ -n "$DEST" ]]; then
        DEST+=","
    fi
    DEST+="https://kubernetes.default.svc,$ns"
done

read -p "Fuente permitida (puedes agregar múltiples fuentes separadas por comas, ejemplo: https://github.com/tu-repo.git,https://otro-repo.git): " SRC
SRC=${SRC:-*}

# Construir argumentos para las fuentes permitidas
SRC_ARGS=()
IFS=',' read -ra SRC_ARRAY <<< "$SRC"
for src in "${SRC_ARRAY[@]}"; do
    SRC_ARGS+=("--src" "$src")
done

read -p "Recursos de clúster permitidos (puedes agregar múltiples recursos separados por comas, ejemplo: *,ConfigMap,Secret): " CLUSTER_RESOURCES
CLUSTER_RESOURCES=${CLUSTER_RESOURCES:-*}

# Crear el proyecto en ArgoCD
echo "🔧 Creando el proyecto '$PROJECT_NAME' en ArgoCD..."
if ! argocd proj create "$PROJECT_NAME" \
    --description "$DESCRIPTION" \
    --dest "$DEST" \
    "${SRC_ARGS[@]}" \
    --allow-cluster-resource "$CLUSTER_RESOURCES"; then
    echo "❌ Error: Falló la creación del proyecto '$PROJECT_NAME'."
    exit 1
fi

echo "✅ Proyecto '$PROJECT_NAME' creado exitosamente."