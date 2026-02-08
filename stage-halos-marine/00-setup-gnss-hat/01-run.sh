#!/bin/bash -e

# Only run on HALPI2 builds (stage-halpi2-common adds the Hat Labs APT repo)
if [ ! -f "${ROOTFS_DIR}/etc/apt/sources.list.d/hatlabs.list" ]; then
    echo "Skipping GNSS HAT setup (not a HALPI2 build)"
    exit 0
fi

# Enable UART0 in boot config for MAX-M8Q GNSS HAT
cat files/config.txt.part >>"${ROOTFS_DIR}/boot/firmware/config.txt"

# Create gpsd device drop-in directory and add HALPI2 GPS device
# 01-setup-gpsd will merge this into gpsd configuration
mkdir -p "${ROOTFS_DIR}/etc/halos/gpsd-devices.d"
echo "/dev/ttyAMA0" > "${ROOTFS_DIR}/etc/halos/gpsd-devices.d/halpi2"
