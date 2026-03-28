#!/bin/bash
set -e

echo "Creating Kind clusters..."
kind create cluster --config configs/kind/cluster1-config.yaml &
kind create cluster --config configs/kind/cluster2-config.yaml &
wait

