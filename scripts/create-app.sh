#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/create-app.sh

set -e

# Variables globales
ARGOCD_SERVER="https://kubernetes.default.svc"
REPO_BASE="https://github.com/JaimeHenaoChallange"

# Listar namespaces existentes
echo "ℹ️  Listando namespaces existentes..."
kubectl get namespaces -o custom-columns=NAME:.metadata.name --no-headers | nl -w2 -s') '

# Seleccionar namespace
read -p "Selecciona el número correspondiente al namespace o escribe uno nuevo para crearlo: " NS_OPTION
if [[ "$NS_OPTION" =~ ^[0-9]+$ ]]; then
    NAMESPACE=$(kubectl get namespaces -o custom-columns=NAME:.metadata.name --no-headers | sed -n "${NS_OPTION}p")
    if [[ -z "$NAMESPACE" ]]; then
        echo "❌ Opción inválida. Abortando."
        exit 1
    fi
else
    NAMESPACE="$NS_OPTION"
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        echo "⚠️  El namespace '$NAMESPACE' no existe. Creándolo..."
        if ! kubectl create namespace "$NAMESPACE"; then
            echo "❌ Error: Falló la creación del namespace '$NAMESPACE'."
            exit 1
        fi
        echo "✅ Namespace '$NAMESPACE' creado exitosamente."
    fi
fi

# Listar proyectos disponibles
echo "ℹ️  Listando proyectos disponibles en ArgoCD..."
PROJECTS=$(argocd proj list -o name)
if [[ -z "$PROJECTS" ]]; then
    echo "❌ No hay proyectos disponibles en ArgoCD. Por favor, crea uno antes de continuar."
    CREATE_PROJECT="yes"
else
    echo "$PROJECTS" | nl -w2 -s') '
    echo "$(( $(echo "$PROJECTS" | wc -l) + 1 ))) Crear un nuevo proyecto"
    read -p "Selecciona el número correspondiente al proyecto: " PROJECT_OPTION
    if [[ "$PROJECT_OPTION" =~ ^[0-9]+$ ]]; then
        if [[ "$PROJECT_OPTION" -eq $(( $(echo "$PROJECTS" | wc -l) + 1 )) ]]; then
            CREATE_PROJECT="yes"
        else
            PROJECT_NAME=$(echo "$PROJECTS" | sed -n "${PROJECT_OPTION}p")
            if [[ -z "$PROJECT_NAME" ]]; then
                echo "❌ Opción inválida. Abortando."
                exit 1
            fi
        fi
    else
        echo "❌ Opción inválida. Abortando."
        exit 1
    fi
fi

# Crear un nuevo proyecto si es necesario
if [[ "$CREATE_PROJECT" == "yes" ]]; then
    read -p "Introduce el nombre del nuevo proyecto: " PROJECT_NAME
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "❌ El nombre del proyecto no puede estar vacío. Abortando."
        exit 1
    fi
    echo "🔧 Creando el proyecto '$PROJECT_NAME' en ArgoCD..."
    if ! argocd proj create "$PROJECT_NAME"; then
        echo "❌ Error: Falló la creación del proyecto '$PROJECT_NAME'."
        exit 1
    fi
    echo "✅ Proyecto '$PROJECT_NAME' creado exitosamente."
fi

# Seleccionar o añadir repositorio
read -p "¿Deseas seleccionar un repositorio de destino? (sí/no): " SELECT_REPO
if [[ "$SELECT_REPO" =~ ^(sí|si|yes)$ ]]; then
    echo "ℹ️  Listando repositorios disponibles en ArgoCD..."
    REPOS=$(argocd repo list -o json | jq -r '.[].repo')
    if [[ -z "$REPOS" ]]; then
        echo "❌ No hay repositorios disponibles en ArgoCD."
        ADD_REPO="yes"
    else
        echo "$REPOS" | nl -w2 -s') '
        echo "$(( $(echo "$REPOS" | wc -l) + 1 ))) Añadir un nuevo repositorio"
        read -p "Selecciona el número correspondiente al repositorio: " REPO_OPTION
        if [[ "$REPO_OPTION" =~ ^[0-9]+$ ]]; then
            if [[ "$REPO_OPTION" -eq $(( $(echo "$REPOS" | wc -l) + 1 )) ]]; then
                ADD_REPO="yes"
            else
                REPO_BASE=$(echo "$REPOS" | sed -n "${REPO_OPTION}p")
                if [[ -z "$REPO_BASE" ]]; then
                    echo "❌ Opción inválida. Abortando."
                    exit 1
                fi
            fi
        else
            echo "❌ Opción inválida. Abortando."
            exit 1
        fi
    fi
else
    echo "ℹ️  Usando el repositorio por defecto: $REPO_BASE"
fi

# Añadir un nuevo repositorio si es necesario
if [[ "$ADD_REPO" == "yes" ]]; then
    read -p "Introduce la URL del nuevo repositorio: " NEW_REPO_URL
    read -p "Introduce el nombre de usuario (si aplica): " REPO_USERNAME
    read -sp "Introduce la contraseña (si aplica): " REPO_PASSWORD
    echo
    echo "🔧 Añadiendo el repositorio '$NEW_REPO_URL' a ArgoCD..."
    if ! argocd repo add "$NEW_REPO_URL" --username "$REPO_USERNAME" --password "$REPO_PASSWORD"; then
        echo "❌ Error: Falló la adición del repositorio '$NEW_REPO_URL'."
        exit 1
    fi
    REPO_BASE="$NEW_REPO_URL"
    echo "✅ Repositorio '$NEW_REPO_URL' añadido exitosamente."

    # Asociar el repositorio al proyecto
    echo "🔧 Asociando el repositorio '$NEW_REPO_URL' al proyecto '$PROJECT_NAME'..."
    echo "Se añadirá el repositorio al proyecto '$PROJECT_NAME'. Presiona Enter para continuar o Ctrl+C para cancelar."
    read
    if ! argocd proj add-source "$PROJECT_NAME" "$NEW_REPO_URL"; then
        echo "❌ Error: Falló la asociación del repositorio '$NEW_REPO_URL' al proyecto '$PROJECT_NAME'."
        exit 1
    fi
    echo "✅ Repositorio '$NEW_REPO_URL' asociado exitosamente al proyecto '$PROJECT_NAME'."
fi

# Seleccionar path
echo "ℹ️  Opciones de path disponibles:"
echo "1) ./Kubernetes"
echo "2) ./helm-charts"
echo "3) ./helm-charts/backend"
echo "4) ./helm-charts/database"
echo "5) ./helm-charts/redis"
read -p "Selecciona el número correspondiente al path (1, 2, 3, 4 o 5): " PATH_OPTION
case "$PATH_OPTION" in
    1) APP_PATH="./Kubernetes" ;;
    2) APP_PATH="./helm-charts" ;;
    3) APP_PATH="./helm-charts/backend" ;;
    4) APP_PATH="./helm-charts/database" ;;
    5) APP_PATH="./helm-charts/redis" ;;
    *) echo "❌ Opción inválida. Abortando."; exit 1 ;;
esac

# Crear aplicación en ArgoCD
APP_NAME="$1"
echo "🔧 Ejecutando: argocd app create $APP_NAME --repo $REPO_BASE --revision main --path $APP_PATH --dest-server $ARGOCD_SERVER --dest-namespace $NAMESPACE --sync-policy automated --project $PROJECT_NAME"
if ! argocd app create "$APP_NAME" \
    --repo "$REPO_BASE" \
    --revision main \
    --path "$APP_PATH" \
    --dest-server "$ARGOCD_SERVER" \
    --dest-namespace "$NAMESPACE" \
    --sync-policy automated \
    --project "$PROJECT_NAME"; then
    echo "❌ Error: Falló la creación de la aplicación '$APP_NAME' en ArgoCD."
    exit 1
fi

echo "🎉 Aplicación '$APP_NAME' creada exitosamente en el proyecto '$PROJECT_NAME' con el path $APP_PATH en el namespace $NAMESPACE."