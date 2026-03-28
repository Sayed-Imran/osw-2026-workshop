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
echo "║   Deploy Sample App to Cluster 1              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""



log_info "Deploying application to cluster1 using Kustomize..."
kubectl apply -k sample-app/ --context=kind-cluster1 || {
    log_error "Failed to deploy application"
    exit 1
}
