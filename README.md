# Repo Makefile - Automatización de Tareas

![CI](https://github.com/jaimehenao8126/repo-makefile/actions/workflows/ci.yml/badge.svg)

Este repositorio contiene configuraciones y `Makefiles` diseñados para automatizar tareas relacionadas con la gestión de clústeres Kubernetes, despliegues con Helm, integración con ArgoCD, y manejo de imágenes Docker. Está pensado para facilitar la configuración y administración de entornos de desarrollo y producción.

---

## Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Estructura del Repositorio](#estructura-del-repositorio)
3. [Diagrama](#diagrama)
4. [Funcionalidades](#funcionalidades)
5. [Gestión de Minikube](#gestión-de-minikube)
6. [Uso](#uso)
7. [Personalización](#personalización)
8. [Contribuciones](#contribuciones)
9. [Licencia](#licencia)
10. [Troubleshooting](#troubleshooting)
11. [Roadmap](#roadmap)
12. [Corrección de Espacios en Blanco e Indentación](#corrección-de-espacios-en-blanco-e-indentación)

---

## Requisitos Previos

Antes de usar este repositorio, asegúrate de tener instaladas las siguientes herramientas:

- **Docker CLI**: Para construir y publicar imágenes Docker.
- **kubectl**: Para interactuar con clústeres Kubernetes.
- **Helm**: Para gestionar despliegues de Helm charts.
- **ArgoCD CLI**: Para gestionar aplicaciones en ArgoCD.
- **Minikube (opcional)**: Para ejecutar un clúster Kubernetes local.

### Instalación de Herramientas

```bash
# Instalar Docker
sudo apt-get update && sudo apt-get install -y docker.io

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Instalar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64 && sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Instalar Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# Instalar ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

## Estructura del Repositorio

El repositorio está organizado de la siguiente manera:

```
repo-makefile/
├── Makefile                # Archivo principal que incluye los módulos
├── [CHANGELOG.md](http://_vscodecontentref_/1)            # Registro de cambios
├── [README.md](http://_vscodecontentref_/2)               # Documentación principal
├── .github/                # Configuración de GitHub
│   ├── ISSUE_TEMPLATE.md   # Plantilla para issues
│   ├── PULL_REQUEST_TEMPLATE.md # Plantilla para pull requests
│   └── workflows/ci.yml    # Configuración de CI
├── examples/               # Ejemplos de configuración
│   ├── argocd-app.yaml     # Ejemplo de aplicación ArgoCD
│   ├── deployment.yaml     # Ejemplo de despliegue Kubernetes
│   └── values.yaml         # Ejemplo de valores para Helm
├── makefiles/              # Directorio con los Makefiles modulares
│   ├── [argocd-apps.mk](http://_vscodecontentref_/3)      # Creación de aplicaciones en ArgoCD
│   ├── [argocd.mk](http://_vscodecontentref_/4)           # Gestión de ArgoCD
│   ├── dependencies.mk     # Verificación de dependencias
│   ├── docker.mk           # Construcción y publicación de imágenes Docker
│   ├── helm.mk             # Despliegue y eliminación de Helm charts
│   ├── kind.mk             # Gestión de clústeres Kind
│   ├── minikube.mk         # Gestión de clústeres Minikube
├── scripts/                # Scripts auxiliares
│   ├── [add-repositories.sh](http://_vscodecontentref_/5) # Añadir repositorios a ArgoCD
│   ├── cleanup.sh          # Limpieza de recursos
│   ├── [create-app.sh](http://_vscodecontentref_/6)       # Crear aplicaciones en ArgoCD
│   ├── [create-project.sh](http://_vscodecontentref_/7)   # Crear proyectos en ArgoCD
│   ├── delete-project.sh   # Eliminar proyectos en ArgoCD
│   ├── install-argocd.sh   # Instalación de ArgoCD
│   ├── install-kind-cluster.sh # Instalación de Kind
│   ├── install-kuma.sh     # Instalación de Kuma
│   ├── [setup.sh](http://_vscodecontentref_/8)            # Configuración inicial
│   └── [update-project.sh](http://_vscodecontentref_/9)   # Actualizar proyectos en ArgoCD
└── tests/                  # Pruebas automatizadas
    └── test-makefiles.sh   # Pruebas para los Makefiles
```

## Diagrama

```
+-------------------+       +-------------------+
|                   |       |                   |
|    Docker CLI     |       |    Makefiles      |
|                   |       |                   |
+-------------------+       +-------------------+
            |                         |
            v                         v
+------------------------------------------------+
|                Kubernetes Cluster              |
|                                                |
|  +-------------------+   +-------------------+ |
|  |                   |   |                   | |
|  |  Ingress          |   |  ArgoCD           | |
|  |  Controller       |   |                   | |
|  +-------------------+   +-------------------+ |
|                                                |
|  +-------------------+   +-------------------+ |
|  |                   |   |                   | |
|  |  Helm             |   |  Applications     | |
|  |                   |   |                   | |
|  +-------------------+   +-------------------+ |
+------------------------------------------------+
```

---

### **5. Añadir un Diagrama Visual**
El diagrama en texto es útil, pero un diagrama visual en formato `.png` o `.svg` sería más atractivo. Puedes usar herramientas como [draw.io](https://app.diagrams.net/) para crearlo y añadirlo al directorio `docs/`. Luego, enlázalo en el [README.md](http://_vscodecontentref_/1):

```markdown
## Diagrama de Arquitectura

El siguiente diagrama muestra cómo interactúan los componentes principales del repositorio:

![Diagrama de Arquitectura](docs/architecture-diagram.png)
```

## Funcionalidades

### 1. **Gestión de Clústeres Kubernetes con Kind**
- Crear y eliminar clústeres de Kind.
- Configurar Ingress en el clúster.

### 2. **Gestión de Aplicaciones con ArgoCD**
- Instalar ArgoCD.
- Crear aplicaciones en ArgoCD para diferentes servicios (backend, frontend, etc.).

### 3. **Gestión de Imágenes Docker**
- Construir imágenes Docker para servicios como backend, frontend, base de datos, etc.
- Publicar imágenes Docker en un registro.

### 4. **Despliegue con Helm**
- Desplegar servicios utilizando Helm charts.
- Eliminar despliegues de Helm charts.

## Gestión de Minikube

### Crear un Clúster de Minikube
Para crear un clúster de Minikube, ejecuta:

```bash
make create-minikube-cluster
```

### Eliminar y Crear un Clúster de Minikube
Para eliminar y crear un clúster de Minikube, ejecuta:

```bash
minikube delete && minikube start --driver=docker
```

## Uso

### 1. **Clonar el Repositorio**
Clona este repositorio en tu máquina local o contenedor de desarrollo:

```bash
git clone https://github.com/tu-usuario/repo-makefile.git
cd repo-makefile
```

### 2. **Verificar Dependencias**
Ejecuta el siguiente comando para asegurarte de que todas las dependencias están instaladas:

```bash
make check-dependencies
```

### 3. **Crear un Clúster de Kind**
Para crear un clúster de Kind, ejecuta:

```bash
make create-kind-cluster
```

### 4. **Configurar Ingress**
Configura Ingress en el clúster:

```bash
make setup-ingress
```

### 5. **Instalar ArgoCD**
Instala ArgoCD en el clúster:

```bash
make install-argocd
```

### 6. **Desplegar Aplicaciones**
Despliega aplicaciones utilizando ArgoCD o Helm. Por ejemplo:

```bash
make create-backend
make deploy-frontend
argocd app sync backend
```

### 7. **Construir y Publicar Imágenes Docker**
Construye y publica imágenes Docker:

```bash
make build-backend
make push-backend
```

## Personalización

Puedes personalizar las configuraciones generales en el archivo `Makefile` principal:

```makefile
KUMA_VERSION ?= 2.7.1
DOCKER_USERNAME ?= tu-usuario
K8S_NAMESPACE ?= poc
HELM_REPO ?= https://kumahq.github.io/charts
KIND_CLUSTER_NAME ?= kind-cluster
```

## Contribuciones

Si deseas contribuir a este repositorio, por favor abre un issue o envía un pull request. ¡Toda ayuda es bienvenida!

## Licencia

Este proyecto está licenciado bajo la [MIT License](LICENSE). Puedes usarlo, modificarlo y distribuirlo libremente, siempre y cuando incluyas la licencia original.

---

¡Gracias por usar este repositorio! Si tienes alguna pregunta, no dudes en contactarnos.

## Troubleshooting

### Error: "kubectl no está instalado"
Asegúrate de que `kubectl` está instalado y disponible en tu `PATH`. Usa el comando:

```bash
kubectl version --client
```

---

### **4. Añadir una Sección de Ejemplos**
Incluye ejemplos prácticos para que los usuarios puedan probar rápidamente:

```markdown
## Ejemplos

### Desplegar una Aplicación con Helm
1. Crea un clúster de Kind:
   ```bash
   make create-kind-cluster
```

### Verificar Pods en el Namespace `poc`
Para verificar los pods en el namespace `poc`, ejecuta:

```bash
kubectl get pods -n poc
```

## Créditos

Este repositorio utiliza las siguientes herramientas y tecnologías:

- [Kind](https://kind.sigs.k8s.io/)
- [Helm](https://helm.sh/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Minikube](https://minikube.sigs.k8s.io/)

## Roadmap

- [ ] Añadir soporte para EKS/GKE/AKS.
- [ ] Implementar pruebas automatizadas para los Makefiles.
- [ ] Crear un script para migrar aplicaciones entre clústeres.
- [ ] Mejorar la integración con CI/CD.

## Corrección de Espacios en Blanco e Indentación.

Si necesitas corregir la indentación de los archivos .mk para asegurarte de que utilizan tabulaciones en lugar de espacios, puedes ejecutar los siguientes comandos:

```
# Corregir la indentación en dependencies.mk
sed -i 's/^    /\t/g' dependencies.mk

# Corregir la indentación en argocd.mk
sed -i 's/^    /\t/g' argocd.mk

# Corregir la indentación en docker.mk
sed -i 's/^    /\t/g' docker.mk

# Corregir la indentación en helm.mk
sed -i 's/^    /\t/g' helm.mk

# Corregir la indentación en kind.mk
sed -i 's/^    /\t/g' kind.mk

# Corregir la indentación en minikube.mk
sed -i 's/^    /\t/g' minikube.mk

# Cambiar al directorio principal
cd ..

# Corregir la indentación en el archivo Makefile principal
sed -i 's/^    /\t/g' Makefile
```
## ¿Por qué es importante?

En los archivos Makefile, las reglas deben estar indentadas con tabulaciones y no con espacios. Si utilizas espacios en lugar de tabulaciones, el make fallará con un error de sintaxis. Estos comandos aseguran que todos los archivos .mk y el archivo principal Makefile estén correctamente formateados.