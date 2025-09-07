.PHONY: validate-env local prod build-local build-prod deploy-local-k8s deploy-prod up-local down-local test help

validate-env:
	@if [ -z "$$APP_HOST" ]; then \
		echo "❌ APP_HOST is not set in .env"; \
		exit 1; \
	fi

local: validate-env build-local up-local

prod: build-prod

build-local:
	@./scripts/build-image-local.sh

build-prod:
	@./scripts/build-image-prod.sh

up-local:
	docker compose -f compose/local/docker-compose.yml up -d

down-local:
	docker compose -f compose/local/docker-compose.yml down

deploy-local-k8s:
	kustomize build k8s/overlays/local | kubectl apply -f -

deploy-prod:
	@./scripts/deploy.sh prod

test:
	./scripts/db-wait.sh
	docker compose -f compose/local/docker-compose.yml exec app php artisan test
	./tests/integration/health.test.sh

help:  ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

