#!/bin/bash
#
# Restrict the 'preconfigured' WiFi connection to wlan0 interface only
#
# This prevents the connection from racing to grab virtual AP interfaces
# (wlan0ap) when they are created for simultaneous STA+AP mode.
#
# The 'preconfigured' connection is created by Raspberry Pi Imager when
# users pre-configure WiFi credentials before flashing the image.
#
# This script runs before NetworkManager starts on first boot.
#
# Related: https://github.com/hatlabs/halos-pi-gen/issues/26

CONN_FILE="/etc/NetworkManager/system-connections/preconfigured.nmconnection"
MARKER_FILE="/var/lib/halos/wifi-sta-ap-configured"

# Only run once
if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

# Create marker directory
mkdir -p "$(dirname "$MARKER_FILE")"

# Check if preconfigured connection exists
if [ ! -f "$CONN_FILE" ]; then
    echo "No preconfigured WiFi connection found"
    touch "$MARKER_FILE"
    exit 0
fi

# Check if interface-name is already set in [connection] section
if grep -q "^interface-name=" "$CONN_FILE"; then
    echo "preconfigured WiFi already has interface-name set"
    touch "$MARKER_FILE"
    exit 0
fi

# Add interface-name=wlan0 after the type= line in [connection] section
echo "Restricting preconfigured WiFi to wlan0..."
sed -i '/^\[connection\]/,/^\[/ { /^type=/a interface-name=wlan0
}' "$CONN_FILE"

# Verify the change was made
if grep -q "^interface-name=wlan0" "$CONN_FILE"; then
    echo "Successfully restricted preconfigured WiFi to wlan0"
else
    echo "Warning: Failed to modify preconfigured connection"
fi

touch "$MARKER_FILE"
