#!/bin/bash -e

# Add HALPI2-specific packages repository (hatlabs component)
# GPG key already added by stage-hatlabs-common
echo "deb https://apt.hatlabs.fi trixie-stable hatlabs" >> "${ROOTFS_DIR}/etc/apt/sources.list.d/hatlabs.list"
on_chroot << EOF
apt-get update
EOF
