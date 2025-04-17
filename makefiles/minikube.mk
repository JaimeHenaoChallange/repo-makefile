# Reglas para gestionar Minikube

# Crear un clúster de Minikube
create-minikube-cluster:
    @echo "Creando clúster de Minikube..."
    minikube start --driver=docker
    @echo "Clúster de Minikube creado exitosamente."

# Configurar Ingress en Minikube
setup-minikube-ingress:
    @echo "Configurando Ingress en Minikube..."
    minikube addons enable ingress
    @echo "Ingress configurado exitosamente en Minikube."

# Eliminar el clúster de Minikube
delete-minikube-cluster:
    @echo "Eliminando clúster de Minikube..."
    minikube delete
    @echo "Clúster de Minikube eliminado exitosamente."