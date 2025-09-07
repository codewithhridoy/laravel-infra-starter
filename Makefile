.PHONY: local prod build-local build-prod deploy-local-k8s deploy-prod up-local down-local test validate-env help

# Get PROJECT_ROOT as absolute path of the directory containing this Makefile
PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

validate-env:
	@ENV_FILE=$(PROJECT_ROOT)/.env; \
	if [ ! -f "$$ENV_FILE" ]; then \
		echo "❌ .env not found at: $$ENV_FILE"; \
		echo "💡 Hint: Run 'cp .env.example .env' in project root"; \
		exit 1; \
	fi; \
	APP_HOST=$$(grep -E "^APP_HOST=" "$$ENV_FILE" | cut -d '=' -f2- | xargs); \
	if [ -z "$$APP_HOST" ]; then \
		echo "❌ APP_HOST is not set in .env"; \
		echo "💡 Example: APP_HOST=api.auth.abc.localhost.test"; \
		exit 1; \
	fi

local: validate-env build-local up-local

prod: build-prod

build-local:
	@$(PROJECT_ROOT)/scripts/build-image-local.sh

build-prod:
	@$(PROJECT_ROOT)/scripts/build-image-prod.sh

up-local: validate-env
	docker compose -f $(PROJECT_ROOT)/compose/local/docker-compose.yml up -d

down-local:
	docker compose -f $(PROJECT_ROOT)/compose/local/docker-compose.yml down

deploy-local-k8s:
	kustomize build $(PROJECT_ROOT)/k8s/overlays/local | kubectl apply -f -

deploy-prod: validate-env
	@$(PROJECT_ROOT)/scripts/deploy.sh prod

test: validate-env
	@$(PROJECT_ROOT)/scripts/db-wait.sh
	docker compose -f $(PROJECT_ROOT)/compose/local/docker-compose.yml exec app php artisan test
	@$(PROJECT_ROOT)/tests/integration/health.test.sh

help:                          ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


