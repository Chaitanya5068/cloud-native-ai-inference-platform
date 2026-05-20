#!/bin/bash
###############################################################################
# Worker Services Deployment Script
# Runs docker-compose for Python, TypeScript, and Model workers
# Deploys on the private EC2 instance
###############################################################################

set -e  # Exit on error

echo "================================"
echo "Worker Services Deployment Started"
echo "================================"

# Configuration
WORKERS_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/docker/workers"
COMPOSE_FILE="$WORKERS_DIR/docker-compose.yml"

# Verify docker-compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "[ERROR] docker-compose.yml not found at $COMPOSE_FILE"
    exit 1
fi

cd "$WORKERS_DIR"

echo "[*] Pulling latest images..."
docker-compose pull || true

echo "[*] Building worker images..."
docker-compose build

echo "[*] Stopping existing services (if any)..."
docker-compose down || true

echo "[*] Starting worker services..."
docker-compose up -d

echo ""
echo "================================"
echo "Worker Services Deployment Completed!"
echo "================================"
echo ""

# Wait a moment for services to start
sleep 5

echo "Service Status:"
docker-compose ps

echo ""
echo "Service URLs (internal):"
echo "  Python Worker: http://localhost:8001"
echo "  TypeScript Worker: http://localhost:8002"
echo "  Model Worker: http://localhost:8003"
echo ""
echo "Health Checks:"
docker-compose exec -T python-worker curl -s http://localhost:8001/health || echo "Python worker not ready"
docker-compose exec -T ts-worker curl -s http://localhost:8002/health || echo "TypeScript worker not ready"
docker-compose exec -T model-worker curl -s http://localhost:8003/health || echo "Model worker not ready"

echo ""
echo "Logs:"
docker-compose logs --tail=20
