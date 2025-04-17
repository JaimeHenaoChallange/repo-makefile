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
    @echo "Introduce el nombre del clúster de Kind (deja vacío para usar el nombre por defecto: $(KIND_CLUSTER_NAME)):"
    @read cluster_name; \
    if [ -z "$$cluster_name" ]; then \
        cluster_name=$(KIND_CLUSTER_NAME); \
    fi; \
    echo "Creando clúster de Kind llamado $$cluster_name..."; \
    KIND_CLUSTER_NAME=$$cluster_name bash scripts/install-kind-cluster.sh

# Eliminar clúster de Kind
delete-kind-cluster:
    @echo "Eliminando clúster de Kind llamado $(KIND_CLUSTER_NAME)..."
    if ! kind delete cluster --name $(KIND_CLUSTER_NAME); then \
        echo "Error: Falló la eliminación del clúster de Kind."; \
        exit 1; \
    fi

# Configurar Ingress en Kind
setup-ingress:
    @echo "Configurando Ingress en Kind..."
    if ! kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml; then \
        echo "Error: Falló la configuración de Ingress."; \
        exit 1; \
    fi
    @echo "Esperando a que los pods de Ingress estén listos..."
    if ! kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s; then \
        echo "Error: Los pods de Ingress no están listos."; \
        exit 1; \
    fi

# Instalar ArgoCD
install-argocd:
    @echo "Instalando ArgoCD usando el script..."
    if ! bash scripts/install-argocd.sh; then \
        echo "Error: Falló la instalación de ArgoCD."; \
        exit 1; \
    fi

# Crear un namespace en Kubernetes
create-ns:
    @echo "Introduce el nombre del namespace que deseas crear:"
    @read ns_name; \
    if ! kubectl create namespace $$ns_name; then \
        echo "Error: Falló la creación del namespace $$ns_name."; \
        exit 1; \
    fi

# Instalar Kuma
install-kuma:
    @echo "Instalando Kuma versión $(KUMA_VERSION)..."
    if ! helm repo add kuma $(HELM_REPO); then \
        echo "Error: Falló al agregar el repositorio de Helm."; \
        exit 1; \
    fi
    if ! helm repo update; then \
        echo "Error: Falló al actualizar el repositorio de Helm."; \
        exit 1; \
    fi
    if ! KUMA_VERSION=$(KUMA_VERSION) bash scripts/install-kuma.sh; then \
        echo "Error: Falló la instalación de Kuma."; \
        exit 1; \
    fi

# Desinstalar Kuma
uninstall-kuma:
    @echo "Desinstalando Kuma..."
    if ! helm uninstall kuma -n kuma-system; then \
        echo "Error: Falló la desinstalación de Kuma."; \
        exit 1; \
    fi
    if ! kubectl delete namespace kuma-system; then \
        echo "Error: Falló la eliminación del namespace kuma-system."; \
        exit 1; \
    fi

# Construir imágenes Docker
build-backend:
    @echo "Construyendo imagen para backend..."
    if ! docker build -t $(BACKEND_IMAGE):$(IMAGE_TAG) ./backend/Docker/backend; then \
        echo "Error: Falló la construcción de la imagen para backend."; \
        exit 1; \
    fi

build-backend-1:
    @echo "Construyendo imagen para backend-1..."
    if ! docker build -t $(BACKEND_IMAGE_1):$(IMAGE_TAG) ./backend-1/Docker; then \
        echo "Error: Falló la construcción de la imagen para backend-1."; \
        exit 1; \
    fi

build-frontend:
    @echo "Construyendo imagen para frontend..."
    if ! docker build -t $(FRONTEND_IMAGE):$(IMAGE_TAG) ./frontend/Docker; then \
        echo "Error: Falló la construcción de la imagen para frontend."; \
        exit 1; \
    fi

build-database:
	@echo "Construyendo imagen para database..."
	docker build -t $(DATABASE_IMAGE):$(IMAGE_TAG) ./backend/Docker/database

build-redis:
	@echo "Construyendo imagen para redis..."
	docker build -t $(REDIS_IMAGE):$(IMAGE_TAG) ./backend/Docker/redis

# Publicar imágenes Docker
push-backend:
	@echo "Publicando imagen para backend..."
    if ! docker push $(BACKEND_IMAGE):$(IMAGE_TAG); then \
        echo "Error: Falló la publicación de la imagen para backend."; \
        exit 1; \
    fi

push-backend-1:
	@echo "Publicando imagen para backend-1..."
    if ! docker push $(BACKEND_IMAGE_1):$(IMAGE_TAG); then \
        echo "Error: Falló la publicación de la imagen para backend-1."; \
        exit 1; \
    fi

push-frontend:
	@echo "Publicando imagen para frontend..."
    if ! docker push $(FRONTEND_IMAGE):$(IMAGE_TAG); then \
        echo "Error: Falló la publicación de la imagen para frontend."; \
        exit 1; \
    fi

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
    if ! kubectl get namespace backend >/dev/null 2>&1; then \
        echo "El namespace 'backend' no existe. Creándolo..."; \
        if ! kubectl create namespace backend; then \
            echo "Error: Falló la creación del namespace 'backend'."; \
            exit 1; \
        fi; \
    fi
    @echo "Creando la aplicación backend en ArgoCD..."
    if ! argocd app create backend \
        --repo https://github.com/JaimeHenaoChallange/backend.git \
        --revision main \
        --path ./helm-charts/backend \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace backend \
        --sync-policy automated \
        --project poc; then \
        echo "Error: Falló la creación de la aplicación backend en ArgoCD."; \
        exit 1; \
    fi
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
    if ! helm upgrade --install frontend ./frontend/helm-charts/frontend -n $(K8S_NAMESPACE); then \
        echo "Error: Falló el despliegue del Helm chart para frontend."; \
        exit 1; \
    fi

deploy-database:
    @echo "Desplegando Helm chart para database..."
    if ! helm upgrade --install database ./backend/helm-charts/database -n $(K8S_NAMESPACE); then \
        echo "Error: Falló el despliegue del Helm chart para database."; \
        exit 1; \
    fi

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
    if ! helm uninstall backend -n $(K8S_NAMESPACE); then \
        echo "Error: Falló la eliminación del despliegue de backend."; \
        exit 1; \
    fi

delete-frontend:
    @echo "Eliminando despliegue de frontend..."
    if ! helm uninstall frontend -n $(K8S_NAMESPACE); then \
        echo "Error: Falló la eliminación del despliegue de frontend."; \
        exit 1; \
    fi

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