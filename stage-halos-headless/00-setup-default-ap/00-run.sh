#!/bin/bash -e
#
# Install default WiFi AP for headless variants
#
# This provides a fallback WiFi access point for headless variants, allowing
# initial network access when no ethernet or pre-configured WiFi is available.
#
# The AP uses wlan0ap virtual interface, which is the same interface name
# used by cockpit-networkmanager-halos for user-created APs.
#
# The SSID is generated at first boot with format "Halos-XXXX" where XXXX is
# the last 4 hex digits of the wlan0 MAC address, making it unique per device.
#
# Related: https://github.com/hatlabs/halos-pi-gen/issues/26

echo "Installing default WiFi AP..."

# Install the interface creation script (also generates AP connection at first boot)
install -m 755 files/create-ap-interface.sh \
    "${ROOTFS_DIR}/usr/local/bin/create-ap-interface.sh"

# Install the systemd service
install -m 644 files/create-ap-interface.service \
    "${ROOTFS_DIR}/etc/systemd/system/create-ap-interface.service"

# Enable the service
on_chroot << EOF
systemctl enable create-ap-interface.service
EOF

echo "Default WiFi AP installed (SSID: Halos-XXXX, password: halos1234)"
