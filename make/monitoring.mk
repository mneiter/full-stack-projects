.PHONY: dev-tools argo-ingress argo-password prometheus-proxy grafana-proxy grafana-password dashboard-proxy dashboard-token argo-help

# --------------------------------------------
# Developer Tools Setup (ArgoCD, Grafana, Proxy)
# --------------------------------------------

# Apply ArgoCD Ingress, start Prometheus and Grafana port-forwarding, and start Kubernetes dashboard proxy
dev-tools:
	@echo "Applying ArgoCD Ingress..."
	nohup kubectl apply -f argo/argocd-ingress.yaml > /dev/null 2>&1 &

	@echo "Starting port-forward to Prometheus (http://localhost:9090)..."
	nohup kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80 > /dev/null 2>&1 &

	@echo "Starting port-forward to Grafana (http://localhost:3000)..."
	nohup kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &

	@echo "Starting Kubernetes proxy (http://localhost:8001)..."
	nohup kubectl proxy > /dev/null 2>&1 &

	@echo "All developer tools started in background:"
	@echo "   - ArgoCD:         https://argocd.localhost"
	@echo "   - Prometheus:     http://localhost:9090"
	@echo "   - Grafana:        http://localhost:3000"
	@echo "   - K8s Dashboard:  http://localhost:8001"


# --------------------------------------------
# ArgoCD Access
# --------------------------------------------

# Create an Ingress resource to expose ArgoCD web UI
argo-ingress:
	@echo "Creating Ingress for ArgoCD..."
	kubectl apply -f argo/argocd-ingress.yaml
	@echo "ArgoCD should now be accessible at: https://argocd.localhost"

# Get the ArgoCD initial admin password (PowerShell compatible)
argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

# --------------------------------------------
# Prometheus Access
# --------------------------------------------

# Start port-forward to access Prometheus UI at http://localhost:9090
prometheus-proxy:
	kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80

# --------------------------------------------
# Grafana Access
# --------------------------------------------

# Start a local port-forward to access Grafana UI
grafana-proxy:
	kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

# Get Grafana admin password (Git Bash compatible)
grafana-password:
	kubectl get secret -n monitoring kube-monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

# --------------------------------------------
# Kubernetes Dashboard Access
# --------------------------------------------

# Start Kubernetes proxy to access the dashboard
dashboard-proxy:
	kubectl proxy

# Get token to log into Kubernetes Dashboard
dashboard-token:
	kubectl get secret dashboard-admin-sa-token -o go-template='{{.data.token | base64decode}}'

# --------------------------------------------
# ArgoCD Help
# --------------------------------------------

argo-help:
	@echo ""
	@echo "Available ArgoCD-related commands:"
	@echo "  make dev-tools             - Start ArgoCD, Prometheus, Grafana and Dashboard tools"
	@echo "  make argo-ingress          - Apply ArgoCD Ingress resource"
	@echo "  make argo-password         - Show initial ArgoCD admin password (PowerShell only)"
	@echo "  make prometheus-proxy      - Port-forward to Prometheus UI (localhost:9090)"
	@echo "  make grafana-proxy         - Port-forward to Grafana UI (localhost:3000)"
	@echo "  make grafana-password      - Show Grafana admin password"
	@echo "  make dashboard-proxy       - Start Kubernetes proxy (Dashboard access)"
	@echo "  make dashboard-token       - Print login token for Kubernetes dashboard"
	@echo ""

