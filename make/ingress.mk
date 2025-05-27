
# ==============================
# 🌐 Ingress Controller Management
# ==============================

.PHONY: ingress-install ingress-uninstall ingress-proxy ingress-status ingress-check

# Install NGINX Ingress Controller via Helm
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

.PHONY: check-ingress

check-ingress:
	@kubectl get pods -n ingress-nginx > /dev/null 2>&1 || \
	(	echo 	"Ingress Controller not found in namespace 'ingress-nginx'." && \
		echo 	"Run: make ingress-install" && exit 1)
