#!/bin/bash

echo "Configurando acceso inicial para ArgoCD..."
read -s -p "Ingrese la contraseña de ArgoCD: " ARGOCD_PASSWORD
echo

if ! argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD"; then
    echo "Error: Falló el acceso a ArgoCD."
    exit 1
fi

echo "Acceso inicial configurado exitosamente."