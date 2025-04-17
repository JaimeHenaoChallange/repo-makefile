#!/bin/bash

# Colores para el output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para mostrar mensajes
show_success() { echo -e "\n${GREEN}✅ $1${NC}"; }
show_error() { echo -e "\n${RED}❌ $1${NC}"; }
show_process() { echo -e "\n${YELLOW}⏳ $1${NC}"; }
show_info() { echo -e "\n${YELLOW}ℹ️  $1${NC}"; }
pause() { read -p "Presiona Enter para continuar..."; }
show_separator() { echo -e "\n${GREEN}════════════════════════════════════════════${NC}"; }

# Función para manejar errores
handle_error() {
    local exit_code=$1
    local message="$2"
    if [ $exit_code -ne 0 ]; then
        show_error "$message"
        exit $exit_code
    fi
}

# Función para mostrar el banner de bienvenida
show_banner() {
    clear
    echo -e "${GREEN}"
    echo "=========================================="
    echo "  Bienvenido al sistema de configuración  "
    echo "=========================================="
    echo -e "${NC}"
}

# Función para verificar conexión SSH con GitHub
check_ssh_connection() {
    show_process "Verificando conexión SSH con GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "success"; then
        show_success "Conexión SSH con GitHub verificada"
        return 0
    else
        show_error "No se pudo establecer conexión SSH con GitHub"
        return 1
    fi
}

# Función para configurar SSH
setup_ssh() {
    show_process "Configurando SSH..."
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        echo -e "${YELLOW}Introduce tu email para generar la clave SSH:${NC}"
        read -r email
        if [[ -z "$email" ]]; then
            show_error "El email no puede estar vacío."
            return 1
        fi
        ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
        handle_error $? "Error al generar la clave SSH."

        # Verificar si el agente SSH está en ejecución
        if ! pgrep -u "$USER" ssh-agent > /dev/null; then
            eval "$(ssh-agent -s)"
            handle_error $? "Error al iniciar el agente SSH."
        fi

        ssh-add ~/.ssh/id_ed25519
        handle_error $? "Error al añadir la clave SSH al agente."

        show_success "Clave SSH generada correctamente. Añádela a GitHub:"
        echo -e "${GREEN}$(cat ~/.ssh/id_ed25519.pub)${NC}"
    else
        show_info "Ya existe una clave SSH configurada en: ~/.ssh/id_ed25519"
        echo -e "${YELLOW}Contenido de la clave pública:${NC}"
        cat ~/.ssh/id_ed25519.pub
    fi
    pause
}

# Función para listar claves SSH existentes
list_ssh_keys() {
    show_process "Listando claves SSH existentes..."
    if [ -d ~/.ssh ]; then
        ls -l ~/.ssh/id_*.pub 2>/dev/null || show_info "No se encontraron claves SSH públicas."
    else
        show_info "No se encontró el directorio ~/.ssh."
    fi
    pause
}

# Función para eliminar una clave SSH específica
delete_ssh_key() {
    show_process "Eliminando una clave SSH..."
    echo -e "${YELLOW}Introduce el nombre del archivo de la clave SSH a eliminar (sin extensión):${NC}"
    read -r key_name
    if [[ -f ~/.ssh/"$key_name" && -f ~/.ssh/"$key_name".pub ]]; then
        rm -f ~/.ssh/"$key_name" ~/.ssh/"$key_name".pub
        handle_error $? "Error al eliminar la clave SSH."
        show_success "Clave SSH eliminada correctamente."
    else
        show_error "No se encontró la clave SSH especificada."
    fi
    pause
}

# Función para probar la conexión SSH con GitHub
test_ssh_connection() {
    show_process "Probando la conexión SSH con GitHub..."
    ssh -T git@github.com 2>&1 | grep -q "success"
    if [ $? -eq 0 ]; then
        show_success "Conexión SSH con GitHub verificada correctamente."
    else
        show_error "No se pudo establecer conexión SSH con GitHub. Verifica tu configuración."
    fi
    pause
}

# Función para verificar dependencias
check_dependencies() {
    show_process "Verificando dependencias..."
    local deps=("kubectl" "helm" "ssh")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            show_error "Dependencia faltante: $dep"
            return 1
        fi
    done
    show_success "Todas las dependencias están instaladas."
}

# Función para verificar conexión a Kubernetes
check_kubernetes() {
    show_process "Verificando conexión a Kubernetes..."
    if kubectl get nodes &>/dev/null; then
        show_success "Conexión a Kubernetes establecida."
    else
        show_error "No hay conexión con Kubernetes. Verifica que Minikube está corriendo."
        return 1
    fi
}

# Función para obtener la IP del nodo de Kubernetes
get_kubernetes_node_ip() {
    show_process "Obteniendo la IP del nodo de Kubernetes..."
    local node_ip
    if minikube status &>/dev/null; then
        node_ip=$(minikube ip)
    else
        node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    fi

    if [[ -z "$node_ip" ]]; then
        show_error "No se pudo obtener la IP del nodo de Kubernetes."
        exit 1
    fi

    show_success "IP del nodo de Kubernetes: $node_ip"
    echo "$node_ip"
}

# Función para configurar Ingress
setup_ingress() {
    show_process "Configurando Ingress en el clúster de Kubernetes..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
    handle_error $? "Error al aplicar los manifiestos de Ingress."

    show_process "Esperando que el controlador de Ingress esté listo..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=Ready pods \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    handle_error $? "Error al esperar que el controlador de Ingress esté listo."

    local node_ip
    node_ip=$(get_kubernetes_node_ip)
    show_success "Ingress configurado correctamente. Usa la IP del nodo: $node_ip"
}

# Función para instalar/actualizar ArgoCD
setup_argocd() {
    show_process "Instalando/Actualizando ArgoCD..."
    kubectl create namespace argocd 2>/dev/null || true
    handle_error $? "Error al crear el namespace de ArgoCD."

    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    handle_error $? "Error al aplicar los manifiestos de ArgoCD."

    show_process "Esperando que los pods de ArgoCD estén listos..."
    kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
    handle_error $? "Error al esperar que los pods de ArgoCD estén listos."

    show_success "ArgoCD instalado/actualizado correctamente."
    pause
}

# Función para instalar el cliente de ArgoCD (argocd-cli)
install_argocd_cli() {
    show_process "Verificando si el cliente de ArgoCD (argocd-cli) está instalado..."
    if ! command -v argocd &>/dev/null; then
        show_process "Instalando el cliente de ArgoCD..."

        # Crear un directorio alternativo si no hay permisos en /usr/local/bin
        local install_dir="/usr/local/bin"
        if [ ! -w "$install_dir" ]; then
            install_dir="$HOME/bin"
            mkdir -p "$install_dir"
            show_info "Usando directorio alternativo para instalación: $install_dir"

            # Agregar ~/bin al PATH si no está ya presente
            if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
                export PATH="$HOME/bin:$PATH"
                echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
                show_info "Directorio $HOME/bin agregado al PATH."
            fi
        fi

        # Descargar e instalar el binario
        local argocd_url="https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
        curl -sSL -o "$install_dir/argocd" "$argocd_url"
        if [ $? -ne 0 ] || [ ! -f "$install_dir/argocd" ]; then
            show_error "Error al descargar el cliente de ArgoCD. Verifica tu conexión a internet."
            return 1
        fi

        chmod +x "$install_dir/argocd"
        if [ $? -ne 0 ]; then
            show_error "Error al hacer ejecutable el cliente de ArgoCD."
            return 1
        fi

        show_success "Cliente de ArgoCD instalado correctamente en $install_dir."
    else
        show_info "El cliente de ArgoCD ya está instalado."
    fi
    pause
}

# Función para obtener la contraseña inicial de ArgoCD
get_argocd_password() {
    show_process "Obteniendo la contraseña inicial de ArgoCD..."
    local password
    password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
    handle_error $? "Error al obtener la contraseña inicial de ArgoCD."
    show_success "Contraseña inicial de ArgoCD: $password"
    pause
}

# Función para sincronizar aplicaciones en ArgoCD
sync_argocd_apps() {
    show_process "Sincronizando aplicaciones en ArgoCD..."
    argocd app sync --all
    handle_error $? "Error al sincronizar aplicaciones en ArgoCD."
    show_success "Aplicaciones sincronizadas correctamente."
    pause
}

# Función para iniciar port-forward de ArgoCD
start_argocd_port_forward() {
    show_process "Iniciando port-forward para ArgoCD..."
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &
    handle_error $? "Error al iniciar el port-forward de ArgoCD."
    show_success "Port-forward iniciado. Accede a ArgoCD en https://localhost:8080"
    pause
}

# Función para detener port-forward de ArgoCD
stop_argocd_port_forward() {
    show_process "Deteniendo port-forward para ArgoCD..."
    pkill -f "kubectl port-forward svc/argocd-server"
    handle_error $? "Error al detener el port-forward de ArgoCD."
    show_success "Port-forward detenido correctamente."
    pause
}

# Función para cambiar la contraseña del usuario admin en ArgoCD
change_argocd_password() {
    show_process "Cambiando la contraseña del usuario admin en ArgoCD..."
    
    # Verificar si el cliente de ArgoCD está instalado
    if ! command -v argocd &>/dev/null; then
        show_error "El cliente de ArgoCD (argocd-cli) no está instalado. Por favor, instálalo primero."
        return 1
    fi

    # Solicitar la nueva contraseña
    echo -e "${YELLOW}Introduce la nueva contraseña para el usuario admin:${NC}"
    read -r -s new_password
    if [[ -z "$new_password" ]]; then
        show_error "La contraseña no puede estar vacía."
        return 1
    fi

    # Cambiar la contraseña usando argocd-cli
    argocd account update-password --current-password admin --new-password "$new_password" --server localhost:8080 --insecure
    if [ $? -eq 0 ]; then
        show_success "Contraseña del usuario admin cambiada correctamente."
    else
        show_error "Error al cambiar la contraseña. Verifica que estás autenticado en el servidor de ArgoCD."
    fi
    pause
}

# Función para verificar el clúster de Kind
verify_kind_cluster() {
    show_process "Verificando el clúster de Kind..."
    if kind get clusters | grep -q "kind"; then
        show_success "El clúster de Kind ya está disponible."
    else
        show_process "Creando un nuevo clúster de Kind..."
        kind create cluster --config kind-config.yaml
        handle_error $? "Error al crear el clúster de Kind."
        show_success "Clúster de Kind creado correctamente."
    fi
    pause
}

# Menú principal
show_menu() {
    clear
    echo -e "${GREEN}=== Menú Principal ===${NC}"
    echo "1. GitHub"
    echo "2. ArgoCD"
    echo "3. Gestión Kubernetes y Sistema"
    echo "4. Configurar Ingress"
    echo "5. Verificar Clúster de Kind"
    echo "6. Salir"
    echo -e "${YELLOW}Selecciona una opción:${NC}"
}

# Submenú GitHub
show_github_menu() {
    clear
    echo -e "${GREEN}=== Menú GitHub ===${NC}"
    echo "1. Verificar/Configurar SSH"
    echo "2. Listar claves SSH existentes"
    echo "3. Eliminar una clave SSH"
    echo "4. Probar conexión SSH con GitHub"
    echo "5. Volver al Menú Principal"
    echo -e "${YELLOW}Selecciona una opción:${NC}"
}

# Submenú ArgoCD
show_argocd_menu() {
    clear
    echo -e "${GREEN}=== Menú ArgoCD ===${NC}"
    echo "1. Instalar/Actualizar ArgoCD"
    echo "2. Instalar cliente de ArgoCD (argocd-cli)"
    echo "3. Obtener contraseña inicial"
    echo "4. Sincronizar aplicaciones"
    echo "5. Iniciar port-forward de ArgoCD"
    echo "6. Detener port-forward de ArgoCD"
    echo "7. Cambiar contraseña del usuario admin"
    echo "8. Volver al Menú Principal"
    echo -e "${YELLOW}Selecciona una opción:${NC}"
}

# Submenú Gestión Kubernetes y Sistema
show_kubernetes_menu() {
    clear
    echo -e "${GREEN}=== Menú Gestión Kubernetes y Sistema ===${NC}"
    echo "1. Verificar dependencias"
    echo "2. Verificar conexión a Kubernetes"
    echo "3. Volver al Menú Principal"
    echo -e "${YELLOW}Selecciona una opción:${NC}"
}

# Mostrar el banner de bienvenida
show_banner

# Loop principal
while true; do
    show_menu
    read -r opt
    case $opt in
        1)
            while true; do
                show_github_menu
                read -r github_opt
                case $github_opt in
                    1) setup_ssh ;;
                    2) list_ssh_keys ;;
                    3) delete_ssh_key ;;
                    4) test_ssh_connection ;;
                    5) break ;;
                    *) show_error "Opción inválida." ;;
                esac
                pause
            done
            ;;
        2)
            while true; do
                show_argocd_menu
                read -r argocd_opt
                case $argocd_opt in
                    1) setup_argocd ;;
                    2) install_argocd_cli ;;
                    3) get_argocd_password ;;
                    4) sync_argocd_apps ;;
                    5) start_argocd_port_forward ;;
                    6) stop_argocd_port_forward ;;
                    7) change_argocd_password ;;
                    8) break ;;
                    *) show_error "Opción inválida." ;;
                esac
            done
            ;;
        3)
            while true; do
                show_kubernetes_menu
                read -r kubernetes_opt
                case $kubernetes_opt in
                    1) check_dependencies ;;
                    2) check_kubernetes ;;
                    3) break ;;
                    *) show_error "Opción inválida." ;;
                esac
                pause
            done
            ;;
        4) setup_ingress ;;
         5) verify_kind_cluster ;;
        6)
            show_success "¡Hasta luego!"
            exit 0
            ;;
        *)
            show_error "Opción inválida."
            pause
            ;;
    esac
done