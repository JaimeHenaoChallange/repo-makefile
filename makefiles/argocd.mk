# Instalar ArgoCD
install-argocd:
	@echo "Instalando ArgoCD usando el script..."
	@if ! bash scripts/install-argocd.sh; then \
	    echo "Error: Falló la instalación de ArgoCD."; \
	    exit 1; \
	fi

# Crear proyecto en ArgoCD con configuraciones personalizadas
create-project:
	@echo "Creando el proyecto 'poc' en ArgoCD..."
	@read -p "Descripción del proyecto: " DESCRIPTION; \
	read -p "Destino del clúster (por defecto: https://kubernetes.default.svc,*): " DEST; \
	DEST=$${DEST:-https://kubernetes.default.svc,*}; \
	read -p "Fuente permitida (por defecto: *): " SRC; \
	SRC=$${SRC:-*}; \
	read -p "Recursos de clúster permitidos (por defecto: *): " CLUSTER_RESOURCES; \
	CLUSTER_RESOURCES=$${CLUSTER_RESOURCES:-*}; \
	if ! argocd proj create poc \
	    --description "$$DESCRIPTION" \
	    --dest "$$DEST" \
	    --src "$$SRC" \
	    --allow-cluster-resource "$$CLUSTER_RESOURCES"; then \
	    echo "Error: Falló la creación del proyecto 'poc'."; \
	    exit 1; \
	fi
	@echo "Proyecto 'poc' creado exitosamente."

# Agregar repositorios a ArgoCD
add-repositories:
	@echo "Agregando repositorios a ArgoCD..."
	if ! argocd repo list | grep -q "https://github.com/JaimeHenaoChallange/backend.git"; then \
	    if ! argocd repo add https://github.com/JaimeHenaoChallange/backend.git --username <user> --password <password>; then \
	        echo "Error: Falló al agregar el repositorio 'backend'."; \
	        exit 1; \
	    fi; \
	else \
	    echo "El repositorio 'backend' ya está agregado."; \
	fi
	if ! argocd repo list | grep -q "https://github.com/JaimeHenaoChallange/frontend.git"; then \
	    if ! argocd repo add https://github.com/JaimeHenaoChallange/frontend.git --username <user> --password <password>; then \
	        echo "Error: Falló al agregar el repositorio 'frontend'."; \
	        exit 1; \
	    fi; \
	else \
	    echo "El repositorio 'frontend' ya está agregado."; \
	fi
	@echo "Repositorios agregados exitosamente."

# Configurar autenticación SSO
configure-sso:
	@echo "Configurando autenticación SSO para ArgoCD..."
	kubectl -n argocd patch configmap argocd-cm \
	    --type merge \
	    -p '{"data":{"url":"https://argocd.example.com","oidc.config":"name: SSO\nissuer: https://accounts.google.com\nclientID: <client-id>\nclientSecret: <client-secret>\nredirectURI: https://argocd.example.com/auth/callback\n"}}'
	@echo "Autenticación SSO configurada exitosamente."

# Configurar acceso inicial
configure-access:
	@echo "Configurando acceso inicial para ArgoCD..."
	ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
	argocd login <Node-IP>:<NodePort> --username admin --password $$ARGOCD_PASSWORD --insecure
	@echo "Acceso inicial configurado exitosamente."

# Desinstalar y eliminar ArgoCD
uninstall-argocd:
	@echo "Desinstalando y eliminando ArgoCD..."
	@if kubectl get namespace argocd >/dev/null 2>&1; then \
	    echo "Eliminando recursos de ArgoCD..."; \
	    kubectl delete namespace argocd --grace-period=0 --force; \
	    echo "ArgoCD eliminado exitosamente."; \
	else \
	    echo "El namespace 'argocd' no existe. Nada que eliminar."; \
	fi