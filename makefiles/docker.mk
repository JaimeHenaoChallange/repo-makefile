# Construir imágenes Docker
build-backend:
	@echo "Construyendo imagen para backend..."
	if ! docker build -t $(BACKEND_IMAGE):$(IMAGE_TAG) ./backend/Docker/backend; then \
	    echo "Error: Falló la construcción de la imagen para backend."; \
	    exit 1; \
	fi

build-frontend:
	@echo "Construyendo imagen para frontend..."
	if ! docker build -t $(FRONTEND_IMAGE):$(IMAGE_TAG) ./frontend/Docker; then \
	    echo "Error: Falló la construcción de la imagen para frontend."; \
	    exit 1; \
	fi

build-database:
	@echo "Construyendo imagen para database..."
	if ! docker build -t $(DATABASE_IMAGE):$(IMAGE_TAG) ./backend/Docker/database; then \
	    echo "Error: Falló la construcción de la imagen para database."; \
	    exit 1; \
	fi

build-redis:
	@echo "Construyendo imagen para redis..."
	if ! docker build -t $(REDIS_IMAGE):$(IMAGE_TAG) ./backend/Docker/redis; then \
	    echo "Error: Falló la construcción de la imagen para redis."; \
	    exit 1; \
	fi

# Publicar imágenes Docker
push-backend:
	@echo "Publicando imagen para backend..."
	if ! docker push $(BACKEND_IMAGE):$(IMAGE_TAG); then \
	    echo "Error: Falló la publicación de la imagen para backend."; \
	    exit 1; \
	fi

push-frontend:
	@echo "Publicando imagen para frontend..."
	if ! docker push $(FRONTEND_IMAGE):$(IMAGE_TAG); then \
	    echo "Error: Falló la publicación de la imagen para frontend."; \
	    exit 1; \
	fi

push-database:
	@echo "Publicando imagen para database..."
	if ! docker push $(DATABASE_IMAGE):$(IMAGE_TAG); then \
	    echo "Error: Falló la publicación de la imagen para database."; \
	    exit 1; \
	fi

push-redis:
	@echo "Publicando imagen para redis..."
	if ! docker push $(REDIS_IMAGE):$(IMAGE_TAG); then \
	    echo "Error: Falló la publicación de la imagen para redis."; \
	    exit 1; \
	fi

# Construir y publicar todas las imágenes
build-all: build-backend build-frontend build-database build-redis
push-all: push-backend push-frontend push-database push-redis