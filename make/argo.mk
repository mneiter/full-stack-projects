# ==============================
# 🚀 Argo CD Section
# ==============================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login argo-password init-namespaces argo-env argo-dev argo-staging argo-prod check-argocd argo-proxy

# Create Kubernetes namespaces for all environments
init-namespaces:
	kubectl apply -f argo/namespaces.yaml

# Check if ArgoCD CLI is installed
check-argocd:
	@argocd version >NUL 2>&1 || (echo ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/ & exit 1)

# Apply ArgoCD application manifest for specific environment (PowerShell compatible)
argo-apply:
	@if not defined ENV ( \
		echo Please provide an environment: make argo-env ENV=dev \
	) else ( \
		kubectl apply -f argo/argo-app-$(ENV).yaml \
	)

# Delete ArgoCD application for a specific environment
argo-delete:
	@if not defined ENV ( \
		echo Please provide an environment: make argo-env ENV=dev \
	) else ( \
		kubectl delete -f argo/argo-app-$(ENV).yaml || true \
	)

# Display the current status of all ArgoCD applications
argo-status:
	kubectl get applications.argoproj.io -n argocd

# Synchronize the ArgoCD application from CLI
argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

# Log in to ArgoCD using the initial admin password
argo-login: check-argocd
	argocd login localhost:8080 --username admin --password $$(make argo-password) --insecure --grpc-web

