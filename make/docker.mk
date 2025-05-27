# ============================================
# Docker Compose Section (Git Bash Compatible)
# ============================================

.PHONY: up down build restart logs frontend backend docker-help

# Start all services with build
up:
	docker-compose up --build

# Stop all running services
down:
	docker-compose down

# Rebuild Docker images without starting
build:
	docker-compose build

# Restart all services (down + up --build)
restart:
	docker-compose down && docker-compose up --build

# Tail logs from all running services
logs:
	docker-compose logs -f

# Start only the frontend service
frontend:
	docker-compose up --build frontend

# Start only the backend service
backend:
	docker-compose up --build backend

# ============================================
# Docker Compose Help
# ============================================

docker-help:
	@echo ""
	@echo "Docker Compose Commands:"
	@echo "  make up              - Start all services with build"
	@echo "  make down            - Stop all running services"
	@echo "  make build           - Build Docker images only"
	@echo "  make restart         - Rebuild and restart all services"
	@echo "  make logs            - Tail logs from all services"
	@echo "  make frontend        - Start only the frontend service"
	@echo "  make backend         - Start only the backend service"
	@echo "  make docker-help     - Show this help message"
	@echo ""	