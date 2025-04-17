# Archivo principal del Makefile

# Configuración general
KUMA_VERSION ?= 2.7.1
DOCKER_USERNAME ?= jaimehenao8126
K8S_NAMESPACE ?= poc
HELM_REPO ?= https://kumahq.github.io/charts
KIND_CLUSTER_NAME ?= kind-cluster

# Incluir módulos
include makefiles/dependencies.mk
include makefiles/kind.mk
include makefiles/argocd.mk
include makefiles/docker.mk
include makefiles/helm.mk