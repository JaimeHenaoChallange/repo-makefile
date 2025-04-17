# Repo Makefile - Automatización de Tareas

Este repositorio contiene configuraciones y `Makefiles` diseñados para automatizar tareas relacionadas con la gestión de clústeres Kubernetes, despliegues con Helm, integración con ArgoCD, y manejo de imágenes Docker. Está pensado para facilitar la configuración y administración de entornos de desarrollo y producción.

## Requisitos Previos

Antes de usar este repositorio, asegúrate de tener instaladas las siguientes herramientas:

- **Docker CLI**: Para construir y publicar imágenes Docker.
- **kubectl**: Para interactuar con clústeres Kubernetes.
- **Helm**: Para gestionar despliegues de Helm charts.
- **ArgoCD CLI**: Para gestionar aplicaciones en ArgoCD.
- **Minikube (opcional)**: Para ejecutar un clúster Kubernetes local.

Todas estas herramientas están preinstaladas y disponibles en el contenedor de desarrollo.

## Estructura del Repositorio

El repositorio está organizado de la siguiente manera:

```
repo-makefile/
├── Makefile                # Archivo principal que incluye los módulos
├── makefiles/              # Directorio con los Makefiles modulares
│   ├── dependencies.mk     # Verificación de dependencias
│   ├── kind.mk             # Gestión de clústeres Kind
│   ├── argocd.mk           # Gestión de aplicaciones ArgoCD
│   ├── docker.mk           # Construcción y publicación de imágenes Docker
│   ├── helm.mk             # Despliegue y eliminación de Helm charts
└── scripts/                # Scripts auxiliares
```

### Cambios realizados:
1. Asegúrate de que el bloque de código esté encerrado entre tres backticks (\`\`\`) antes y después de la estructura.
2. Elimina cualquier formato adicional que pueda interferir con la visualización del bloque.

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

Este proyecto está bajo la licencia [MIT](LICENSE).

---

¡Gracias por usar este repositorio! Si tienes alguna pregunta, no dudes en contactarnos.
````