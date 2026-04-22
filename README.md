# kubedev

A local Kubernetes development environment that sets up a production-like cluster on your machine using [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker) with full GitOps, monitoring, and ingress.

## Overview

kubedev provisions a multi-node Kind cluster and installs a complete stack of cluster components managed via ArgoCD. All components are declared in this repository and automatically synced through GitOps.

**Cluster topology:** 1 control-plane + 3 worker nodes

**Component stack:**

| Component | Version | Purpose |
|-----------|---------|---------|
| [Cilium](https://cilium.io/) | 1.19.1 | CNI + L2 LoadBalancer |
| [HAProxy Ingress](https://haproxy-ingress.github.io/) | 1.44.0 | Ingress controller |
| [cert-manager](https://cert-manager.io/) | 1.20.2 | TLS certificate management |
| [ArgoCD](https://argo-cd.readthedocs.io/) | 9.5.3 | GitOps continuous deployment |
| [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts) | 83.7.0 | Prometheus + Grafana + AlertManager |

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [Nix](https://nixos.org/download/) with flakes enabled (recommended), or manually install: `kubectl`, `helm`, `kind`, `go-task`, `cilium-cli`, `k9s`

With Nix and [direnv](https://direnv.net/), the development environment loads automatically when you enter the directory.

## Getting Started

### Full setup

```bash
direnv allow
task
```

This creates the Kind cluster and installs all components. Equivalent to:

```bash
task create && task install
```

### Step by step

```bash
# Create the Kind cluster and Docker network
task create

# Bootstrap Cilium CNI (required before other components)
task bootstrap

# Install all controllers and deploy services via ArgoCD
task install
```

### Teardown

```bash
task delete
```

## Accessing Services

All services use [nip.io](https://nip.io/) for local DNS resolution with self-signed TLS certificates.

| Service | URL |
|---------|-----|
| ArgoCD | `https://argocd.172.19.0.50.nip.io` |
| Grafana | `https://grafana.172.19.0.50.nip.io` |

**ArgoCD initial password:**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Network Configuration

Cilium provides L2 load balancer announcements on the `172.19.0.0/16` Docker bridge network.

- LoadBalancer IP pool: `172.19.0.50 – 172.19.0.55`
- HAProxy ingress: fixed at `172.19.0.50`

## Adding a Service

Services are auto-discovered by ArgoCD via an ApplicationSet that watches `services/*/service.yaml`.

1. Create a directory under `services/<service-name>/`
2. Add a `service.yaml` (ArgoCD Application manifest)
3. Add a `values.yaml` for Helm configuration
4. Optionally add static manifests under `manifests/`

ArgoCD will automatically pick up and sync the new service on the next poll.

## Repository Structure

```
kubedev/
├── Taskfile.yaml          # Task automation (go-task)
├── flake.nix              # Nix dev environment
├── kind/
│   └── default.yaml       # Kind cluster config
├── argocd/
│   ├── argocd.yaml        # ArgoCD self-managed Application
│   └── services.yaml      # ApplicationSet for service discovery
└── services/
    ├── argocd/
    ├── cilium/
    ├── cert-manager/
    ├── haproxy-controller/
    └── monitoring/
```
