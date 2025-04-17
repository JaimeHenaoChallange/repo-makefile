#!/bin/bash
# filepath: /workspaces/kind/repo-makefile/tests/test-makefiles.sh

set -e

echo "Probando Makefiles..."
make check-dependencies
make create-kind-cluster
make setup-ingress
make install-argocd
echo "Pruebas completadas exitosamente."