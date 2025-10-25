#!/bin/bash -e

# Create a one-time systemd service to load the Docker images on first boot

# Extract versions from the docker-compose.yml
RUNTIPI_VERSION=$(grep 'image: ghcr.io/runtipi/runtipi:' /opt/runtipi/docker-compose.yml | sed 's/.*ghcr\.io\/runtipi\/runtipi://' | tr -d ' ')
TRAEFIK_VERSION=$(grep 'image: traefik:' /opt/runtipi/docker-compose.yml | sed 's/.*traefik://' | tr -d ' ')
POSTGRES_VERSION=$(grep 'image: postgres:' /opt/runtipi/docker-compose.yml | sed 's/.*postgres://' | tr -d ' ')

if [ -z "$RUNTIPI_VERSION" ] || [ -z "$TRAEFIK_VERSION" ] || [ -z "$POSTGRES_VERSION" ]; then
    echo "ERROR: Could not determine all versions from /opt/runtipi/docker-compose.yml"
    echo "RUNTIPI_VERSION: $RUNTIPI_VERSION"
    echo "TRAEFIK_VERSION: $TRAEFIK_VERSION"
    echo "POSTGRES_VERSION: $POSTGRES_VERSION"
    exit 1
fi

echo "Creating systemd service to load Runtipi Docker images on first boot..."

# Create a one-shot service to load all Docker images
cat > /etc/systemd/system/load-runtipi-images.service <<EOF
[Unit]
Description=Load Runtipi Docker Images
Before=runtipi.service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c '\
  for img in /opt/runtipi/images/*.tar; do \
    if [ -f "\$img" ]; then \
      echo "Loading \$(basename \$img)..."; \
      docker load -i "\$img" && rm "\$img"; \
    fi \
  done; \
  rmdir /opt/runtipi/images 2>/dev/null || true; \
  echo "All Runtipi images loaded successfully"'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable load-runtipi-images.service

echo "Docker images will be loaded on first boot from /opt/runtipi/images/"
echo "Images to be loaded:"
echo "  - runtipi-${RUNTIPI_VERSION}.tar"
echo "  - traefik-${TRAEFIK_VERSION}.tar"
echo "  - postgres-${POSTGRES_VERSION}.tar"
echo "  - lavinmq-latest.tar"
