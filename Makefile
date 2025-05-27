# ============================================
# 📦 Makefile for Full-Stack Kubernetes Project
# ============================================

include make/docker.mk
include make/k8s.mk
include make/git.mk
include make/helm.mk
include make/ingress.mk
include make/argo.mk

.PHONY: dev-tools

# Apply ArgoCD Ingress, start Grafana port-forwarding and Kubernetes dashboard proxy
dev-tools:
	@echo "Applying ArgoCD Ingress..."
	kubectl apply -f argo/argocd-ingress.yaml

	@echo "Starting port-forward to Grafana (localhost:3000)..."
	@nohup kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &

	@echo "Starting Kubernetes proxy (localhost:8001)..."
	@nohup kubectl proxy > /dev/null 2>&1 &

	@echo "✅ All dev tools started in background:"
	@echo "   - Grafana:     http://localhost:3000"
	@echo "   - K8s Dashboard: http://localhost:8001"


# ==============================
# 🚀 ArgoCD Access
# ==============================

.PHONY: argo-ingress argo-password

# Create an Ingress resource to expose the Argo CD web UI at https://argocd.localhost
argo-ingress:
	@echo "Creating Ingress for Argo CD..."
	kubectl apply -f argo/argocd-ingress.yaml
	@echo "Argo CD should now be accessible at: https://argocd.localhost"

# Get the ArgoCD initial admin password (PowerShell-compatible)
argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

.PHONY: grafana-proxy grafana-password-gitbash dashboard-proxy dashboard-token help

# ==============================
# 📊 Grafana Access
# ==============================

# Start a local port-forward to access Grafana UI at http://localhost:3000
grafana-proxy:
	kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

# Get Grafana admin password (for Git Bash or Linux/macOS)
grafana-password:
	@kubectl get secret -n monitoring kube-monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

# ==============================
# 📋 Kubernetes Dashboard Access
# ==============================

# Start proxy to access Kubernetes Dashboard at http://localhost:8001
dashboard-proxy:
	kubectl proxy

# Get token for Dashboard login from ServiceAccount secret
dashboard-token:
	@kubectl get secret dashboard-admin-sa-token -o go-template='{{.data.token | base64decode}}'

# ==============================
# 🧭 Help
# ==============================

help:
	@echo:
	@echo == Docker Compose Commands ==
	@echo   make up                    - Start all Docker services
	@echo   make down                  - Stop all Docker containers
	@echo   make build                 - Rebuild Docker images
	@echo   make restart               - Restart all containers
	@echo   make logs                  - View Docker logs
	@echo   make frontend              - Start only frontend
	@echo   make backend               - Start only backend
	@echo:
	@echo == Kubernetes Commands ==
	@echo   make apply-mongo           - Apply MongoDB k8s resources
	@echo   make apply-backend         - Apply FastAPI backend
	@echo   make apply-frontend        - Apply frontend
	@echo   make apply-ingress         - Apply Ingress routing
	@echo   make apply-all             - Apply all resources
	@echo   make delete-all            - Delete all k8s resources
	@echo   make restart-all           - Restart all deployments
	@echo   make k8s-status            - Show status of pods, services, ingress
	@echo   make logs-backend          - Tail backend pod logs
	@echo   make logs-frontend         - Tail frontend pod logs
	@echo:
	@echo == Helm Commands ==
	@echo   make helm-install          - Install or upgrade Helm release
	@echo   make helm-upgrade          - Upgrade Helm release
	@echo   make helm-upgrade-lint     - Lint and upgrade Helm release
	@echo   make helm-lint             - Check Helm chart structure
	@echo   make helm-uninstall        - Uninstall Helm release
	@echo   make helm-status           - Show Helm release status
	@echo   make helm-rollback         - Rollback to previous Helm revision
	@echo:
	@echo == Helm Environment Commands ==
	@echo   make helm-dev              - Deploy Dev environment with Helm
	@echo   make helm-staging          - Deploy Staging environment with Helm
	@echo   make helm-prod             - Deploy Production environment with Helm
	@echo:
	@echo == Argo CD Commands ==
	@echo   make argo-apply ENV=dev    - Apply ArgoCD application manifest
	@echo   make argo-delete ENV=dev   - Delete ArgoCD application
	@echo   make argo-status           - Show ArgoCD application status
	@echo   make argo-sync             - Force ArgoCD sync (requires CLI)
	@echo   make argo-login            - Login to ArgoCD using CLI
	@echo   make argo-password         - Extract initial admin password (PowerShell-compatible)
	@echo:
	@echo == Rebuild Commands ==
	@echo   make rebuild-backend       - Rebuild and restart FastAPI backend
	@echo   make rebuild-frontend      - Rebuild and restart Next.js frontend
	@echo   make rebuild-all           - Rebuild and restart both frontend & backend
