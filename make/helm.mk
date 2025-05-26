
# ==============================
# 🎯 Helm Section
# ==============================

HELM_RELEASE := fullstack-dev
HELM_CHART_PATH := ./charts/fullstack

.PHONY: helm-install helm-upgrade helm-uninstall helm-lint helm-status helm-rollback helm-upgrade-lint check-helm helm-monitoring

check-helm:
	@helm version >NUL 2>&1 || (echo Helm is not installed. Please install it: https://helm.sh/docs/intro/install/ & exit 1)

helm-install: check-helm
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART_PATH)

helm-upgrad: check-helm
	helm upgrade $(HELM_RELEASE) $(HELM_CHART_PATH)

helm-lint: check-helm
	helm lint $(HELM_CHART_PATH)

helm-uninstall: check-helm
	helm uninstall $(HELM_RELEASE)

helm-status: check-helm
	helm status $(HELM_RELEASE)

helm-rollback: check-helm
	helm rollback $(HELM_RELEASE)

helm-upgrade-lint: helm-lint helm-upgrade

.PHONY: helm-dev helm-staging helm-prod

helm-dev: check-helm
	helm upgrade --install fullstack-dev $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-dev.yaml

helm-staging: check-helm
	helm upgrade --install fullstack-staging $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-staging.yaml

helm-prod: check-helm
	helm upgrade --install fullstack-prod $(HELM_CHART_PATH) -f $(HELM_CHART_PATH)/values-prod.yaml

.PHONY: helm-monitoring

helm-monitoring:
	helm upgrade --install monitoring charts/monitoring --namespace monitoring --create-namespace


