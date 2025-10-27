#!/bin/bash -e

curl -fsSL https://apt.hatlabs.fi/hat-labs-apt-key.asc | gpg --dearmor > "${ROOTFS_DIR}/etc/apt/trusted.gpg.d/hatlabs.gpg"
echo "deb https://apt.hatlabs.fi stable main" > "${ROOTFS_DIR}/etc/apt/sources.list.d/hatlabs.list"
on_chroot << EOF
apt-get update
EOF
