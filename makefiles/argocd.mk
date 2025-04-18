# Instalar ArgoCD
install-argocd:
	@echo "Instalando ArgoCD usando el script..."
	@if ! bash scripts/install-argocd.sh; then \
	    echo "Error: Falló la instalación de ArgoCD."; \
	    exit 1; \
	fi

# Crear proyecto en ArgoCD con configuraciones personalizadas
create-project:
	@echo "Creando un proyecto en ArgoCD..."
	@read -p "Nombre del proyecto (ejemplo: poc): " PROJECT_NAME; \
	read -p "Descripción del proyecto (ejemplo: Proyecto de prueba para aplicaciones): " DESCRIPTION; \
	read -p "Destino del clúster (puedes agregar múltiples destinos separados por comas, ejemplo: https://kubernetes.default.svc,default,https://otro-clúster.svc,namespace): " DEST; \
	DEST=$${DEST:-https://kubernetes.default.svc,default}; \
	read -p "Fuente permitida (puedes agregar múltiples fuentes separadas por comas, ejemplo: https://github.com/tu-repo.git,https://otro-repo.git): " SRC; \
	SRC=$${SRC:-*}; \
	read -p "Recursos de clúster permitidos (puedes agregar múltiples recursos separados por comas, ejemplo: *,ConfigMap,Secret): " CLUSTER_RESOURCES; \
	CLUSTER_RESOURCES=$${CLUSTER_RESOURCES:-*}; \
	if ! argocd proj create $$PROJECT_NAME \
	    --description "$$DESCRIPTION" \
	    --dest "$$DEST" \
	    --src "$$SRC" \
	    --allow-cluster-resource "$$CLUSTER_RESOURCES"; then \
	    echo "Error: Falló la creación del proyecto '$$PROJECT_NAME'."; \
	    exit 1; \
	fi
	@echo "Proyecto '$$PROJECT_NAME' creado exitosamente."

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

# Cambiar contraseña de ArgoCD
change-password:
	@echo "Cambiando la contraseña del usuario admin en ArgoCD..."
	@bash -c ' \
	CURRENT_PASSWORD=$$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d); \
	read -s -p "Nueva contraseña: " NEW_PASSWORD; echo; \
	if ! argocd account update-password --current-password $$CURRENT_PASSWORD --new-password $$NEW_PASSWORD; then \
	    echo "Error: Falló el cambio de la contraseña."; \
	    exit 1; \
	fi; \
	echo "Contraseña cambiada exitosamente.";'

# Realizar un port-forward al localhost:8080
port-forward:
	@echo "Realizando port-forward al localhost:8080 para ArgoCD..."
	kubectl port-forward svc/argocd-server -n argocd 8080:443
	@echo "Port-forward activo. Accede a ArgoCD en https://localhost:8080"

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

# Configurar proyecto para permitir repositorios y destinos
configure-project:
	@echo "Configurando el proyecto 'poc' en ArgoCD..."
	argocd proj add-destination poc \
	    --dest https://kubernetes.default.svc,backend
	argocd proj add-destination poc \
	    --dest https://kubernetes.default.svc,default
	argocd proj add-source poc \
	    --src https://github.com/JaimeHenaoChallange/backend.git
	argocd proj add-source poc \
	    --src https://github.com/JaimeHenaoChallange/frontend.git
	@echo "Proyecto 'poc' configurado exitosamente."