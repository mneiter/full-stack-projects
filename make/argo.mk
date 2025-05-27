# ============================================
# Argo CD Section (Git Bash Compatible)
# ============================================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login argo-password \
        init-namespaces check-argocd argo-dev argo-staging argo-prod argo-help

# Create Kubernetes namespaces for all environments
init-namespaces:
	kubectl apply -f argo/namespaces.yaml

# Check if ArgoCD CLI is installed
check-argocd:
	@echo "Checking Argo CD CLI version..."
	@command -v argocd >/dev/null 2>&1 || { \
		echo "ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/"; \
		exit 1; \
	}
	@argocd version

# Apply ArgoCD application manifest for a specific environment
# Usage: make argo-apply ENV=dev
argo-apply:
	@if [ -z "$(ENV)" ]; then \
		echo "Please provide an environment: make argo-apply ENV=dev"; \
		exit 1; \
	else \
		kubectl apply -f argo/argo-app-$(ENV).yaml; \
	fi

# Delete ArgoCD application manifest for a specific environment
# Usage: make argo-delete ENV=dev
argo-delete:
	@if [ -z "$(ENV)" ]; then \
		echo "Please provide an environment: make argo-delete ENV=dev"; \
		exit 1; \
	else \
		kubectl delete -f argo/argo-app-$(ENV).yaml || true; \
	fi

# Show the current ArgoCD application status
argo-status:
	kubectl get applications.argoproj.io -n argocd

# Sync ArgoCD application manually
argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

# Login to ArgoCD using the admin credentials
argo-login: check-argocd
	argocd login localhost:8080 --username admin --password "$$(make argo-password)" --insecure --grpc-web

# Extract initial admin password from ArgoCD secret (Git Bash compatible)
argo-password:
	@kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode; echo

# ============================================
# Argo CD Help
# ============================================

argo-help:
	@echo ""
	@echo "ArgoCD Commands:"
	@echo "  make init-namespaces         - Create namespaces used by ArgoCD apps"
	@echo "  make check-argocd            - Check if ArgoCD CLI is installed"
	@echo "  make argo-apply ENV=dev      - Apply ArgoCD app manifest for environment"
	@echo "  make argo-delete ENV=dev     - Delete ArgoCD app manifest"
	@echo "  make argo-status             - Show ArgoCD application status"
	@echo "  make argo-sync               - Sync ArgoCD application (requires CLI)"
	@echo "  make argo-login              - Login to ArgoCD with initial password"
	@echo "  make argo-password           - Show initial admin password"
	@echo "  make argo-help               - Show this help menu"
	@echo ""