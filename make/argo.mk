# ==============================
# 🚀 Argo CD Section
# ==============================

.PHONY: argo-apply argo-delete argo-status argo-sync argo-login argo-password init-namespaces argo-env argo-dev argo-staging argo-prod

check-argocd:
	@argocd version >NUL 2>&1 || (echo ArgoCD CLI not found. Install it: https://argo-cd.readthedocs.io/en/stable/cli_installation/ & exit 1)

argo-apply:
	kubectl apply -f argo/argo-fullstack-app.yaml

argo-delete:
	kubectl delete -f argo/argo-fullstack-app.yaml || true

argo-status:
	kubectl get applications.argoproj.io -n argocd

argo-sync: check-argocd
	argocd app sync fullstack --insecure --grpc-web

argo-login: check-argocd
	argocd login localhost:8080 --username admin --password $$(make argo-password) --insecure --grpc-web

argo-password:
	@powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}')))"

init-namespaces:
	kubectl apply -f argo/namespaces.yaml

argo-dev:
	kubectl apply -f argo/argo-app-dev.yaml

argo-staging:
	kubectl apply -f argo/argo-app-staging.yaml

argo-prod:
	kubectl apply -f argo/argo-app-prod.yaml
