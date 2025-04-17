#!/bin/bash

set -e  # Detener el script si ocurre un error

# Validar si Argo CD ya está instalado
echo "Verificando si Argo CD ya está instalado..."
if kubectl get namespace argocd &>/dev/null; then
    echo "Argo CD ya está instalado. Saliendo del script."
    exit 0
fi

# Crear el namespace de Argo CD
echo "Creando el namespace de Argo CD..."
kubectl create namespace argocd || true

# Instalar Argo CD
echo "Instalando Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que el servidor de Argo CD esté listo
echo "Esperando a que el servidor de Argo CD esté listo..."
kubectl rollout status deployment argocd-server -n argocd

# Instalar el CLI de Argo CD
echo "Instalando el CLI de Argo CD..."
if ! command -v argocd &>/dev/null; then
    echo "Descargando el CLI de Argo CD..."
    TEMP_FILE=$(mktemp)  # Crear un archivo temporal para la descarga
    if curl -sSL -o "$TEMP_FILE" https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64; then
        chmod +x "$TEMP_FILE"
        sudo mv "$TEMP_FILE" /usr/local/bin/argocd
        echo "CLI de Argo CD instalado exitosamente."
    else
        echo "Error: No se pudo descargar el CLI de Argo CD." >&2
        exit 1
    fi
else
    echo "El CLI de Argo CD ya está instalado."
fi

# Obtener la contraseña inicial de Argo CD
echo "Obteniendo la contraseña inicial de Argo CD..."
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

# Mostrar información de acceso
echo "Argo CD y su CLI han sido instalados exitosamente."
echo "Accede a la interfaz web en http://<Node-IP>:<NodePort>"
echo "Usuario: admin"
echo "Contraseña: $ARGOCD_PASSWORD"
echo "Para usar el CLI de Argo CD, ejecuta: argocd login <Node-IP>:<NodePort> --username admin --password <password> --insecure"

# Nota sobre el acceso
echo "Si estás usando Kind o Minikube, utiliza la IP del nodo para conectarte al servidor de Argo CD."