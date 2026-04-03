# OSW 2026 Workshop — Istio Multi-Cluster Service Mesh

A hands-on workshop demonstrating an Istio multi-cluster service mesh setup using local [kind](https://kind.sigs.k8s.io/) clusters, [MetalLB](https://metallb.universe.tf/) for load balancing, and the **Simple Buy** e-commerce sample application.

## Overview

This workshop walks through setting up two Kubernetes clusters (`cluster1` and `cluster2`) connected via an Istio east-west gateway, with a microservices application spanning both clusters. The `Product` service runs in `cluster2` while the rest of the application runs in `cluster1` — demonstrating cross-cluster service discovery through the shared service mesh.

## Architecture

```
cluster1 (port 8080)                    cluster2 (port 8081)
┌─────────────────────────────────┐    ┌─────────────────────────────┐
│  Istio Ingress Gateway          │    │                             │
│  ┌───────────────────────────┐  │    │  ┌──────────────────────┐  │
│  │  simple-buy namespace     │  │◄──►│  │  simple-buy namespace│  │
│  │  - frontend               │  │    │  │  - product service   │  │
│  │  - auth                   │  │    │  └──────────────────────┘  │
│  │  - cart                   │  │    │                             │
│  │  - order                  │  │    │  East-West Gateway          │
│  │  - notification           │  │    │  (cross-cluster mTLS)       │
│  │  - postgres               │  │    └─────────────────────────────┘
│  │  - redis                  │  │
│  │  - rabbitmq               │  │
│  └───────────────────────────┘  │
│  East-West Gateway               │
└─────────────────────────────────┘
```

### Application Services (Simple Buy)

| Service        | Cluster  | HTTP Port | gRPC Port | Description                          |
|----------------|----------|-----------|-----------|--------------------------------------|
| `frontend`     | cluster1 | 3000      | —         | Next.js frontend                     |
| `auth`         | cluster1 | 8081      | 9081      | User authentication & JWT            |
| `product`      | cluster2 | 8082      | 9082      | Product catalogue & categories       |
| `cart`         | cluster1 | 8083      | 9083      | Shopping cart (Redis-backed)         |
| `order`        | cluster1 | 8084      | 9084      | Order management                     |
| `notification` | cluster1 | 8085      | 9085      | Notifications (SSE via Redis)        |
| `postgres`     | cluster1 | 5432      | —         | Shared PostgreSQL with per-service DBs |
| `redis`        | cluster1 | 6379      | —         | Session & notification cache         |
| `rabbitmq`     | cluster1 | 5672      | 15672     | Async messaging                      |

## Prerequisites

- Docker
- `kubectl`
- `jq`

## Setup

Run the numbered scripts in order:

### 0. Install Tools

```bash
# Install kind
bash 0-install-kind.sh

# Install istioctl (Istio 1.28.3)
bash 0-install-istioctl.sh
```

### 1. Create Kind Clusters

```bash
bash 1-cluster-setup.sh
```

Creates two kind clusters:

| Cluster    | Pod CIDR       | Service CIDR  | Host Port |
|------------|----------------|---------------|-----------|
| `cluster1` | 10.244.0.0/16  | 10.96.0.0/16  | 8080      |
| `cluster2` | 10.245.0.0/16  | 10.97.0.0/16  | 8081      |

### 2. Install MetalLB

```bash
bash 2-install-metallb.sh
```

Automatically detects the kind Docker network subnet and configures non-overlapping IP pools:

- **cluster1**: `<subnet>.255.1` – `<subnet>.255.100`
- **cluster2**: `<subnet>.255.101` – `<subnet>.255.200`

### 3. Install Istio (Multi-Cluster)

```bash
bash 3-istio-cluster-setup.sh
```

- Installs Istio on both clusters with separate mesh networks (`network1` / `network2`) under a shared mesh ID (`mesh1`)
- Deploys east-west gateways on each cluster
- Shares the root CA so clusters trust each other's mTLS certificates

### 4. Exchange Istio Remote Secrets

```bash
bash 4-istio-secrets.sh
```

Creates cross-cluster remote secrets so each cluster's Istio control plane can discover services in the other cluster.

### 5. Deploy the Application

```bash
# Deploy the full app to cluster1
bash 5-deploy-app.sh

# Deploy the Product service to cluster2
bash 6-deploy-product-to-cluster2.sh
```

The app is deployed to the `simple-buy` namespace (Istio sidecar injection enabled). All resources are managed via Kustomize.

### Access the Application

Once deployed, the frontend is accessible at:

```
http://localhost:8080
```

## Cleanup

```bash
bash 7-cleanup.sh
```

Deletes both kind clusters.

## Repository Structure

```
.
├── 0-install-kind.sh           # Install kind binary
├── 0-install-istioctl.sh       # Install istioctl
├── 1-cluster-setup.sh          # Create kind clusters
├── 2-install-metallb.sh        # Install & configure MetalLB
├── 3-istio-cluster-setup.sh    # Install Istio multi-cluster
├── 4-istio-secrets.sh          # Exchange cross-cluster secrets
├── 5-deploy-app.sh             # Deploy app to cluster1
├── 6-deploy-product-to-cluster2.sh  # Deploy product to cluster2
├── 7-cleanup.sh                # Tear down clusters
├── configs/
│   ├── istio/                  # Istio IstioOperator configs & gateway manifests
│   ├── kind/                   # Kind cluster configs
│   └── metallb/                # MetalLB IP pool configs
└── sample-app/
    ├── *.yaml                  # All cluster1 manifests (Kustomize)
    └── cluster2-manifests/     # Product service manifests for cluster2
```

## Key Concepts Demonstrated

- **Istio multi-cluster (multi-network)** — two clusters on separate networks joined via east-west gateways
- **mTLS cross-cluster** — shared root CA enables automatic mutual TLS between clusters
- **Cross-cluster service discovery** — `product` service running in `cluster2` is transparently reachable from `cluster1`
- **Istio Ingress Gateway** — routes all HTTP traffic to microservices via `VirtualService` rules
- **Kustomize** — declarative management of Kubernetes manifests with image overrides
