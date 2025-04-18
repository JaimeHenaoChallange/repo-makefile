# Función para verificar y crear namespaces
define ensure-namespace
	@echo "Verificando si el namespace '$(1)' existe..."
	if ! kubectl get namespace $(1) >/dev/null 2>&1; then \
	    echo "El namespace '$(1)' no existe. Creándolo..."; \
	    if ! kubectl create namespace $(1); then \
	        echo "Error: Falló la creación del namespace '$(1)'."; \
	        exit 1; \
	    fi; \
	fi
endef

# Crear aplicaciones en ArgoCD
create-backend:
	$(call ensure-namespace,backend)
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

create-frontend:
	$(call ensure-namespace,frontend)
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

create-backend-1:
	$(call ensure-namespace,backend-1)
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

create-app-1:
	$(call ensure-namespace,app-1)
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

create-app-2:
	$(call ensure-namespace,app-2)
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

create-kubeops:
	$(call ensure-namespace,kubeops)
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