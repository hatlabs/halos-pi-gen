# stage-halos-base

This stage installs the core Halos components that are included in all Halos variants (both marine and non-marine, desktop and lite).

## Components Installed

### 00-install-docker
Installs Docker CE from the official Docker repository following [Docker's official documentation](https://docs.docker.com/engine/install/debian/).

**Packages installed:**
- docker-ce
- docker-ce-cli
- containerd.io
- docker-buildx-plugin
- docker-compose-plugin

**What it does:**
- Adds Docker's official GPG key
- Adds Docker APT repository
- Installs Docker CE and plugins
- Enables Docker service

### 01-install-cockpit
Installs Cockpit web-based system administration interface.

**Packages installed:**
- cockpit (core web interface)
- cockpit-docker (Docker container management)
- cockpit-networkmanager (network management)
- cockpit-storaged (storage management)

**What it does:**
- Installs Cockpit packages
- Enables cockpit.socket service
- Web UI available on port 9090 after first boot

### 02-install-runtipi
Installs the Runtipi containerized service from the Hat Labs APT repository.

**Packages installed:**
- runtipi-docker-service (from apt.hatlabs.fi)

**What it does:**
- Installs runtipi-docker-service package
- Creates /opt/runtipi directory structure (via package postinst)
- Installs docker-compose.yml to /opt/runtipi/
- Installs runtipi.service systemd unit
- Enables runtipi.service for first boot
- Stops service during build (will start on first boot)
- Web UI available on port 80 after first boot

### 03-pull-images
Pre-pulls Docker images required by Runtipi to enable offline first boot.

**What it does:**
- Reads image versions from /opt/runtipi/docker-compose.yml
- Pulls required images:
  - ghcr.io/runtipi/runtipi (version from docker-compose.yml)
  - traefik (version from docker-compose.yml)
  - postgres (version from docker-compose.yml)
  - cloudamqp/lavinmq:latest
- Stores images as tar archives in /opt/runtipi/images/
- Creates systemd service to load images on first boot
- Ensures Runtipi can start without network connectivity

## Services Enabled

After this stage, the following services are enabled but not yet started:
- **docker.service** - Docker daemon
- **cockpit.socket** - Cockpit web interface (port 9090)
- **runtipi.service** - Runtipi container management (port 80)
- **load-runtipi-images.service** - One-time service to load Docker images on first boot

Services will start on first boot of the Halos system.

## Network Requirements

This stage requires network connectivity during the build process to:
- Download Docker CE packages from download.docker.com
- Download Cockpit packages from Debian repositories
- Download runtipi-docker-service from apt.hatlabs.fi
- Pull Runtipi Docker images:
  - ghcr.io/runtipi/runtipi from GitHub Container Registry
  - traefik from Docker Hub
  - postgres from Docker Hub
  - cloudamqp/lavinmq from Docker Hub

After the build is complete, the system can boot and run without network connectivity since all required images are pre-pulled.

## Applies To

This stage is included in all Halos image variants:
- Halos-HALPI2 (desktop)
- Halos-Lite-HALPI2 (headless)
- Halos-RPI (desktop, generic Pi)
- Halos-Lite-RPI (headless, generic Pi)
- Halos-Marine-* variants (all with additional stage-halos-marine)

## Stage Order

This stage should be run:
- **After** stage2 (base system is ready)
- **Before** hardware-specific stages (stage-halpi2-common)
- **Before** stage3 (if desktop environment is needed)
- **Before** stage-halos-marine (if marine variant)

Example stage list:
```
stage0 stage1 stage2 stage-halos-base stage-halpi2-common stage3 stage-halos-marine
```