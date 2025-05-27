# ============================================
# Helm Section for Full-Stack Kubernetes Project
# ============================================

HELM_RELEASE := fullstack
ENV := dev
HELM_CHART_PATH := ./charts/fullstack

.PHONY: check-helm helm-install helm-upgrade helm-uninstall helm-lint helm-status helm-rollback helm-upgrade-lint \
        helm-monitoring helm-reset helm-test helm-help

# Detect null device path for Helm CLI check
NULL := $(if $(findstring Windows,$(OS)),NUL,/dev/null)

# Check if Helm CLI is installed
check-helm:
	@echo "Checking Helm CLI version..."
	@helm version || (echo Helm is not installed. Please install it: https://helm.sh/docs/intro/install/ && exit 1)

# Install or upgrade the main Helm release
helm-install: check-helm
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART_PATH)

# Deploy the Dev environment
helm-upgrade: check-helm check-ingress
	@echo "Deploying Helm release for DEV environment..."
	helm upgrade --install $(HELM_RELEASE)-$(ENV) $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-$(ENV).yaml

# Lint the Helm chart
helm-lint: check-helm
	helm lint $(HELM_CHART_PATH)

# Uninstall the Helm release
helm-uninstall: check-helm
	helm uninstall $(HELM_RELEASE)-$(ENV) 

# Show status of the Helm release
helm-status: check-helm
	helm status $(HELM_RELEASE)-$(ENV) 

# Roll back to the previous revision
helm-rollback: check-helm
	helm rollback $(HELM_RELEASE)-$(ENV) 

# Lint and then upgrade the Helm release
helm-upgrade-lint: helm-lint helm-upgrade

# ============================================
# Dev Environment Reset and Test
# ============================================

# Uninstall, clean up Ingress, reinstall and run Helm tests
helm-reset:
	@echo "Uninstalling existing Helm release..."
	-helm uninstall $(HELM_RELEASE)-$(ENV)  || true

	@echo "Deleting existing Ingress (if any)..."
	kubectl delete ingress fullstack-ingress -n dev --ignore-not-found

	@echo "Installing Helm release..."
	helm upgrade --install $(HELM_RELEASE)-$(ENV) $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-$(ENV).yaml

	@echo "Running Helm tests..."
	helm test $(HELM_RELEASE)-$(ENV) --logs

# Run Helm test suite to validate resources
helm-test:
	@echo "Running Helm tests for release: fullstack-$(ENV)..."
	helm test $(HELM_RELEASE)-$(ENV) --logs

# ============================================
# Monitoring Stack Deployment
# ============================================

# Install Prometheus + Grafana into monitoring namespace
helm-monitoring: check-helm
	helm upgrade --install monitoring charts/monitoring --namespace monitoring --create-namespace

# ============================================
# Helm Help
# ============================================

helm-help:
	@echo "== Helm Commands =="
	@echo "  make helm-install           - Install or upgrade the Helm release"
	@echo "  make helm-upgrade ENV=dev   - Upgrade Helm release for specific environment"
	@echo "  make helm-lint              - Lint the Helm chart"
	@echo "  make helm-uninstall ENV=dev - Uninstall the Helm release"
	@echo "  make helm-status ENV=dev    - Show Helm release status"
	@echo "  make helm-rollback ENV=dev  - Roll back Helm release"
	@echo "  make helm-upgrade-lint ENV=dev - Lint and upgrade"
	@echo "  make helm-reset ENV=dev     - Reset Helm release and run tests"
	@echo "  make helm-test ENV=dev      - Run Helm test suite"
	@echo "  make helm-monitoring        - Deploy monitoring stack"
	@echo "  make helm-help              - Show this help message"
