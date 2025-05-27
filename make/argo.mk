# ==============================
# Argo CD Section (Git Bash)
# ==============================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login init-namespaces argo-env argo-dev argo-staging argo-prod check-argocd

# Create Kubernetes namespaces for all environments
init-namespaces:
	kubectl apply -f argo/namespaces.yaml

# Check if ArgoCD CLI is installed
check-argocd:
	@echo "Checking Argo CD CLI version..."
	@command -v argocd >/dev/null 2>&1 || { echo "ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/"; exit 1; }
	@argocd version

# Apply ArgoCD application manifest for a specific environment
argo-apply:
	@if [ -z "$(ENV)" ]; then \
		echo "Please provide an environment: make argo-apply ENV=dev"; \
		exit 1; \
	else \
		kubectl apply -f argo/argo-app-$(ENV).yaml; \
	fi

# Delete ArgoCD application for a specific environment
argo-delete:
	@if [ -z "$(ENV)" ]; then \
		echo "Please provide an environment: make argo-delete ENV=dev"; \
		exit 1; \
	else \
		kubectl delete -f argo/argo-app-$(ENV).yaml || true; \
	fi

# Show ArgoCD application status
argo-status:
	kubectl get applications.argoproj.io -n argocd

# Sync application from CLI
argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

# Login to ArgoCD with initial admin password
argo-login: check-argocd
	argocd login localhost:8080 --username admin --password "$$(make argo-password)" --insecure --grpc-web
