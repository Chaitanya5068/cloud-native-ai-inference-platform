#!/bin/bash
###############################################################################
# API Server Deployment Script
# Builds and runs the FastAPI API Gateway container on the public EC2 instance
###############################################################################

set -e  # Exit on error

echo "================================"
echo "API Server Deployment Started"
echo "================================"

# Configuration
API_IMAGE_NAME="ai-inference-api"
API_CONTAINER_NAME="api-gateway"
API_PORT="${API_PORT:-8000}"
WORKER_SERVICE_URL="${WORKER_SERVICE_URL:-http://worker-server:8001}"

# Change to docker/api directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
API_DIR="$(dirname "$SCRIPT_DIR")/docker/api"

cd "$API_DIR"

echo "[*] Building API image: $API_IMAGE_NAME"
docker build -t "$API_IMAGE_NAME:latest" .

echo "[*] Stopping existing container (if any)..."
docker stop "$API_CONTAINER_NAME" || true
docker rm "$API_CONTAINER_NAME" || true

echo "[*] Running API container..."
docker run \
    --name "$API_CONTAINER_NAME" \
    --detach \
    --restart unless-stopped \
    -p "${API_PORT}:8000" \
    -e "API_HOST=0.0.0.0" \
    -e "API_PORT=8000" \
    -e "WORKER_SERVICE_URL=$WORKER_SERVICE_URL" \
    "$API_IMAGE_NAME:latest"

echo ""
echo "================================"
echo "API Server Deployment Completed!"
echo "================================"
echo ""
echo "Container Name: $API_CONTAINER_NAME"
echo "Image: $API_IMAGE_NAME:latest"
echo "Port: $API_PORT"
echo "Worker Service URL: $WORKER_SERVICE_URL"
echo ""
echo "API Health: http://localhost:$API_PORT/health"
echo "API Docs: http://localhost:$API_PORT/docs"
echo ""
echo "Logs:"
docker logs "$API_CONTAINER_NAME"
