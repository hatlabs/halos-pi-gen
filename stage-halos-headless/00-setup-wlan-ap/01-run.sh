#!/bin/bash -e

# Setup WiFi Access Point using NetworkManager for headless Halos variants
# This creates a virtual WiFi interface (wlan9) for AP mode while keeping
# wlan0 available for client connections

echo "Setting up Halos WiFi Hotspot using NetworkManager..."

# Copy the Halos-Hotspot NetworkManager connection profile
install -m 600 files/Halos-Hotspot.nmconnection "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"

# Install script to create virtual wlan interface for AP mode
install -m 755 files/create_ap_interface.sh "${ROOTFS_DIR}/usr/local/bin/create_ap_interface.sh"

# Install systemd service to create the AP interface
install -m 644 files/create_ap_interface.service "${ROOTFS_DIR}/etc/systemd/system/create_ap_interface.service"

# Enable the service to create virtual interface at boot
on_chroot <<EOF
systemctl enable create_ap_interface
EOF

echo "Halos WiFi Hotspot configured:"
echo "  SSID: Halos-HALPI2"
echo "  Password: halos1234"
echo "  Interface: wlan9 (virtual AP interface)"
echo "  wlan0 remains available for client connections"
