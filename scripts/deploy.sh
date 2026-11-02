#!/usr/bin/env bash
set -euo pipefail

IMAGE="aryav17/devops-deployment-project:latest"
CONTAINER="devops-app"
PORT="8080"

echo "Pulling latest image..."
docker pull "$IMAGE"

echo "Removing old container if it exists..."
docker rm -f "$CONTAINER" 2>/dev/null || true

echo "Starting new container..."
docker run -d \
  --name "$CONTAINER" \
  --restart unless-stopped \
  -p "$PORT:80" \
  "$IMAGE"

echo "Checking application health..."
bash scripts/health-check.sh "http://localhost:$PORT"

echo "Deployment completed successfully!"
