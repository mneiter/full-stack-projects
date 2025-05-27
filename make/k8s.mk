
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