# TypeScript Worker Docker Image
# Second step in the processing pipeline
# Receives from Python worker and forwards to Model worker

FROM node:20-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and install dependencies
COPY package.json . || echo "No package.json"

RUN npm init -y && \
    npm install express axios

# Copy application code
COPY ts_worker.js .

EXPOSE 8002

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8002/health || exit 1

CMD ["node", "ts_worker.js"]
