# ==================================================
# Monitoring, ArgoCD, and Developer Tools Management
# ==================================================

.PHONY: check-kubectl dev-tools stop-dev-tools restart-dev-tools \
        argo-ingress argo-password prometheus-proxy grafana-proxy grafana-password \
        dashboard-proxy dashboard-token monitoring-help

# Ensure kubectl CLI is available
check-kubectl:
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found. Please install it: https://kubernetes.io/docs/tasks/tools/"; exit 1; }

# Start developer tools: ArgoCD ingress, Prometheus, Grafana, Kubernetes dashboard proxy
dev-tools: check-kubectl
	@echo "Applying ArgoCD Ingress..."
	kubectl apply -f argo/argocd-ingress.yaml

	@echo "Starting port-forward to Grafana (http://localhost:3000)..."
	nohup kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &

	@echo "Starting port-forward to Prometheus (http://localhost:9090)..."
	nohup kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80 > /dev/null 2>&1 &

	@echo "Starting Kubernetes proxy (http://localhost:8001)..."
	nohup kubectl proxy > /dev/null 2>&1 &

	@echo "All developer tools started in background:"
	@echo "   - Grafana:       http://localhost:3000"
	@echo "   - Prometheus:    http://localhost:9090"
	@echo "   - K8s Dashboard: http://localhost:8001"

# Stop background kubectl processes started by dev-tools
stop-dev-tools: check-kubectl
	@echo "Stopping background kubectl processes..."
	@ps -W | grep "[k]ubectl port-forward" | awk '{print $$1}' | xargs -r taskkill /F /PID
	@ps -W | grep "[k]ubectl proxy" | awk '{print $$1}' | xargs -r taskkill /F /PID
	@echo "All kubectl background processes stopped."

# Restart developer tools
restart-dev-tools: stop-dev-tools dev-tools
	@echo "Developer tools restarted successfully."

# --------------------------------------------
# ArgoCD Access
# --------------------------------------------

# Create an Ingress resource to expose ArgoCD web UI
argo-ingress:
	@echo "Creating Ingress for ArgoCD..."
	kubectl apply -f argo/argocd-ingress.yaml
	@echo "ArgoCD should now be accessible at: https://argocd.localhost"

# Get the ArgoCD initial admin password (PowerShell-compatible)
argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

# --------------------------------------------
# Prometheus Access
# --------------------------------------------

# Start a port-forward to Prometheus UI
prometheus-proxy:
	kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80

# --------------------------------------------
# Grafana Access
# --------------------------------------------

# Start a port-forward to Grafana UI
grafana-proxy:
	kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

# Get Grafana admin password (Git Bash compatible)
grafana-password:
	kubectl get secret -n monitoring kube-monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

# --------------------------------------------
# Kubernetes Dashboard Access
# --------------------------------------------

# Start Kubernetes proxy for dashboard access
dashboard-proxy:
	kubectl proxy

# Get login token for Kubernetes dashboard
dashboard-token:
	kubectl get secret dashboard-admin-sa-token -o go-template='{{.data.token | base64decode}}'

# --------------------------------------------
# ArgoCD Help
# --------------------------------------------

monitoring-help:
	@echo ""
	@echo "Available ArgoCD and Monitoring Commands:"
	@echo "  make dev-tools             - Start ArgoCD, Prometheus, Grafana, and Dashboard proxies"
	@echo "  make stop-dev-tools        - Stop background port-forward and proxy processes"
	@echo "  make restart-dev-tools     - Restart developer tool processes"
	@echo "  make argo-ingress          - Apply Ingress for ArgoCD web UI"
	@echo "  make argo-password         - Show ArgoCD initial admin password (PowerShell only)"
	@echo "  make prometheus-proxy      - Port-forward to Prometheus (localhost:9090)"
	@echo "  make grafana-proxy         - Port-forward to Grafana (localhost:3000)"
	@echo "  make grafana-password      - Show Grafana admin password"
	@echo "  make dashboard-proxy       - Start Kubernetes proxy (Dashboard)"
	@echo "  make dashboard-token       - Show login token for Kubernetes dashboard"
	@echo "  make monitoring-help       - Show this help message"
	@echo ""
