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
	if ! helm upgrade --install redis ./backend/helm-charts/redis -n $(K8S_NAMESPACE); then \
	    echo "Error: Falló el despliegue del Helm chart para redis."; \
	    exit 1; \
	fi

deploy-helm:
	@echo "Desplegando todos los Helm charts..."
	make deploy-frontend
	make deploy-database
	make deploy-redis

# Eliminar despliegues de Helm charts
delete-frontend:
	@echo "Eliminando despliegue de frontend..."
	if ! helm uninstall frontend -n $(K8S_NAMESPACE); then \
	    echo "Error: Falló la eliminación del despliegue de frontend."; \
	    exit 1; \
	fi

delete-database:
	@echo "Eliminando despliegue de database..."
	if ! helm uninstall database -n $(K8S_NAMESPACE); then \
	    echo "Error: Falló la eliminación del despliegue de database."; \
	    exit 1; \
	fi

delete-redis:
	@echo "Eliminando despliegue de redis..."
	if ! helm uninstall redis -n $(K8S_NAMESPACE); then \
	    echo "Error: Falló la eliminación del despliegue de redis."; \
	    exit 1; \
	fi

delete-helm:
	@echo "Eliminando todos los despliegues de Helm charts..."
	make delete-frontend
	make delete-database
	make delete-redis