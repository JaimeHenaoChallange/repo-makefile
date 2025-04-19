# Use bash as the shell
SHELL := /bin/bash

# Configuración global
SCRIPT_PATH := ./scripts/create-app.sh

# Crear aplicaciones específicas
create-backend:
	$(SCRIPT_PATH) backend $(PROJECT_NAME) backend

create-frontend:
	$(SCRIPT_PATH) frontend $(PROJECT_NAME) frontend

create-backend-1:
	$(SCRIPT_PATH) backend-1 $(PROJECT_NAME) backend-1

create-app-1:
	$(SCRIPT_PATH) app-1 $(PROJECT_NAME) app-1

create-app-2:
	$(SCRIPT_PATH) app-2 $(PROJECT_NAME) app-2

create-kubeops:
	$(SCRIPT_PATH) kubeops $(PROJECT_NAME) kubeops

create-database:
	$(SCRIPT_PATH) database $(PROJECT_NAME) database

create-redis:
	$(SCRIPT_PATH) redis $(PROJECT_NAME) redis