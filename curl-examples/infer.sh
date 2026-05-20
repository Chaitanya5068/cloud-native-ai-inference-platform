#!/bin/bash
###############################################################################
# API Inference Examples
# Demonstrates how to interact with the Distributed AI Inference Platform
###############################################################################

# Configuration
API_SERVER_IP="${1:-localhost}"
API_PORT="${2:-8000}"
API_URL="http://${API_SERVER_IP}:${API_PORT}"

echo "================================"
echo "API Inference Examples"
echo "================================"
echo "API Server: $API_URL"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Example 1: Health Check
echo -e "${YELLOW}[Example 1] Health Check${NC}"
echo "Command:"
echo "  curl -s $API_URL/health | jq ."
echo ""
echo "Response:"
curl -s "$API_URL/health" | jq . || echo "Failed to connect"
echo ""
echo ""

# Example 2: Simple Inference
echo -e "${YELLOW}[Example 2] Simple Inference${NC}"
echo "Command:"
echo "  curl -X POST $API_URL/infer \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"prompt\":\"Hello\"}'"
echo ""
echo "Response:"
curl -X POST "$API_URL/infer" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Hello"}' | jq . || echo "Failed to send request"
echo ""
echo ""

# Example 3: Inference with Model Specification
echo -e "${YELLOW}[Example 3] Inference with Model Specification${NC}"
echo "Command:"
echo "  curl -X POST $API_URL/infer \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"prompt\":\"Explain DevOps\", \"model\":\"advanced\"}'"
echo ""
echo "Response:"
curl -X POST "$API_URL/infer" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"Explain DevOps", "model":"advanced"}' | jq . || echo "Failed to send request"
echo ""
echo ""

# Example 4: API Documentation
echo -e "${YELLOW}[Example 4] Interactive API Documentation${NC}"
echo "Open in browser:"
echo "  $API_URL/docs"
echo ""
echo ""

# Example 5: ReDoc Documentation
echo -e "${YELLOW}[Example 5] Alternative API Documentation (ReDoc)${NC}"
echo "Open in browser:"
echo "  $API_URL/redoc"
echo ""
echo ""

# Example 6: Batch Processing
echo -e "${YELLOW}[Example 6] Multiple Inference Requests${NC}"
echo "Processing multiple prompts..."
echo ""

prompts=("What is AI?" "How does distributed computing work?" "Explain infrastructure as code")

for i in "${!prompts[@]}"; do
    echo "Request $((i+1)): ${prompts[$i]}"
    curl -s -X POST "$API_URL/infer" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\":\"${prompts[$i]}\"}" | jq '.response' || echo "Failed"
    echo ""
done

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Examples Completed!${NC}"
echo -e "${GREEN}================================${NC}"
