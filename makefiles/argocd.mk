# Instalar ArgoCD
install-argocd:
	@echo "Instalando ArgoCD usando el script..."
	if ! bash scripts/install-argocd.sh; then \
	    echo "Error: Falló la instalación de ArgoCD."; \
	    exit 1; \
	fi

# Crear aplicaciones en ArgoCD
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
	if ! kubectl get namespace frontend >/dev/null 2>&1; then \
	    echo "El namespace 'frontend' no existe. Creándolo..."; \
	    if ! kubectl create namespace frontend; then \
	        echo "Error: Falló la creación del namespace 'frontend'."; \
	        exit 1; \
	    fi; \
	fi
	@echo "Creando la aplicación frontend en ArgoCD..."
	if ! argocd app create frontend \
	    --repo https://github.com/JaimeHenaoChallange/frontend.git \
	    --revision main \
	    --path ./helm-charts/frontend \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace frontend \
	    --sync-policy automated \
	    --project poc; then \
	    echo "Error: Falló la creación de la aplicación frontend en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación frontend creada exitosamente."

# Crear aplicación backend-1 en ArgoCD
create-backend-1:
	@echo "Verificando si el namespace 'backend-1' existe..."
	if ! kubectl get namespace backend-1 >/dev/null 2>&1; then \
	    echo "El namespace 'backend-1' no existe. Creándolo..."; \
	    if ! kubectl create namespace backend-1; then \
	        echo "Error: Falló la creación del namespace 'backend-1'."; \
	        exit 1; \
	    fi; \
	fi
	@echo "Creando la aplicación backend-1 en ArgoCD..."
	if ! argocd app create backend-1 \
	    --repo https://github.com/JaimeHenaoChallange/backend-1.git \
	    --revision main \
	    --path ./helm-charts/backend-1 \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace backend-1 \
	    --sync-policy automated \
	    --project poc; then \
	    echo "Error: Falló la creación de la aplicación backend-1 en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación backend-1 creada exitosamente."

# Crear aplicación app-1 en ArgoCD
create-app-1:
	@echo "Verificando si el namespace 'app-1' existe..."
	if ! kubectl get namespace app-1 >/dev/null 2>&1; then \
	    echo "El namespace 'app-1' no existe. Creándolo..."; \
	    if ! kubectl create namespace app-1; then \
	        echo "Error: Falló la creación del namespace 'app-1'."; \
	        exit 1; \
	    fi; \
	fi
	@echo "Creando la aplicación app-1 en ArgoCD..."
	if ! argocd app create app-1 \
	    --repo https://github.com/JaimeHenaoChallange/app-1.git \
	    --revision main \
	    --path ./helm-charts/app-1 \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace app-1 \
	    --sync-policy automated \
	    --project poc; then \
	    echo "Error: Falló la creación de la aplicación app-1 en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación app-1 creada exitosamente."

# Crear aplicación app-2 en ArgoCD
create-app-2:
	@echo "Verificando si el namespace 'app-2' existe..."
	if ! kubectl get namespace app-2 >/dev/null 2>&1; then \
	    echo "El namespace 'app-2' no existe. Creándolo..."; \
	    if ! kubectl create namespace app-2; then \
	        echo "Error: Falló la creación del namespace 'app-2'."; \
	        exit 1; \
	    fi; \
	fi
	@echo "Creando la aplicación app-2 en ArgoCD..."
	if ! argocd app create app-2 \
	    --repo https://github.com/JaimeHenaoChallange/app-2.git \
	    --revision main \
	    --path ./helm-charts/app-2 \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace app-2 \
	    --sync-policy automated \
	    --project poc; then \
	    echo "Error: Falló la creación de la aplicación app-2 en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación app-2 creada exitosamente."

# Crear aplicación kubeops en ArgoCD
create-kubeops:
	@echo "Verificando si el namespace 'kubeops' existe..."
	if ! kubectl get namespace kubeops >/dev/null 2>&1; then \
	    echo "El namespace 'kubeops' no existe. Creándolo..."; \
	    if ! kubectl create namespace kubeops; then \
	        echo "Error: Falló la creación del namespace 'kubeops'."; \
	        exit 1; \
	    fi; \
	fi
	@echo "Creando la aplicación kubeops en ArgoCD..."
	if ! argocd app create kubeops \
	    --repo https://github.com/JaimeHenaoChallange/kubeops.git \
	    --revision main \
	    --path ./helm-charts/kubeops \
	    --dest-server https://kubernetes.default.svc \
	    --dest-namespace kubeops \
	    --sync-policy automated \
	    --project poc; then \
	    echo "Error: Falló la creación de la aplicación kubeops en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación kubeops creada exitosamente."