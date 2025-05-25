# === Makefile for Full-Stack Project ===

include make/docker.mk
include make/k8s.mk
include make/helm.mk
include make/argo.mk

.PHONY: grafana-password-gitbash
# ==============================
grafana-password-gitbash:
	@kubectl get secret -n monitoring kube-monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

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
	@echo == Helm Environment Commands ==
	@echo   make helm-dev             - Deploy Dev environment with Helm
	@echo   make helm-staging         - Deploy Staging environment with Helm
	@echo   make helm-prod            - Deploy Production environment with

	@echo:
	@echo == Argo CD Commands ==
	@echo   make argo-apply ENV=dev 	- Apply ArgoCD application manifest
	@echo   make argo-delete ENV=dev	- Delete ArgoCD application
	@echo   make argo-status       		- Show ArgoCD application status
	@echo   make argo-sync         		- Force ArgoCD sync (requires CLI)
	@echo   make argo-login        		- Login to ArgoCD using CLI
	@echo   make argo-password     		- Extract initial admin password (PowerShell-compatible)
	@echo:
	@echo == Rebuild Commands ==
	@echo   make rebuild-backend      	- Rebuild and restart FastAPI backend
	@echo   make rebuild-frontend     	- Rebuild and restart Next.js frontend
	@echo   make rebuild-all          	- Rebuild and restart both frontend & backend
