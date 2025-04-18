#!/bin/bash

set -e  # Detener el script si ocurre un error

# Verificar si Kind está instalado
if ! command -v kind &> /dev/null; then
    echo "Kind no está instalado. Procediendo con la instalación..."

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
else
    echo "Kind ya está instalado."
fi

# Crear el clúster de Kind
CLUSTER_NAME=${KIND_CLUSTER_NAME:-kind}
echo "Verificando si ya existe un clúster de Kind llamado '$CLUSTER_NAME'..."
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Ya existe un clúster de Kind llamado '$CLUSTER_NAME'. No es necesario crearlo nuevamente."
    exit 0
fi

echo "Creando el clúster de Kind llamado '$CLUSTER_NAME'..."
if kind create cluster --name "$CLUSTER_NAME"; then
    echo "Clúster de Kind '$CLUSTER_NAME' creado exitosamente."
else
    echo "Error: No se pudo crear el clúster de Kind." >&2
    exit 1
fi

# Configurar el contexto de kubectl
echo "Configurando kubectl para usar el contexto del clúster '$CLUSTER_NAME'..."
if kubectl config use-context "kind-$CLUSTER_NAME"; then
    echo "kubectl configurado correctamente para el clúster '$CLUSTER_NAME'."
else
    echo "Error: No se pudo configurar el contexto de kubectl." >&2
    exit 1
fi