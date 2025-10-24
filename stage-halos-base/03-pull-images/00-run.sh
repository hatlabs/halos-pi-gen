#!/bin/bash -e

# This script downloads Docker images without requiring the Docker daemon
# Uses skopeo to pull images from Docker Hub and convert to docker-archive format

# Check if skopeo is available
if ! command -v skopeo &> /dev/null; then
    echo "skopeo not found, installing..."
    apt-get update && apt-get install -y skopeo
fi

# Extract version from the docker-compose.yml
CASA_VERSION=$(grep 'image: dockurr/casa:' "${ROOTFS_DIR}/opt/casa/docker-compose.yml" | sed 's/.*dockurr\/casa://' | tr -d ' ')

if [ -z "$CASA_VERSION" ]; then
    echo "ERROR: Could not determine CasaOS version from docker-compose.yml"
    exit 1
fi

echo "Downloading dockurr/casa:$CASA_VERSION using skopeo..."

# Create output directory
mkdir -p "${ROOTFS_DIR}/opt/casa/images"

# Use skopeo to copy the image from Docker Hub to a docker-archive tar file
# This works without the Docker daemon and creates a tar that 'docker load' can read
skopeo copy \
    --override-arch=arm64 \
    docker://docker.io/dockurr/casa:${CASA_VERSION} \
    docker-archive:${ROOTFS_DIR}/opt/casa/images/casa-${CASA_VERSION}.tar:dockurr/casa:${CASA_VERSION}

echo "Successfully downloaded dockurr/casa:$CASA_VERSION to /opt/casa/images/"
ls -lh "${ROOTFS_DIR}/opt/casa/images/"
