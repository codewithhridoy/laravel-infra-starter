# Deployment Guide — Laravel Microservices Infra

This infrastructure is designed to be reused across microservices via `git subtree`.

---

## 1. Integrate as Subtree

In your microservice repo:

```bash
git subtree add --prefix=infra https://github.com/yourorg/laravel-infra-starter main --squash
cp infra/.env.example .env
```
### Edit .env:
APP_URL=https://api.yourservice.yourcompany.com
DB_HOST=...

##  2. Local Development
```bash
# Generate local TLS certs
./infra/scripts/generate-certs-local.sh

# Build + start
make -f infra/Makefile local

# Visit: https://api.yourservice.localhost.test (or your APP_URL)
```

##  3. Deploy to Kubernetes

**Prerequisites**
- kubectl configured for target cluster
- kustomize installed
- Secrets created (see below)

**Deploy Manually**
```bash
# Build prod image
make -f infra/Makefile build-prod

# Deploy (reads .env)
make -f infra/Makefile deploy-prod
```

##  4. CI/CD — GitHub Actions

This repo includes workflows:

- deploy-staging.yml → auto-deploy from release/* or main
- deploy-prod.yml → manual approval required

**Setup Secrets in GitHub**
In your microservice repo → Settings → Secrets and variables → Actions:

GHCR_TOKEN -> GitHub PAT with `write:packages`
STAGING_KUBECONFIG -> Base64 of kubeconfig for staging
PROD_KUBECONFIG -> Base64 of kubeconfig for prod
SLACK_WEBHOOK -> Optional — for notifications

**Create GitHub Environments**
- Go to repo → Settings → Environments
- Create staging → no approval
- Create production → require 1+ reviewer

##  5. Managing Secrets
Never commit secrets.

**For Local:**
Use .env (gitignored)

**For Kubernetes:**
Use SealedSecrets:
```bash
# Install sealed-secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/controller.yaml

# Create secret locally
echo -n 'your-app-key' > ./app-key.txt
kubectl create secret generic app-secrets \
  --from-file=APP_KEY=./app-key.txt \
  --from-literal=DB_PASSWORD=your-db-pass \
  --dry-run=client -o yaml > secrets-clear.yaml

# Seal it
kubeseal --format=yaml < secrets-clear.yaml > k8s/values/prod-sealed-secrets.yaml

# Commit prod-sealed-secrets.yaml
git add k8s/values/prod-sealed-secrets.yaml
```
→ Update `k8s/overlays/prod/kustomization.yaml`:
```bash
resources:
  - ../../base/...
  - ../../../values/prod-sealed-secrets.yaml  # ← sealed secret  
```
## 6. Health-checks & Rollback
All deployments:

- Wait for rollout
- Hit /health endpoint
- Auto-rollback if fails
- 
Override healthcheck URL in `.env`:
```dotenv
HEALTHCHECK_PATH=/api/v1/health
```
→ Update `scripts/deploy.sh` to use `$HEALTHCHECK_PATH`

## 7. Observability
**Logging**
All containers log JSON to stdout → ship to Loki with Promtail.

**Metrics**
Laravel app exposes `/metrics` → scrape with Prometheus.

Add to `app/Providers/AppServiceProvider.php`:
```php
use Prometheus\Storage\Redis;
use Prometheus\CollectorRegistry;

// In register():
if ($this->app->environment('production')) {
    $adapter = new Redis(['host' => env('REDIS_HOST')]);
    $registry = new CollectorRegistry($adapter);
    $this->app->instance(CollectorRegistry::class, $registry);
}
```

## 8. Emergency Rollback
```bash
kubectl -n production rollout undo deployment/laravel-app
```
Or via GitHub Actions → Re-run previous successful workflow.

## 9. Updating the Infra Subtree
To pull latest infra updates:
```bash
git subtree pull --prefix=infra https://github.com/yourorg/laravel-infra-starter main --squash
```
→ Test locally → deploy.


