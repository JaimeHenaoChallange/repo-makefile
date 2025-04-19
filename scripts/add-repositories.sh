#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/add-repositories.sh

set -e

# Función para agregar un repositorio a ArgoCD
add_repository() {
    local REPO_URL="$1"
    local USERNAME="$2"
    local PASSWORD="$3"

    echo "🔧 Verificando si el repositorio '$REPO_URL' ya está agregado..."
    if argocd repo list | grep -q "$REPO_URL"; then
        echo "✅ El repositorio '$REPO_URL' ya está agregado."
    else
        echo "🔧 Agregando el repositorio '$REPO_URL' a ArgoCD..."
        if ! argocd repo add "$REPO_URL" --username "$USERNAME" --password "$PASSWORD"; then
            echo "❌ Error: Falló al agregar el repositorio '$REPO_URL'."
            exit 1
        fi
        echo "✅ Repositorio '$REPO_URL' agregado exitosamente."
    fi
}

# Lista de repositorios a agregar
declare -A REPOSITORIES=(
    ["https://github.com/JaimeHenaoChallange/backend.git"]="<user>"
    ["https://github.com/JaimeHenaoChallange/frontend.git"]="<user>"
)

# Solicitar contraseña para los repositorios
read -sp "Introduce la contraseña para los repositorios: " PASSWORD
echo

# Agregar cada repositorio
for REPO_URL in "${!REPOSITORIES[@]}"; do
    USERNAME="${REPOSITORIES[$REPO_URL]}"
    add_repository "$REPO_URL" "$USERNAME" "$PASSWORD"
done

echo "✅ Todos los repositorios han sido procesados."