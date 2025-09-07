# Laravel Microservices Infrastructure Starter

Enterprise-grade, production-ready infrastructure for Laravel microservices.

- Local & Production parity  
- Driven by `APP_URL` — no hardcoded hosts  
- Separate Dockerfiles, Compose, K8s overlays  
- Observability (Prometheus, Loki, Tracing)  
- Security (Trivy, Gitleaks, NetworkPolicy)  
- GitOps-ready (Kustomize + ArgoCD)  
- Zero-downtime deployments

---

## Requirements

- Docker + Docker Compose
- mkcert (for local TLS)
- kubectl + kustomize (for K8s)
- PHP 8.2+ (for config validation)

---

## Quick Start

```bash
cp .env.example .env
# Edit APP_URL, DB_* etc.

make local          # Local dev with Traefik + HTTPS
make build-prod     # Build prod image
make deploy-prod    # Deploy to K8s (requires kubectl)

```
