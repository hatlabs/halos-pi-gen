#!/bin/bash -e
#
# Install WiFi STA+AP mode support components
#
# This installs a first-boot service that restricts the 'preconfigured'
# WiFi connection to wlan0 only, preventing it from racing to grab
# virtual AP interfaces (wlan0ap) when they are created.
#
# Related: https://github.com/hatlabs/halos-pi-gen/issues/26

echo "Installing WiFi STA+AP mode support..."

# Install the restriction script
install -m 755 files/restrict-preconfigured-wifi.sh \
    "${ROOTFS_DIR}/usr/local/bin/restrict-preconfigured-wifi.sh"

# Install the systemd service
install -m 644 files/restrict-preconfigured-wifi.service \
    "${ROOTFS_DIR}/etc/systemd/system/restrict-preconfigured-wifi.service"

# Enable the service
on_chroot << EOF
systemctl enable restrict-preconfigured-wifi.service
EOF

# Remove any legacy Halos-Hotspot connection file if present
# (AP connections are now managed by cockpit-networkmanager-halos)
rm -f "${ROOTFS_DIR}/etc/NetworkManager/system-connections/Halos-Hotspot.nmconnection"

echo "WiFi STA+AP mode support installed"
