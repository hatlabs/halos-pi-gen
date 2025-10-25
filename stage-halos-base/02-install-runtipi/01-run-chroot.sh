#!/bin/bash -e

# The runtipi-docker-service package postinst script will:
# - Create /opt/runtipi directory structure
# - Enable runtipi.service
# - Start runtipi.service
#
# However, during image build, we don't want to start services yet
# So we stop it here and let it start on first boot

# Stop the service if it was started during package installation
systemctl stop runtipi.service || true

# Ensure service is enabled for first boot
systemctl enable runtipi.service

echo "Runtipi service configured and will start on first boot"
echo "Web interface will be available on port 80"
