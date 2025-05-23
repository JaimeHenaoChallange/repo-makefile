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
	@if ! bash scripts/create-project.sh; then \
	    echo "Error: Falló la creación del proyecto."; \
	    exit 1; \
	fi

# Actualizar proyecto en ArgoCD
update-project:
	@echo "Actualizando un proyecto en ArgoCD..."
	@if ! bash scripts/update-project.sh; then \
	    echo "Error: Falló la actualización del proyecto."; \
	    exit 1; \
	fi

# Agregar repositorios a ArgoCD
add-repo:
	@echo "Agregando repositorios a ArgoCD..."
	@if ! bash scripts/add-repositories.sh; then \
	    echo "Error: Falló al agregar los repositorios."; \
	    exit 1; \
	fi

# Configurar autenticación SSO
configure-sso:
	@echo "Configurando autenticación SSO para ArgoCD..."
	kubectl -n argocd patch configmap argocd-cm \
	    --type merge \
	    -p '{"data":{"url":"https://argocd.example.com","oidc.config":"name: SSO\nissuer: https://accounts.google.com\nclientID: <client-id>\nclientSecret: <client-secret>\nredirectURI: https://argocd.example.com/auth/callback\n"}}'
	@echo "Autenticación SSO configurada exitosamente."

# Acceso a argocd-cli
access-cli:
	@bash scripts/access-argocd.sh

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

# Eliminar proyecto en ArgoCD
delete-project:
	@echo "Eliminando un proyecto en ArgoCD..."
	@if ! bash scripts/delete-project.sh; then \
	    echo "Error: Falló la eliminación del proyecto."; \
	    exit 1; \
	fi