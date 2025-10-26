#!/bin/bash -e

# This runs on the build host (pi-gen Docker container)
# Pre-pull the Signal K Docker image using skopeo and save it to the image
# Skopeo works without a Docker daemon, so it works in restricted build environments

SIGNALK_IMAGE="docker://signalk/signalk-server:latest-24.x"
SIGNALK_IMAGE_NAME="signalk"

# Install skopeo if not available
if ! command -v skopeo &> /dev/null; then
    echo "skopeo not found, installing..."
    apt-get update
    apt-get install -y skopeo
fi

echo "Pre-pulling Signal K Docker image using skopeo..."

# Create directory for image tarball (should already exist from stage-halos-base)
mkdir -p "${ROOTFS_DIR}/opt/runtipi/images"

echo "Pulling ${SIGNALK_IMAGE} using skopeo..."

# Use skopeo to copy the image directly to docker-archive format
skopeo copy "${SIGNALK_IMAGE}" "docker-archive:${ROOTFS_DIR}/opt/runtipi/images/${SIGNALK_IMAGE_NAME}.tar"

echo "Successfully saved Signal K image to /opt/runtipi/images/${SIGNALK_IMAGE_NAME}.tar"
echo "Image will be loaded on first boot by the load-runtipi-images.service"
