# Configuración global
ARGOCD_SERVER=https://kubernetes.default.svc
REPO_BASE=https://github.com/JaimeHenaoChallange

# Función para verificar y crear namespaces
define ensure-namespace
	@echo "🔍 Verificando si el namespace '$(1)' existe..."
	@if ! kubectl get namespace $(1) >/dev/null 2>&1; then \
	    echo "⚠️  El namespace '$(1)' no existe. Creándolo..."; \
	    if ! kubectl create namespace $(1); then \
	        echo "❌ Error: Falló la creación del namespace '$(1)'."; \
	        exit 1; \
	    fi; \
	    echo "✅ Namespace '$(1)' creado exitosamente."; \
	fi
endef

# Función genérica para crear aplicaciones
define create-app
	$(call ensure-namespace,$(2))
	@echo "🚀 Creando la aplicación '$(1)' en ArgoCD..."
	@echo "ℹ️  Opciones de path disponibles:"
	@echo "1) ./Kubernetes"
	@echo "2) ./helm-charts"
	@echo "3) ./helm-charts/backend"
	@echo "4) ./helm-charts/database"
	@echo "5) ./helm-charts/redis"
	@read -p "Selecciona el número correspondiente al path (1, 2, 3, 4 o 5): " PATH_OPTION; \
	case $$PATH_OPTION in \
	    1) APP_PATH="./Kubernetes";; \
	    2) APP_PATH="./helm-charts";; \
	    3) APP_PATH="./helm-charts/backend";; \
	    4) APP_PATH="./helm-charts/database";; \
	    5) APP_PATH="./helm-charts/redis";; \
	    *) echo "❌ Opción inválida. Abortando."; exit 1;; \
	esac; \
	if [ ! -d "$$APP_PATH" ] || [ -z "$$(ls -A $$APP_PATH 2>/dev/null)" ]; then \
	    echo "❌ Error: El path seleccionado '$$APP_PATH' no existe o está vacío. Por favor verifica."; \
	    echo "💡 Sugerencia: Asegúrate de que el directorio exista y contenga los manifiestos necesarios."; \
	    exit 1; \
	fi; \
	if ! argocd app create $(1) \
	    --repo $(REPO_BASE)/$(3).git \
	    --revision main \
	    --path $$APP_PATH \
	    --dest-server $(ARGOCD_SERVER) \
	    --dest-namespace $(2) \
	    --sync-policy automated \
	    --project $(4); then \
	    echo "❌ Error: Falló la creación de la aplicación '$(1)' en ArgoCD."; \
	    exit 1; \
	fi; \
	echo "🎉 Aplicación '$(1)' creada exitosamente en el proyecto '$(4)' con el path $$APP_PATH."
endef

# Crear aplicaciones específicas
create-backend:
	$(call create-app,backend,backend,backend,$(PROJECT_NAME))

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