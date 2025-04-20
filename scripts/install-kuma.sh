#!/bin/bash

# Validar los argumentos
if [ -z "$1" ]; then
  echo "Error: Debes proporcionar la versión de Kuma como primer argumento."
  echo "Uso: $0 <KUMA_VERSION> <KUMA_NAMESPACE>"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error: Debes proporcionar el namespace como segundo argumento."
  echo "Uso: $0 <KUMA_VERSION> <KUMA_NAMESPACE>"
  exit 1
fi

KUMA_VERSION=$1
KUMA_NAMESPACE=$2

# Añadir el repositorio de Helm si no está añadido
helm repo add kuma https://kumahq.github.io/charts || true
helm repo update

# Instalar Kuma usando Helm con la versión y namespace especificados
echo "Instalando Kuma versión $KUMA_VERSION en el namespace $KUMA_NAMESPACE..."
helm upgrade --install kuma kuma/kuma \
  --namespace "$KUMA_NAMESPACE" \
  --create-namespace \
  --version "$KUMA_VERSION"

# Etiquetar el namespace "default" para habilitar la inyección de sidecars
echo "Habilitando la inyección de sidecars en el namespace 'default'..."
kubectl label namespace default kuma.io/sidecar-injection=enabled --overwrite
