
#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_REPO="aryav17/devops-deployment-project"
CONTAINER="devops-app"
PORT="80"

NEW_TAG="${1:?Usage: ./deploy-ec2.sh IMAGE_TAG}"
NEW_IMAGE="${IMAGE_REPO}:${NEW_TAG}"
PREVIOUS_IMAGE=""

echo "Starting deployment..."
echo "New image: $NEW_IMAGE"

if sudo docker inspect "$CONTAINER" >/dev/null 2>&1; then
    PREVIOUS_IMAGE=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER")
    echo "Previous image: $PREVIOUS_IMAGE"
fi

if ! sudo docker image inspect "$NEW_IMAGE" >/dev/null 2>&1; then
    sudo docker pull "$NEW_IMAGE"
fi

rollback() {
    echo "Deployment failed. Starting rollback..."

    sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

    if [[ -z "$PREVIOUS_IMAGE" ]]; then
        echo "No previous image available for rollback."
        return 1
    fi

    if ! sudo docker run -d \
        --name "$CONTAINER" \
        --restart unless-stopped \
        -p "$PORT:80" \
        "$PREVIOUS_IMAGE"; then
        echo "CRITICAL: Could not start previous container."
        return 1
    fi

    sleep 3

    if curl -fsS http://localhost/ | grep -q "My DevOps Project"; then
        echo "Rollback successful!"
        return 0
    fi

    echo "CRITICAL: Previous deployment is unhealthy."
    return 1
}

sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

if ! sudo docker run -d \
    --name "$CONTAINER" \
    --restart unless-stopped \
    -p "$PORT:80" \
    "$NEW_IMAGE"; then
    rollback || true
    exit 1
fi

sleep 3

if curl -fsS http://localhost/ | grep -q "My DevOps Project"; then
    echo "Deployment successful!"
    exit 0
fi

rollback || true
exit 1
