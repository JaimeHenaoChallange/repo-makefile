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