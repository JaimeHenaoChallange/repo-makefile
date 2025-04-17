# Configuración general
KUMA_VERSION ?= 2.7.1
DOCKER_USERNAME ?= jaimehenao8126
K8S_NAMESPACE ?= poc
HELM_REPO ?= https://kumahq.github.io/charts
KIND_CLUSTER_NAME ?= kind-cluster

# Imágenes Docker
BACKEND_IMAGE ?= $(DOCKER_USERNAME)/backend
BACKEND_IMAGE_1 ?= $(DOCKER_USERNAME)/backend-1
FRONTEND_IMAGE ?= $(DOCKER_USERNAME)/frontend
DATABASE_IMAGE ?= $(DOCKER_USERNAME)/database
REDIS_IMAGE ?= $(DOCKER_USERNAME)/redis
IMAGE_TAG ?= latest

# Verificar dependencias
check-dependencies:
	@echo "Verificando dependencias..."
	@command -v kubectl >/dev/null || { echo "kubectl no está instalado. Por favor instálalo."; exit 1; }
	@command -v helm >/dev/null || { echo "helm no está instalado. Por favor instálalo."; exit 1; }
	@command -v docker >/dev/null || { echo "docker no está instalado. Por favor instálalo."; exit 1; }
	@command -v kind >/dev/null || { echo "kind no está instalado. Por favor instálalo."; exit 1; }
	@echo "Todas las dependencias están instaladas."

# Crear clúster de Kind
create-kind-cluster:
	@echo "Creando clúster de Kind usando el script..."
	bash scripts/install-kind-cluster.sh

# Eliminar clúster de Kind
delete-kind-cluster:
	@echo "Eliminando clúster de Kind llamado $(KIND_CLUSTER_NAME)..."
	kind delete cluster --name $(KIND_CLUSTER_NAME)

# Configurar Ingress en Kind
setup-ingress:
	@echo "Configurando Ingress en Kind..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Esperando a que los pods de Ingress estén listos..."
	kubectl wait --namespace ingress-nginx \
	    --for=condition=ready pod \
	    --selector=app.kubernetes.io/component=controller \
	    --timeout=90s

# Instalar ArgoCD
install-argocd:
	@echo "Instalando ArgoCD usando el script..."
	bash scripts/install-argocd.sh

# Crear un namespace en Kubernetes
create-ns:
	@echo "Introduce el nombre del namespace que deseas crear:"
	@read ns_name; \
	kubectl create namespace $$ns_name || echo "El namespace $$ns_name ya existe."

# Instalar Kuma
install-kuma:
	@echo "Instalando Kuma versión $(KUMA_VERSION)..."
	helm repo add kuma $(HELM_REPO) || echo "El repositorio de Helm ya está agregado."
	helm repo update
	KUMA_VERSION=$(KUMA_VERSION) bash scripts/install-kuma.sh

# Desinstalar Kuma
uninstall-kuma:
	@echo "Desinstalando Kuma..."
	helm uninstall kuma -n kuma-system || echo "Kuma no está instalado."
	kubectl delete namespace kuma-system || echo "El namespace kuma-system no existe."

# Construir imágenes Docker
build-backend:
	@echo "Construyendo imagen para backend..."
	docker build -t $(BACKEND_IMAGE):$(IMAGE_TAG) ./backend/Docker/backend

build-backend-1:
	@echo "Construyendo imagen para backend-1..."
	docker build -t $(BACKEND_IMAGE_1):$(IMAGE_TAG) ./backend-1/Docker

build-frontend:
	@echo "Construyendo imagen para frontend..."
	docker build -t $(FRONTEND_IMAGE):$(IMAGE_TAG) ./frontend/Docker

build-database:
	@echo "Construyendo imagen para database..."
	docker build -t $(DATABASE_IMAGE):$(IMAGE_TAG) ./backend/Docker/database

build-redis:
	@echo "Construyendo imagen para redis..."
	docker build -t $(REDIS_IMAGE):$(IMAGE_TAG) ./backend/Docker/redis

# Publicar imágenes Docker
push-backend:
	@echo "Publicando imagen para backend..."
	docker push $(BACKEND_IMAGE):$(IMAGE_TAG)

push-backend-1:
	@echo "Publicando imagen para backend-1..."
	docker push $(BACKEND_IMAGE_1):$(IMAGE_TAG)

push-frontend:
	@echo "Publicando imagen para frontend..."
	docker push $(FRONTEND_IMAGE):$(IMAGE_TAG)

push-database:
	@echo "Publicando imagen para database..."
	docker push $(DATABASE_IMAGE):$(IMAGE_TAG)

push-redis:
	@echo "Publicando imagen para redis..."
	docker push $(REDIS_IMAGE):$(IMAGE_TAG)

# Construir y publicar todas las imágenes
build-all: build-backend build-frontend build-database build-redis
push-all: push-backend push-frontend push-database push-redis

# Crear aplicación backend en ArgoCD
create-backend:
	@echo "Verificando si el namespace 'backend' existe..."
	@kubectl get namespace backend >/dev/null 2>&1 || { \
	    echo "El namespace 'backend' no existe. Creándolo..."; \
	    kubectl create namespace backend; \
	}
	@echo "Creando la aplicación backend en ArgoCD..."
	argocd app create backend \
	    --repo https://github.com/JaimeHenaoChallange/backend.git \
	    --revision main \
	    --path ./helm-charts/backend \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace backend \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación backend creada exitosamente."

# Crear aplicación frontend en ArgoCD
create-frontend:
	@echo "Verificando si el namespace 'frontend' existe..."
	@kubectl get namespace frontend >/dev/null 2>&1 || { \
	    echo "El namespace 'frontend' no existe. Creándolo..."; \
	    kubectl create namespace frontend; \
	}
	@echo "Creando la aplicación frontend en ArgoCD..."
	argocd app create frontend \
	    --repo https://github.com/JaimeHenaoChallange/frontend.git \
	    --revision main \
	    --path ./helm-charts/ \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace frontend \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación frontend creada exitosamente."

# Crear aplicación backend-1 en ArgoCD
create-backend-1:
	@echo "Verificando si el namespace 'backend-1' existe..."
	@kubectl get namespace backend-1 >/dev/null 2>&1 || { \
	    echo "El namespace 'backend-1' no existe. Creándolo..."; \
	    kubectl create namespace backend-1; \
	}
	@echo "Creando la aplicación backend-1 en ArgoCD..."
	argocd app create backend-1 \
	    --repo https://github.com/JaimeHenaoChallange/backend-1.git \
	    --revision main \
	    --path ./Kubernetes \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace backend-1 \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación backend-1 creada exitosamente."

# Crear aplicación app-1 en ArgoCD
create-app-1:
	@echo "Verificando si el namespace 'poc' existe..."
	@kubectl get namespace poc >/dev/null 2>&1 || { \
	    echo "El namespace 'poc' no existe. Creándolo..."; \
	    kubectl create namespace poc; \
	}
	@echo "Creando la aplicación app-1 en ArgoCD..."
	argocd app create app-1 \
	    --repo https://github.com/JaimeHenaoChallange/app-1.git \
	    --revision main \
	    --path ./Kubernetes \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace poc \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación app-1 creada exitosamente."

# Crear aplicación app-2 en ArgoCD
create-app-2:
	@echo "Verificando si el namespace 'poc' existe..."
	@kubectl get namespace poc >/dev/null 2>&1 || { \
	    echo "El namespace 'poc' no existe. Creándolo..."; \
	    kubectl create namespace poc; \
	}
	@echo "Creando la aplicación app-2 en ArgoCD..."
	argocd app create app-2 \
	    --repo https://github.com/JaimeHenaoChallange/app-2.git \
	    --revision main \
	    --path ./Kubernetes \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace poc \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación app-2 creada exitosamente."

# Crear aplicación kubeops en ArgoCD
create-kubeops:
	@echo "Verificando si el namespace 'poc' existe..."
	@kubectl get namespace poc >/dev/null 2>&1 || { \
	    echo "El namespace 'poc' no existe. Creándolo..."; \
	    kubectl create namespace poc; \
	}
	@echo "Creando la aplicación kubeops en ArgoCD..."
	argocd app create kubeops \
	    --repo https://github.com/JaimeHenaoChallange/kubeops.git \
	    --revision main \
	    --path ./Kubernetes \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace poc \
	    --sync-policy automated \
	    --project poc
	@echo "Aplicación kubeops creada exitosamente."

# Desplegar Helm charts
deploy-frontend:
	@echo "Desplegando Helm chart para frontend..."
	helm upgrade --install frontend ./frontend/helm-charts/frontend -n $(K8S_NAMESPACE)

deploy-database:
	@echo "Desplegando Helm chart para database..."
	helm upgrade --install database ./backend/helm-charts/database -n $(K8S_NAMESPACE)

deploy-redis:
	@echo "Desplegando Helm chart para redis..."
	helm upgrade --install redis ./backend/helm-charts/redis -n $(K8S_NAMESPACE)

deploy-helm:
	@echo "Desplegando todos los Helm charts..."
	make deploy-backend
	make deploy-frontend
	make deploy-database
	make deploy-redis

# Eliminar despliegues de Helm charts
delete-backend:
	@echo "Eliminando despliegue de backend..."
	helm uninstall backend -n $(K8S_NAMESPACE) || echo "Backend no está desplegado."

delete-frontend:
	@echo "Eliminando despliegue de frontend..."
	helm uninstall frontend -n $(K8S_NAMESPACE) || echo "Frontend no está desplegado."

delete-database:
	@echo "Eliminando despliegue de database..."
	helm uninstall database -n $(K8S_NAMESPACE) || echo "Database no está desplegado."

delete-redis:
	@echo "Eliminando despliegue de redis..."
	helm uninstall redis -n $(K8S_NAMESPACE) || echo "Redis no está desplegado."

delete-helm:
	@echo "Eliminando todos los despliegues de Helm charts..."
	make delete-backend
	make delete-frontend
	make delete-database
	make delete-redis