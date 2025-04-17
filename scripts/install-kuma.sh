#!/bin/bash

# Verifica si se proporcionó la versión de Kuma
if [ -z "$KUMA_VERSION" ]; then
  echo "Error: La variable KUMA_VERSION no está definida."
  exit 1
fi

# Instalar Kuma usando Helm con la versión especificada
helm install kuma kuma/kuma --namespace kuma-system --create-namespace --version "$KUMA_VERSION"

# Etiquetar el namespace "default" para habilitar la inyección de sidecars
kubectl label namespace default kuma.io/sidecar-injection=enabled --overwrite
