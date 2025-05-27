# ============================================
# Ingress Controller Management (Git Bash Compatible)
# ============================================

.PHONY: ingress-install ingress-uninstall ingress-proxy ingress-status ingress-check \
        check-ingress ingress-help

# Install NGINX Ingress Controller using Helm
ingress-install:
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm repo update
	@helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		--namespace ingress-nginx --create-namespace \
		--set controller.ingressClassResource.name=nginx \
		--set controller.ingressClass=nginx \
		--set controller.watchIngressWithoutClass=true \
		--set controller.extraArgs.enable-ssl-passthrough=true \
		--set-string controller.config.rewrite-target="/"

# Uninstall the NGINX Ingress Controller and delete its namespace
ingress-uninstall:
	@helm uninstall ingress-nginx -n ingress-nginx || true
	@kubectl delete namespace ingress-nginx --ignore-not-found

# Start port-forward to access ingress via http://localhost:8080
ingress-proxy:
	@echo "Starting local port-forward to ingress-nginx (localhost:8080)..."
	kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Display all ingress-nginx controller pods
ingress-status:
	kubectl get pods -n ingress-nginx

# Perform full health check of Ingress and endpoints
ingress-check:
	@echo "\nIngress resources in 'dev' namespace:"
	kubectl get ingress -n dev
	@echo "\nDescribing 'fullstack-ingress':"
	kubectl describe ingress fullstack-ingress -n dev
	@echo "\nCurl test: frontend"
	@curl -i http://localhost:8080/ || echo "Frontend check failed"
	@echo "\nCurl test: backend"
	@curl -i http://localhost:8080/api/tasks || echo "Backend check failed"

# Ensure Ingress controller is running before applying ingress resources
check-ingress:
	@kubectl get pods -n ingress-nginx > /dev/null 2>&1 || { \
		echo "Ingress Controller not found in namespace 'ingress-nginx'."; \
		echo "Run: make ingress-install"; \
		exit 1; \
	}

# ============================================
# Ingress Help
# ============================================

ingress-help:
	@echo ""
	@echo "Ingress Commands:"
	@echo "  make ingress-install          - Install NGINX ingress controller"
	@echo "  make ingress-uninstall        - Uninstall ingress controller and delete namespace"
	@echo "  make ingress-status           - Show status of ingress pods"
	@echo "  make ingress-proxy            - Port forward ingress to localhost:8080"
	@echo "  make ingress-check            - Run basic ingress curl tests"
	@echo "  make check-ingress            - Ensure ingress controller is installed"
	@echo "  make ingress-help             - Show this help message"
	@echo ""