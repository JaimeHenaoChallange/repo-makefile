#!/bin/bash

set -e  # Detener el script si ocurre un error

# Verificar si ya existe un clúster de Kind
echo "Verificando si ya existe un clúster de Kind..."
if kind get clusters | grep -q "kind"; then
    echo "Ya existe un clúster de Kind llamado 'kind'. No es necesario instalarlo nuevamente."
    exit 0
fi

echo "Descargando Kind..."
if curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64; then
    echo "Kind descargado exitosamente."
else
    echo "Error: No se pudo descargar Kind." >&2
    exit 1
fi

echo "Haciendo el binario ejecutable..."
if chmod +x ./kind; then
    echo "Permisos de ejecución asignados correctamente."
else
    echo "Error: No se pudieron asignar permisos de ejecución al binario." >&2
    exit 1
fi

echo "Moviendo Kind al directorio /usr/local/bin..."
if sudo mv ./kind /usr/local/bin/kind; then
    echo "Kind movido exitosamente a /usr/local/bin."
else
    echo "Error: No se pudo mover Kind a /usr/local/bin." >&2
    exit 1
fi

echo "Verificando la instalación de Kind..."
if kind version; then
    echo "Kind se instaló correctamente."
else
    echo "Error: No se pudo verificar la instalación de Kind." >&2
    exit 1
fi