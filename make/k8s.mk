# ============================================
# Kubernetes Section (Git Bash Compatible)
# ============================================

.PHONY: check-health apply-mongo apply-backend apply-frontend apply-ingress \
        apply-all delete-all restart-all k8s-status logs-backend logs-frontend \
        rebuild-backend rebuild-frontend rebuild-all k8s-help

# Check health of all resources in the given namespace (default: dev)
check-health:
	@echo "Checking health of resources in namespace: $${NAMESPACE:-dev}..."
	@kubectl get all -n $${NAMESPACE:-dev}
	@echo ""
	@echo "Describing pods (showing recent events):"
	@kubectl get pods -n $${NAMESPACE:-dev} -o name | while read pod; do \
		echo "\n--- $$pod ---"; \
		kubectl describe $$pod -n $${NAMESPACE:-dev} | grep -A 5 "Events:" || true; \
	done

# Apply MongoDB manifests
apply-mongo:
	kubectl apply -f k8s/mongo/
	-kubectl get pods,svc

# Apply backend manifests
apply-backend:
	kubectl apply -f k8s/backend/
	-kubectl get pods,svc

# Apply frontend manifests
apply-frontend:
	kubectl apply -f k8s/frontend/
	-kubectl get pods,svc

# Apply ingress manifests
apply-ingress:
	kubectl apply -f k8s/ingress/
	-kubectl get pods,svc,ingress

# Apply all Kubernetes manifests
apply-all: apply-mongo apply-backend apply-frontend apply-ingress

# Delete all applied Kubernetes resources
delete-all:
	-kubectl delete -f k8s/ingress/
	-kubectl delete -f k8s/frontend/
	-kubectl delete -f k8s/backend/
	-kubectl delete -f k8s/mongo/

# Restart all deployments (useful after image rebuild)
restart-all:
	kubectl rollout restart deployment

# Show status of pods, services, and ingresses
k8s-status:
	kubectl get pods,svc,ingress

# Tail logs from backend pods
logs-backend:
	kubectl logs -l app=backend --tail=100 -f

# Tail logs from frontend pods
logs-frontend:
	kubectl logs -l app=frontend --tail=100 -f

# ============================================
# Rebuild and Restart (Kubernetes Deployments)
# ============================================

# Rebuild backend image and restart backend deployment
rebuild-backend:
	docker build -t fastapi-backend:latest -f backend/Dockerfile.dev ./backend
	kubectl rollout restart deployment/backend

# Rebuild frontend image and restart frontend deployment
rebuild-frontend:
	docker build -t nextjs-frontend:latest -f frontend/Dockerfile.dev ./frontend
	kubectl rollout restart deployment/frontend

# Rebuild and restart both frontend and backend
rebuild-all: rebuild-backend rebuild-frontend

# ============================================
# Kubernetes Help
# ============================================

k8s-help:
	@echo ""
	@echo "Kubernetes Commands:"
	@echo "  make apply-mongo          - Apply MongoDB resources"
	@echo "  make apply-backend        - Apply backend resources"
	@echo "  make apply-frontend       - Apply frontend resources"
	@echo "  make apply-ingress        - Apply ingress resources"
	@echo "  make apply-all            - Apply all resources"
	@echo "  make delete-all           - Delete all applied resources"
	@echo "  make restart-all          - Restart all deployments"
	@echo "  make k8s-status           - Show status of all k8s resources"
	@echo "  make check-health         - Check health of all pods in 'dev' namespace"
	@echo "  make logs-backend         - Tail logs from backend pods"
	@echo "  make logs-frontend        - Tail logs from frontend pods"
	@echo "  make rebuild-backend      - Rebuild and restart backend container"
	@echo "  make rebuild-frontend     - Rebuild and restart frontend container"
	@echo "  make rebuild-all          - Rebuild both frontend and backend"
	@echo "  k8s-help				   - Show this help menu"
	@echo ""

