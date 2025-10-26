#!/bin/bash -e

# This runs on the build host (pi-gen Docker container)
# Clone the marine app store repository into the image

MARINE_APPSTORE_SLUG="marine"
MARINE_APPSTORE_URL="https://github.com/hatlabs/runtipi-marine-app-store"
MARINE_APPSTORE_BRANCH="main"
MARINE_APPSTORE_DIR="${ROOTFS_DIR}/opt/runtipi/repos/${MARINE_APPSTORE_SLUG}"

echo "Cloning marine app store from ${MARINE_APPSTORE_URL}..."

# Create the repos directory structure
mkdir -p "${ROOTFS_DIR}/opt/runtipi/repos"

# Install git if not available
if ! command -v git &> /dev/null; then
    echo "git not found, installing..."
    apt-get update
    apt-get install -y git
fi

# Clone the app store
git clone --depth 1 --branch "${MARINE_APPSTORE_BRANCH}" "${MARINE_APPSTORE_URL}" "${MARINE_APPSTORE_DIR}"

# Remove .git directory to save space
rm -rf "${MARINE_APPSTORE_DIR}/.git"

echo "Marine app store cloned successfully to ${MARINE_APPSTORE_DIR}"
