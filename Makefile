# === Makefile for Full-Stack Project ===

# ==============================
# 🐳 Docker Compose Section
# ==============================

.PHONY: up down build restart logs frontend backend

up:
	docker-compose up --build

down:
	docker-compose down

build:
	docker-compose build

restart:
	docker-compose down && docker-compose up --build

logs:
	docker-compose logs -f

frontend:
	docker-compose up --build frontend

backend:
	docker-compose up --build backend

# ==============================
# ☸️ Kubernetes Section
# ==============================

.PHONY: apply-mongo apply-backend apply-frontend apply-ingress apply-all delete-all k8s-status logs-backend logs-frontend

apply-mongo:
	kubectl apply -f k8s/mongo/
	-kubectl get pods,svc

apply-backend:
	kubectl apply -f k8s/backend/
	-kubectl get pods,svc

apply-frontend:
	kubectl apply -f k8s/frontend/
	-kubectl get pods,svc

apply-ingress:
	kubectl apply -f k8s/ingress/
	-kubectl get pods,svc,ingress

apply-all: apply-mongo apply-backend apply-frontend apply-ingress

delete-all:
	-kubectl delete -f k8s/ingress/
	-kubectl delete -f k8s/frontend/
	-kubectl delete -f k8s/backend/
	-kubectl delete -f k8s/mongo/

restart-all:
	kubectl rollout restart deployment

k8s-status:
	kubectl get pods,svc,ingress

logs-backend:
	kubectl logs -l app=backend --tail=100 -f

logs-frontend:
	kubectl logs -l app=frontend --tail=100 -f

# ==============================
# 🎯 Helm Section
# ==============================

HELM_RELEASE := fullstack
HELM_CHART_PATH := ./charts/fullstack

.PHONY: helm-install helm-upgrade helm-uninstall helm-lint helm-status helm-rollback helm-upgrade-lint check-helm

check-helm:
	@helm version >NUL 2>&1 || (echo Helm is not installed. Please install it: https://helm.sh/docs/intro/install/ & exit 1)

helm-install: check-helm
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART_PATH)

helm-upgrade: check-helm
	helm upgrade $(HELM_RELEASE) $(HELM_CHART_PATH)

helm-lint: check-helm
	helm lint $(HELM_CHART_PATH)

helm-uninstall: check-helm
	helm uninstall $(HELM_RELEASE)

helm-status: check-helm
	helm status $(HELM_RELEASE)

helm-rollback: check-helm
	helm rollback $(HELM_RELEASE)

helm-upgrade-lint: helm-lint helm-upgrade

# ==============================
# 🚀 Argo CD Section
# ==============================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login argo-password check-argocd

# Check if ArgoCD CLI is installed
check-argocd:
	@argocd version >NUL 2>&1 || (echo ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/ & exit 1)

# Apply ArgoCD Application manifest
argo-apply:
	kubectl apply -f argo/argo-fullstack-app.yaml

# Delete ArgoCD Application
argo-delete:
	kubectl delete -f argo/argo-fullstack-app.yaml || true

# Get ArgoCD Application status
argo-status:
	kubectl get applications.argoproj.io -n argocd

# Sync Application via ArgoCD CLI
argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

# Login to ArgoCD
argo-login: check-argocd
	argocd login localhost:8080 --username admin --password $$(make argo-password) --insecure --grpc-web

# Apply ArgoCD applications for dev environment
argo-dev:
	kubectl apply -f argo/argo-app-dev.yaml

# Apply ArgoCD applications for staging environment
argo-staging:
	kubectl apply -f argo/argo-app-staging.yaml

# Apply ArgoCD application for production environment
argo-prod:
	kubectl apply -f argo/argo-app-prod.yaml


# Extract ArgoCD admin password (PowerShell compatible)
argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

# ==============================
# 🔁 Rebuild Containers (Kubernetes)
# ==============================

.PHONY: rebuild-backend rebuild-frontend rebuild-all

rebuild-backend:
	docker build -t fastapi-backend:latest -f backend/Dockerfile.dev ./backend
	kubectl rollout restart deployment/backend

rebuild-frontend:
	docker build -t nextjs-frontend:latest -f frontend/Dockerfile.dev ./frontend
	kubectl rollout restart deployment/frontend

rebuild-all: rebuild-backend rebuild-frontend

# ==============================
# 🧭 Help
# ==============================

.PHONY: help

help:
	@echo:
	@echo == Docker Compose Commands ==
	@echo   make up               - Start all Docker services
	@echo   make down             - Stop all Docker containers
	@echo   make build            - Rebuild Docker images
	@echo   make restart          - Restart all containers
	@echo   make logs             - View Docker logs
	@echo   make frontend         - Start only frontend
	@echo   make backend          - Start only backend
	@echo:
	@echo == Kubernetes Commands ==
	@echo   make apply-mongo      - Apply MongoDB k8s resources
	@echo   make apply-backend    - Apply FastAPI backend
	@echo   make apply-frontend   - Apply frontend
	@echo   make apply-ingress    - Apply Ingress routing
	@echo   make apply-all        - Apply all resources
	@echo   make delete-all       - Delete all k8s resources
	@echo   make restart-all      - Restart all deployments	
	@echo   make k8s-status       - Show status of pods, services, ingress
	@echo   make logs-backend     - Tail backend pod logs
	@echo   make logs-frontend    - Tail frontend pod logs
	@echo:
	@echo == Helm Commands ==
	@echo   make helm-install         - Install or upgrade Helm release
	@echo   make helm-upgrade         - Upgrade Helm release
	@echo   make helm-upgrade-lint    - Lint and upgrade Helm release
	@echo   make helm-lint            - Check Helm chart structure
	@echo   make helm-uninstall       - Uninstall Helm release
	@echo   make helm-status          - Show Helm release status
	@echo   make helm-rollback        - Rollback to previous Helm revision
	@echo:
	@echo == Argo CD Commands ==
	@echo   make argo-apply        - Apply ArgoCD application manifest
	@echo   make argo-delete       - Delete ArgoCD application
	@echo   make argo-status       - Show ArgoCD application status
	@echo   make argo-sync         - Force ArgoCD sync (requires CLI)
	@echo   make argo-login        - Login to ArgoCD using CLI
	@echo   make argo-password     - Extract initial admin password (PowerShell-compatible)
	@echo:
	@echo == Rebuild Commands ==
	@echo   make rebuild-backend      - Rebuild and restart FastAPI backend
	@echo   make rebuild-frontend     - Rebuild and restart Next.js frontend
	@echo   make rebuild-all          - Rebuild and restart both frontend & backend