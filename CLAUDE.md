# Halos Image Builder

This repository builds Halos (Hat Labs Operating System) images using pi-gen.

**pi-gen Documentation:** https://raw.githubusercontent.com/RPi-Distro/pi-gen/refs/heads/master/README.md

## Git Workflow Policy

**IMPORTANT:** Always ask the user before:
- Committing files to git
- Pushing commits to remote repositories
- Creating or modifying git tags
- Running destructive git operations

## Project Overview

Halos is a Raspberry Pi OS (Trixie) distribution with pre-installed Cockpit and CasaOS web management interfaces. This repository uses the official `pi-gen` image builder with custom stages to create Halos images for HALPI2 and generic Raspberry Pi hardware.

**Not in this repository:** Legacy OpenPlotter and HALPI (CM4) images are maintained in the separate `openplotter-halpi` repository (Bookworm-based).

## ⚠️ CRITICAL: Offline Operation Requirement

**IMPORTANT:** Halos is designed for marine environments where **internet connectivity may NOT be available during first boot**.

**Mandatory Requirements:**
1. **All Docker images required for first boot MUST be pre-loaded** in the built image
2. **No network connectivity can be assumed** on first boot
3. **All core services must be operational** without internet access

This currently applies to:
- **CasaOS Docker image** (`dockurr/casa:X.Y.Z`) - required by casaos-docker-service package

## Image Variants

Each variant is defined by a `config.*` file that specifies which stages to include. See the actual config files for exact stage lists and settings.

**Halos uses headless-first naming:** Base images are headless. Desktop variants add `-Desktop-` to the name.

**Naming Convention:**
- Headless (default): `Halos-[Marine-]<Hardware>`
- Desktop variants: `Halos-Desktop-[Marine-]<Hardware>`
- Hardware suffix: `-HALPI2` or `-RPI`

## Build Commands

```bash
# Build a specific variant
./run docker-build "Halos-Marine-HALPI2"

# Build all enabled variants
./run docker-build-all

# Clean up Docker containers
./run docker-clean
```

**Requirements:** Docker, ~20GB disk space per variant

## Architecture

### Build System Structure

1. The `pi-gen` repository is cloned (arm64 branch)
2. Custom Halos stage directories are copied into `pi-gen/`
3. A config file is copied to `pi-gen/config`
4. The pi-gen Docker builder runs with the custom stages

### Stage System

Pi-gen uses a stage-based system where each stage adds functionality. Stages run in alphanumeric order.

**Standard Pi-Gen Stages:** stage0 (bootstrap) → stage1 (base) → stage2 (lite) → stage3 (desktop) → stage4+ (full)

**Custom Halos Stages:**
- **stage-halos-base/**: Install Cockpit and CasaOS (all Halos variants)
- **stage-halpi2-common/**: HALPI2 hardware support (APT repo, drivers, CAN/RS485/I2C)
- **stage-halos-marine/**: Marine software stack (Signal K, InfluxDB, Grafana)
- **stage-halpi2-rpi/**: HALPI2 desktop customizations (wallpaper, VNC)

### Task Structure

Each stage contains numbered task directories (00-, 01-, etc.):
- **00-run.sh**: Script executed on build host
- **01-run-chroot.sh**: Script executed inside Pi OS filesystem
- **00-packages**: List of apt packages to install
- **files/**: Configuration files copied into image

## Configuration Guidelines by Variant Type

**Headless variants** (accessible immediately over network):
- Set `FIRST_USER_NAME="pi"`, `FIRST_USER_PASS="raspberry"`
- Set `DISABLE_FIRST_BOOT_USER_RENAME="1"`, `ENABLE_SSH=1`
- Security tradeoff: convenience over security

**Desktop variants** (use first-boot wizard):
- Do NOT set user credentials
- Let user configure securely via GUI

## Creating New Image Variants

1. **Create config file**: `config.halos-new-variant`
2. **Define stage list**: Base stages + custom Halos stages as needed
3. **Add to CI/CD**: Update `.github/workflows/pull_request.yml` matrix
4. **Test locally**: `./run docker-build "Variant-Name"`

## Common Development Patterns

### Adding a New Stage Task

1. Create numbered directory: `stage-name/##-task-name/`
2. Add script: `01-run-chroot.sh` (most common)
3. Optional: `00-packages` file for apt packages
4. Optional: `files/` directory for config files

### Key pi-gen Variables

- `${ROOTFS_DIR}`: Path to the root filesystem being built
- `${STAGE_DIR}`: Current stage directory

### Testing Changes

- Add `SKIP` files to disable stages during development
- Check `deploy/build.log` for build errors
- Use `./run docker-clean` to clean up failed builds

## Build and Release Pipeline

### Debian Package Building
Custom packages are built in separate repositories and published to apt.hatlabs.fi

### CI/CD Workflows

- **`.github/workflows/pull_request.yml`**: Builds images on PRs (ARM64 runners)
- **`.github/workflows/release.yml`**: Creates GitHub releases

## Technology Stack

- **Base OS**: Debian-based Raspberry Pi OS (arm64, trixie)
- **Build System**: pi-gen (official Raspberry Pi image builder)
- **Web Management**: Cockpit (system admin), CasaOS (container/app management)
- **Containers**: Docker + Docker Compose
- **Marine Software**: Signal K, InfluxDB, Grafana
- **Hardware**: HALPI2 (CM5-based compute modules) and generic Raspberry Pi
- **HALPI2 Interfaces**: CAN bus, RS-485, I2C, UART
- **CI/CD**: GitHub Actions on ARM64 runners
- **Package Repository**: apt.hatlabs.fi

## Related Documentation

- **Pi-gen upstream**: https://github.com/RPi-Distro/pi-gen
- **Legacy images**: `openplotter-halpi` repository - OpenPlotter and HALPI (CM4) images (Bookworm)
