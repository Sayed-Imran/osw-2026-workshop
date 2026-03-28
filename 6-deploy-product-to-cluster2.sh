#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║   Deploy Product Service to Cluster 2         ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Set cluster context
CLUSTER_CONTEXT="kind-cluster2"

# Deploy all resources using kustomize
log_info "Deploying Product service to cluster2..."
kubectl apply -k sample-app/cluster2-manifests/ --context=$CLUSTER_CONTEXT || {
    log_error "Failed to deploy application"
    exit 1
}
log_success "All resources deployed successfully"

# Show deployment status
echo ""
log_info "Deployment Status:"
echo ""
kubectl get pods -n simple-buy --context=$CLUSTER_CONTEXT

echo ""
log_info "Services:"
echo ""
kubectl get svc -n simple-buy --context=$CLUSTER_CONTEXT

echo ""
log_success "Deployment complete! 🎉"

echo ""
log_info "Access Information:"
echo ""
echo "  Product service is now running on cluster2"
echo ""
echo "  Check pod logs:"
echo "  kubectl logs -n simple-buy -l app=product --context=$CLUSTER_CONTEXT --tail=50"
echo ""
