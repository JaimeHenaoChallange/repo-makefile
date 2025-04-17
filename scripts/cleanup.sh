#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/scripts/cleanup.sh

set -e

echo "Eliminando recursos..."
make delete-helm
make delete-kind-cluster
echo "Recursos eliminados exitosamente."