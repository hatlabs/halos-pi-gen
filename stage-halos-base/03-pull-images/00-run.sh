#!/bin/bash -e

# This script downloads Docker images without requiring the Docker daemon
# Uses skopeo to pull images and convert to docker-archive format

# Check if skopeo is available
if ! command -v skopeo &> /dev/null; then
    echo "skopeo not found, installing..."
    apt-get update && apt-get install -y skopeo
fi

# Extract versions from the docker-compose.yml
RUNTIPI_VERSION=$(grep 'image: ghcr.io/runtipi/runtipi:' "${ROOTFS_DIR}/opt/runtipi/docker-compose.yml" | sed 's/.*ghcr\.io\/runtipi\/runtipi://' | tr -d ' ')
TRAEFIK_VERSION=$(grep 'image: traefik:' "${ROOTFS_DIR}/opt/runtipi/docker-compose.yml" | sed 's/.*traefik://' | tr -d ' ')
POSTGRES_VERSION=$(grep 'image: postgres:' "${ROOTFS_DIR}/opt/runtipi/docker-compose.yml" | sed 's/.*postgres://' | tr -d ' ')

if [ -z "$RUNTIPI_VERSION" ] || [ -z "$TRAEFIK_VERSION" ] || [ -z "$POSTGRES_VERSION" ]; then
    echo "ERROR: Could not determine all versions from docker-compose.yml"
    echo "RUNTIPI_VERSION: $RUNTIPI_VERSION"
    echo "TRAEFIK_VERSION: $TRAEFIK_VERSION"
    echo "POSTGRES_VERSION: $POSTGRES_VERSION"
    exit 1
fi

echo "Downloading Runtipi Docker images using skopeo..."
echo "  - ghcr.io/runtipi/runtipi:$RUNTIPI_VERSION"
echo "  - traefik:$TRAEFIK_VERSION"
echo "  - postgres:$POSTGRES_VERSION"
echo "  - cloudamqp/lavinmq:latest"

# Create output directory
mkdir -p "${ROOTFS_DIR}/opt/runtipi/images"

# Download runtipi main image
echo "Downloading runtipi:$RUNTIPI_VERSION..."
skopeo copy \
    --override-arch=arm64 \
    docker://ghcr.io/runtipi/runtipi:${RUNTIPI_VERSION} \
    docker-archive:${ROOTFS_DIR}/opt/runtipi/images/runtipi-${RUNTIPI_VERSION}.tar:ghcr.io/runtipi/runtipi:${RUNTIPI_VERSION}

# Download traefik
echo "Downloading traefik:$TRAEFIK_VERSION..."
skopeo copy \
    --override-arch=arm64 \
    docker://docker.io/library/traefik:${TRAEFIK_VERSION} \
    docker-archive:${ROOTFS_DIR}/opt/runtipi/images/traefik-${TRAEFIK_VERSION}.tar:traefik:${TRAEFIK_VERSION}

# Download postgres
echo "Downloading postgres:$POSTGRES_VERSION..."
skopeo copy \
    --override-arch=arm64 \
    docker://docker.io/library/postgres:${POSTGRES_VERSION} \
    docker-archive:${ROOTFS_DIR}/opt/runtipi/images/postgres-${POSTGRES_VERSION}.tar:postgres:${POSTGRES_VERSION}

# Download lavinmq (using latest since no version specified in compose)
echo "Downloading cloudamqp/lavinmq:latest..."
skopeo copy \
    --override-arch=arm64 \
    docker://docker.io/cloudamqp/lavinmq:latest \
    docker-archive:${ROOTFS_DIR}/opt/runtipi/images/lavinmq-latest.tar:cloudamqp/lavinmq:latest

echo "Successfully downloaded all Runtipi images to /opt/runtipi/images/"
ls -lh "${ROOTFS_DIR}/opt/runtipi/images/"
