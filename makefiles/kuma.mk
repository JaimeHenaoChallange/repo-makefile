# Variables específicas para Kuma
KUMA_NAMESPACE ?= kuma-system
KUMA_HELM_RELEASE ?= kuma
KUMA_HELM_CHART ?= kuma/kuma

# Objetivo para añadir el repositorio de Helm de Kuma
kuma-helm-repo:
	@echo "Añadiendo el repositorio de Helm de Kuma..."
	helm repo add kuma $(HELM_REPO)
	helm repo update

# Objetivo para instalar Kuma usando Helm
install-kuma: kuma-helm-repo
	@echo "Instalando Kuma en el namespace $(KUMA_NAMESPACE)..."
	./scripts/install-kuma.sh $(KUMA_VERSION) $(KUMA_NAMESPACE)

# Objetivo para desinstalar Kuma
uninstall-kuma:
	@echo "Desinstalando Kuma del namespace $(KUMA_NAMESPACE)..."
	helm uninstall $(KUMA_HELM_RELEASE) --namespace $(KUMA_NAMESPACE)
	@echo "Eliminando el namespace $(KUMA_NAMESPACE)..."
	kubectl delete namespace $(KUMA_NAMESPACE) || true

# Verificar el estado de Kuma
status-kuma:
	@echo "Verificando el estado de Kuma en el namespace $(KUMA_NAMESPACE)..."
	kubectl get all -n $(KUMA_NAMESPACE)

# Desplegar Kuma usando ArgoCD
deploy-kuma-argocd: install-argocd
	@echo "Desplegando Kuma en ArgoCD..."
	kubectl apply -f ../kuma-repo/argocd/kuma-argocd-app.yaml
	@echo "Kuma ha sido configurado en ArgoCD."