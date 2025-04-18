# Configuración global
ARGOCD_SERVER=https://kubernetes.default.svc
REPO_BASE=https://github.com/JaimeHenaoChallange

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

# Función genérica para crear aplicaciones
define create-app
	$(call ensure-namespace,$(2))
	@echo "Creando la aplicación $(1) en ArgoCD..."
	if ! argocd app create $(1) \
	    --repo $(REPO_BASE)/$(3).git \
	    --revision main \
	    --path ./helm-charts/$(3) \
	    --dest-server $(ARGOCD_SERVER) \
	    --dest-namespace $(2) \
	    --sync-policy automated \
	    --project $(4); then \
	    echo "Error: Falló la creación de la aplicación $(1) en ArgoCD."; \
	    exit 1; \
	fi
	@echo "Aplicación $(1) creada exitosamente."
endef

# Crear aplicaciones específicas
create-backend:
	$(call ensure-namespace,backend)
	@if [ -z "$(PROJECT_NAME)" ]; then \
	    echo "❌ Error: Debes proporcionar el nombre del proyecto usando la variable PROJECT_NAME."; \
	    echo "ℹ️  Proyectos disponibles en ArgoCD:"; \
	    argocd proj list -o name; \
	    echo "💡 Ejemplo: make create-backend PROJECT_NAME=poc"; \
	    exit 1; \
	fi
	@if ! argocd proj get $(PROJECT_NAME) >/dev/null 2>&1; then \
	    echo "❌ Error: El proyecto '$(PROJECT_NAME)' no existe en ArgoCD."; \
	    echo "💡 Por favor, verifica el nombre del proyecto o créalo antes de continuar."; \
	    exit 1; \
	fi
	@echo "✅ Usando el proyecto: $(PROJECT_NAME)"
	@echo "🚀 Creando la aplicación 'backend' en ArgoCD..."
	if ! argocd app create backend \
	    --repo $(REPO_BASE)/backend.git \
	    --revision main \
	    --path ./helm-charts/backend \
	    --dest-server $(ARGOCD_SERVER) \
	    --dest-namespace backend \
	    --sync-policy automated \
	    --project $(PROJECT_NAME); then \
	    echo "❌ Error: Falló la creación de la aplicación 'backend' en ArgoCD."; \
	    exit 1; \
	fi
	@echo "🎉 Aplicación 'backend' creada exitosamente en el proyecto '$(PROJECT_NAME)'."

create-frontend:
	$(call create-app,frontend,frontend,frontend,$(PROJECT_NAME))

create-backend-1:
	$(call create-app,backend-1,backend-1,backend-1,$(PROJECT_NAME))

create-app-1:
	$(call create-app,app-1,app-1,app-1,$(PROJECT_NAME))

create-app-2:
	$(call create-app,app-2,app-2,app-2,$(PROJECT_NAME))

create-kubeops:
	$(call create-app,kubeops,kubeops,kubeops,$(PROJECT_NAME))