# ==============================
# 🚀 Argo CD Section
# ==============================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login argo-password init-namespaces argo-env argo-dev argo-staging argo-prod check-argocd

# Check if ArgoCD CLI is installed
check-argocd:
	@argocd version >NUL 2>&1 || (echo ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/ & exit 1)

# Apply ArgoCD application manifest for specific environment (PowerShell compatible)
argo-apply-env:
	@if not defined ENV ( \
		echo Please provide an environment: make argo-env ENV=dev \
	) else ( \
		kubectl apply -f argo/argo-app-$(ENV).yaml \
	)

# Delete base application
argo-delete-env:
	@if not defined ENV ( \
		echo Please provide an environment: make argo-env ENV=dev \
	) else ( \
		kubectl delete -f argo/argo-app-$(ENV).yaml || true \
	)

# Show ArgoCD application status
argo-status:
	kubectl get applications.argoproj.io -n argocd

# Sync application from CLI
argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

# Login to ArgoCD with initial admin password
argo-login: check-argocd
	argocd login localhost:8080 --username admin --password $$(make argo-password) --insecure --grpc-web

# Get ArgoCD initial admin password (PowerShell-compatible)
argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

# Create Kubernetes namespaces for all environments
init-namespaces:
	kubectl apply -f argo/namespaces.yaml

	
