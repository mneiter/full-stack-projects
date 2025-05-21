# === Makefile for Full-Stack Project ===

# ==============================
# 🐳 Docker Compose Section
# ==============================

.PHONY: up down build restart logs frontend backend

# Build and start all services (frontend, backend, mongo)
up:
	docker-compose up --build

# Stop all containers
down:
	docker-compose down

# Rebuild images without starting
build:
	docker-compose build

# Restart services with rebuild
restart:
	docker-compose down && docker-compose up --build

# Show all container logs
logs:
	docker-compose logs -f

# Start only the frontend service
frontend:
	docker-compose up --build frontend

# Start only the backend service
backend:
	docker-compose up --build backend

# ==============================
# ☸️ Kubernetes Section
# ==============================

.PHONY: apply-mongo apply-backend apply-frontend apply-ingress apply-all delete-all k8s-status logs-backend logs-frontend

# Apply MongoDB Deployment & Service
apply-mongo:
	kubectl apply -f k8s/mongo/
	kubectl get pods,svc

# Apply FastAPI Deployment & Service
apply-backend:
	kubectl apply -f k8s/backend/
	kubectl get pods,svc

# Apply Next.js Deployment & Service
apply-frontend:
	kubectl apply -f k8s/frontend/
	kubectl get pods,svc

# Apply Ingress configuration
apply-ingress:
	kubectl apply -f k8s/ingress/
	kubectl get pods,svc,ingress

# Apply all Kubernetes resources
apply-all: apply-mongo apply-backend apply-frontend apply-ingress

# Delete all Kubernetes resources (safe)
delete-all:
	kubectl delete -f k8s/ingress/ || true
	kubectl delete -f k8s/frontend/ || true
	kubectl delete -f k8s/backend/ || true
	kubectl delete -f k8s/mongo/ || true

# Show cluster status
k8s-status:
	kubectl get pods,svc,ingress

# Show backend logs
logs-backend:
	kubectl logs -l app=backend --tail=100 -f

# Show frontend logs
logs-frontend:
	kubectl logs -l app=frontend --tail=100 -f

# ==============================
# 🧭 Help
# ==============================

.PHONY: help

help:
	@echo ""
	@echo "== Docker Compose Commands =="
	@echo "  make up           - Start all Docker services"
	@echo "  make down         - Stop all Docker containers"
	@echo "  make build        - Rebuild Docker images"
	@echo "  make restart      - Restart all containers"
	@echo "  make logs         - View Docker logs"
	@echo "  make frontend     - Start only frontend"
	@echo "  make backend      - Start only backend"
	@echo ""
	@echo "== Kubernetes Commands =="
	@echo "  make apply-mongo      - Apply MongoDB k8s resources"
	@echo "  make apply-backend    - Apply FastAPI backend"
	@echo "  make apply-frontend   - Apply frontend"
	@echo "  make apply-ingress    - Apply Ingress routing"
	@echo "  make apply-all        - Apply all resources"
	@echo "  make delete-all       - Delete all k8s resources"
	@echo "  make k8s-status       - Show status of pods, services, ingress"
	@echo "  make logs-backend     - Tail backend pod logs"
	@echo "  make logs-frontend    - Tail frontend pod logs"
	@echo ""
