#!/bin/bash -e

# This runs in the chroot environment (inside the image being built)
# Configure the marine app store to be added on first boot using runtipi-cli

MARINE_APPSTORE_NAME="Marine"
MARINE_APPSTORE_URL="https://github.com/hatlabs/runtipi-marine-app-store"

echo "Configuring marine app store to be added on first boot..."

# Create a systemd one-shot service to add the app store on first boot
cat > /etc/systemd/system/add-marine-appstore.service <<EOF
[Unit]
Description=Add Marine App Store to Runtipi
After=runtipi.service
Requires=runtipi.service

[Service]
Type=oneshot
# Wait for Runtipi to be ready
ExecStartPre=/bin/bash -c 'for i in {1..60}; do docker exec runtipi-db pg_isready -U tipi 2>/dev/null && break || sleep 2; done'
ExecStartPre=/bin/sleep 10
# Add the marine app store using runtipi-cli
ExecStart=/bin/bash -c 'cd /opt/runtipi && ./runtipi-cli appstore add "${MARINE_APPSTORE_NAME}" "${MARINE_APPSTORE_URL}" || true'
# Disable the service after successful execution
ExecStartPost=/bin/systemctl disable add-marine-appstore.service
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable add-marine-appstore.service

echo "Marine app store will be added on first boot using runtipi-cli"
