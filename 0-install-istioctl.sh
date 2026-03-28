#!/bin/bash
set -e

ISTIO_VERSION=1.28.3
ARCH=$(uname -m)

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=${ARCH} sh -
sudo cp istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/istioctl
