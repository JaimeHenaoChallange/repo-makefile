#!/bin/bash

KUMA_VERSION=$1
KUMA_NAMESPACE=$2

if [ -z "$KUMA_VERSION" ]; then
  echo "Error: No se especificó la versión de Kuma."
  exit 1
fi

if [ -z "$KUMA_NAMESPACE" ]; then
  echo "Error: No se especificó el namespace de Kuma."
  exit 1
fi

# Añadir el repositorio de Helm si no está añadido
helm repo add kuma https://kumahq.github.io/charts || true
helm repo update

# Instalar o actualizar Kuma usando Helm
if helm list -n "$KUMA_NAMESPACE" | grep -q "kuma"; then
  echo "Kuma ya está instalado en el namespace $KUMA_NAMESPACE. Actualizando..."
  helm upgrade kuma kuma/kuma --namespace "$KUMA_NAMESPACE" --version "$KUMA_VERSION"
else
  echo "Instalando Kuma versión $KUMA_VERSION en el namespace $KUMA_NAMESPACE..."
  helm install kuma kuma/kuma --namespace "$KUMA_NAMESPACE" --create-namespace --version "$KUMA_VERSION"
fi

# Preguntar al usuario en qué namespace aplicar los labels
echo "¿En qué namespace deseas habilitar la inyección de sidecars? (por defecto: 'default')"
read -p "Namespace: " TARGET_NAMESPACE
TARGET_NAMESPACE=${TARGET_NAMESPACE:-default}

# Etiquetar el namespace seleccionado
echo "Habilitando la inyección de sidecars en el namespace '$TARGET_NAMESPACE'..."
kubectl label namespace "$TARGET_NAMESPACE" kuma.io/sidecar-injection=enabled --overwrite

echo "Kuma ha sido instalado y configurado correctamente."
