#!/bin/bash
set -e

echo "Deleting Kind clusters..."
kind delete clusters cluster1 cluster2

echo "Clusters deleted successfully."
