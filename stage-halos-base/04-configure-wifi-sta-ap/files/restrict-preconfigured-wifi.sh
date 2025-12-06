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

set -e

CONN_FILE="/etc/NetworkManager/system-connections/preconfigured.nmconnection"
MARKER_FILE="/var/lib/halos/wifi-sta-ap-configured"

# Log to both stdout and systemd journal
log() {
    local level="${2:-info}"
    echo "$1"
    echo "$1" | systemd-cat -t restrict-preconfigured-wifi -p "$level"
}

# Only run once
if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

# Create marker directory
mkdir -p "$(dirname "$MARKER_FILE")"

# Check if preconfigured connection exists
if [ ! -f "$CONN_FILE" ]; then
    log "No preconfigured WiFi connection found"
    touch "$MARKER_FILE"
    exit 0
fi

# Check current interface-name value
current_interface=$(grep "^interface-name=" "$CONN_FILE" 2>/dev/null | cut -d= -f2 || true)

if [ -n "$current_interface" ]; then
    if [ "$current_interface" = "wlan0" ]; then
        log "preconfigured WiFi already restricted to wlan0"
        touch "$MARKER_FILE"
        exit 0
    else
        log "Warning: preconfigured WiFi has interface-name=$current_interface, changing to wlan0" warning
        sed -i 's/^interface-name=.*/interface-name=wlan0/' "$CONN_FILE"
    fi
else
    # Add interface-name=wlan0 after the type= line in [connection] section
    log "Restricting preconfigured WiFi to wlan0..."
    sed -i '/^\[connection\]/,/^\[/ {
        /^type=/ a\
interface-name=wlan0
    }' "$CONN_FILE"
fi

# Ensure correct permissions for NetworkManager
chmod 600 "$CONN_FILE"
chown root:root "$CONN_FILE"

# Verify the change was made
if grep -q "^interface-name=wlan0" "$CONN_FILE"; then
    log "Successfully restricted preconfigured WiFi to wlan0"
else
    log "ERROR: Failed to modify preconfigured connection" err
    exit 1
fi

touch "$MARKER_FILE"
