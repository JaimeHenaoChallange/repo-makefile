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
        if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
            if ! argocd repo add "$REPO_URL" --username "$USERNAME" --password "$PASSWORD"; then
                echo "❌ Error: Falló al agregar el repositorio '$REPO_URL'."
                exit 1
            fi
        else
            if ! argocd repo add "$REPO_URL"; then
                echo "❌ Error: Falló al agregar el repositorio '$REPO_URL'."
                exit 1
            fi
        fi
        echo "✅ Repositorio '$REPO_URL' agregado exitosamente."
    fi
}

# Solicitar datos del repositorio al usuario
read -p "Introduce la URL del repositorio: " REPO_URL
if [ -z "$REPO_URL" ]; then
    echo "❌ Error: La URL del repositorio no puede estar vacía."
    exit 1
fi

read -p "Introduce el nombre de usuario (deja vacío si no aplica): " USERNAME
read -sp "Introduce la contraseña (deja vacío si no aplica): " PASSWORD
echo

# Agregar el repositorio
add_repository "$REPO_URL" "$USERNAME" "$PASSWORD"

echo "✅ Proceso completado."