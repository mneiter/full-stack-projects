
# ==============================
# ☸️ Kubernetes Section
# ==============================

.PHONY: check-health apply-mongo apply-backend apply-frontend apply-ingress apply-all delete-all k8s-status logs-backend logs-frontend

# ==============================
# 🔍 Check Kubernetes resource health
# ==============================

.PHONY: check-health

# Show status of all resources in the given namespace (default: dev)
check-health:
	@echo "🔍 Checking health of resources in namespace: $${NAMESPACE:-dev}..."
	@kubectl get all -n $${NAMESPACE:-dev}
	@echo
	@echo "🧪 Describing pods (showing problems if any):"
	@kubectl get pods -n $${NAMESPACE:-dev} -o name | while read pod; do \
		echo "\n--- $$pod ---"; \
		kubectl describe $$pod -n $${NAMESPACE:-dev} | grep -A 5 "Events:" || true; \
	done

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
# 🌐 Ingress Controller Management
# ==============================

.PHONY: ingress-install ingress-uninstall ingress-proxy ingress-status ingress-check

# Install NGINX Ingress Controller via Helm
ingress-install:
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm repo update
	@helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		--namespace ingress-nginx --create-namespace

# Uninstall NGINX Ingress Controller
ingress-uninstall:
	@helm uninstall ingress-nginx -n ingress-nginx || true
	@kubectl delete namespace ingress-nginx --ignore-not-found

# Port-forward to access ingress locally (for http://localhost:8080)
ingress-proxy:
	@echo "🔁 Starting local port forward to ingress-nginx (localhost:8080)"
	kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Show Ingress controller status
ingress-status:
	kubectl get pods -n ingress-nginx

ingress-check:
	@echo "\n🌍 Ingress status:" && kubectl get ingress -n dev
	@echo "\n🔎 Describing ingress:" && kubectl describe ingress fullstack-ingress -n dev
	@echo "\n🌐 Curl test frontend:" && curl -i http://localhost:8080/
	@echo "\n🧪 Curl test backend:" && curl -i http://localhost:8080/api/tasks || echo "❌ Backend failed"

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