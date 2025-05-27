# ==============================
# 🎯 Helm Section
# ==============================

HELM_RELEASE := fullstack-dev
HELM_CHART_PATH := ./charts/fullstack

.PHONY: check-helm helm-install helm-upgrade helm-uninstall helm-lint helm-status helm-rollback helm-upgrade-lint \
        helm-dev helm-staging helm-prod helm-monitoring

# Check if Helm CLI is installed
NULL := $(if $(findstring Windows,$(OS)),NUL,/dev/null)

check-helm:
	@echo "Checking Helm CLI version..."
	@helm version || (echo Helm is not installed. Please install it: https://helm.sh/docs/intro/install/ & exit 1)

# Install or upgrade the main Helm release
helm-install: check-helm
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART_PATH)

# Upgrade only (no install fallback)
helm-upgrade: check-helm
	helm upgrade $(HELM_RELEASE) $(HELM_CHART_PATH)

# Lint the Helm chart for errors and warnings
helm-lint: check-helm
	helm lint $(HELM_CHART_PATH)

# Uninstall the Helm release
helm-uninstall: check-helm
	helm uninstall $(HELM_RELEASE)

# Show the status of the Helm release
helm-status: check-helm
	helm status $(HELM_RELEASE)

# Roll back to the previous revision
helm-rollback: check-helm
	helm rollback $(HELM_RELEASE)

# Lint and then upgrade the Helm release
helm-upgrade-lint: helm-lint helm-upgrade

# ==============================
# 🧪 Environment-specific Helm Deployments
# ==============================

# Deploy the Dev environment
helm-dev: check-helm check-ingress
	@echo "Deploying Helm release for DEV environment..."
	helm upgrade --install fullstack-dev ./charts/fullstack -f ./charts/fullstack/values-dev.yaml

# Deploy the Staging environment
helm-staging: check-helm
	helm upgrade --install fullstack-staging $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-staging.yaml

# Deploy the Production environment
helm-prod: check-helm
	helm upgrade --install fullstack-prod $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-prod.yaml

.PHONY: helm-reset-dev

# Reset the fullstack Helm release: uninstall, delete conflicting ingress, reinstall, and run tests
helm-reset-dev:
	@echo "Uninstalling existing Helm release..."
	-helm uninstall fullstack-dev || true

	@echo "Deleting existing Ingress (if any)..."
	kubectl delete ingress fullstack-ingress -n dev --ignore-not-found

	@echo "Installing Helm release..."
	helm upgrade --install fullstack-dev ./charts/fullstack -f ./charts/fullstack/values-dev.yaml

	@echo "Running Helm tests..."
	helm test fullstack-dev --logs


.PHONY: helm-test

# Run Helm post-install tests for the release (backend, mongo, frontend healthchecks)
helm-test:
	@echo "Running Helm tests for release: fullstack-dev..."
	helm test fullstack-dev --logs


# ==============================
# 📊 Monitoring stack deployment
# ==============================

# Deploy Prometheus + Grafana to the monitoring namespace
helm-monitoring: check-helm
	helm upgrade --install monitoring charts/monitoring --namespace monitoring --create-namespace
