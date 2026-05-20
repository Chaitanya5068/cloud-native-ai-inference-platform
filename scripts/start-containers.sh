#!/bin/bash
###############################################################################
# Container Restart Script
# Restarts all containers managed by this project
###############################################################################

set -e  # Exit on error

echo "================================"
echo "Restarting Containers"
echo "================================"

echo "[*] Restarting Docker daemon..."
systemctl restart docker || true

echo "[*] Waiting for Docker to be ready..."
sleep 3

# Restart API container
echo "[*] Restarting API container..."
docker restart api-gateway || echo "API container not running"

# Restart worker containers
echo "[*] Restarting worker containers..."
cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/docker/workers"
docker-compose restart || echo "Workers not running via compose"

# Alternative: Restart by name
docker restart python-worker || echo "Python worker not running"
docker restart ts-worker || echo "TypeScript worker not running"
docker restart model-worker || echo "Model worker not running"

echo ""
echo "================================"
echo "Container Restart Completed!"
echo "================================"
echo ""
echo "Running containers:"
docker ps

echo ""
echo "Checking health:"
docker ps --format "table {{.Names}}\t{{.Status}}"
