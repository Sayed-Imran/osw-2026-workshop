#!/bin/bash
set -e

echo "Deleting Kind clusters..."
kind delete cluster --name cluster1 cluster2

echo "Clusters deleted successfully."
