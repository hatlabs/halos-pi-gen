#!/bin/bash
#
# Create wlan0ap virtual interface and default AP connection
#
# This script runs early at boot (before NetworkManager) to:
# 1. Create the virtual AP interface
# 2. Generate a default AP connection with a unique SSID (if not already present)
#
# The SSID includes the last 4 hex digits of the wlan0 MAC address to make it
# unique when multiple devices are being set up simultaneously.
#
# The interface name wlan0ap is also used by cockpit-networkmanager-halos,
# so user-created APs will use the same interface.

CONN_FILE="/etc/NetworkManager/system-connections/Halos-AP.nmconnection"

# Log to both stdout and systemd journal
log() {
    local level="${2:-info}"
    echo "$1"
    echo "$1" | systemd-cat -t create-ap-interface -p "$level"
}

# Create virtual AP interface
iw dev wlan0 interface add wlan0ap type __ap 2>/dev/null || true
ip link set wlan0ap up 2>/dev/null || true

# Generate default AP connection if it doesn't exist
if [ ! -f "$CONN_FILE" ]; then
    # Get last 4 hex digits of wlan0 MAC address (uppercase, no colons)
    MAC_SUFFIX=$(tr -d ':\n' < /sys/class/net/wlan0/address 2>/dev/null | tail -c 4 | tr '[:lower:]' '[:upper:]')

    if [ -n "$MAC_SUFFIX" ]; then
        SSID="Halos-${MAC_SUFFIX}"
    else
        SSID="Halos"
    fi

    cat > "$CONN_FILE" << EOF
[connection]
id=Halos-AP
type=wifi
interface-name=wlan0ap
autoconnect=true
autoconnect-priority=-100

[wifi]
mode=ap
ssid=${SSID}
band=bg

[wifi-security]
key-mgmt=wpa-psk
psk=halos1234

[ipv4]
method=shared

[ipv6]
method=ignore
EOF

    chmod 600 "$CONN_FILE"
    log "Created default AP connection (SSID: ${SSID})"
else
    log "Default AP connection already exists"
fi
