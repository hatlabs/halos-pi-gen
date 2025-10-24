# HaLOS Image Builder

This repository builds HaLOS (Hat Labs Operating System) images using pi-gen. For the overall project architecture, see [../CLAUDE.md](../CLAUDE.md).

**pi-gen Documentation:** https://raw.githubusercontent.com/RPi-Distro/pi-gen/refs/heads/master/README.md

## Git Workflow Policy

**IMPORTANT:** Always ask the user before:
- Committing files to git
- Pushing commits to remote repositories
- Creating or modifying git tags
- Running destructive git operations

## Project Overview

HaLOS is a Raspberry Pi OS (Trixie) distribution with pre-installed Cockpit and CasaOS web management interfaces. This repository uses the official `pi-gen` image builder with custom stages to create HaLOS images for HALPI2 and generic Raspberry Pi hardware.

**Key Features:**
- **Cockpit** (port 9090): Web-based system administration
- **CasaOS** (port 80/443): Container and app management
- **Marine variants**: Pre-configured Signal K, InfluxDB, Grafana
- **HALPI2 support**: Hardware drivers for HALPI2

**Not in this repository:** Legacy OpenPlotter and HALPI (CM4) images are maintained in the separate `openplotter-halpi` repository (Bookworm-based).

## ⚠️ CRITICAL: Offline Operation Requirement

**IMPORTANT:** HaLOS is designed for marine environments where **internet connectivity may NOT be available during first boot**.

**Mandatory Requirements:**
1. **All Docker images required for first boot MUST be pre-loaded** in the built image
2. **No network connectivity can be assumed** on first boot
3. **All core services must be operational** without internet access

This currently applies to:
- **CasaOS Docker image** (`dockurr/casa:X.Y.Z`) - required by casaos-docker-service package

## Image Variants

Each variant is defined by a `config.*` file that specifies which stages to include:

| Config File | Image Name | Hardware | Desktop? | Marine? |
|-------------|------------|----------|----------|---------|
| `config.halos-marine-halpi2` | HaLOS-Marine-HALPI2 | HALPI2 | Yes | Yes |
| `config.halos-marine-lite-halpi2` | HaLOS-Marine-Lite-HALPI2 | HALPI2 | No | Yes |
| `config.halos-halpi2` | HaLOS-HALPI2 | HALPI2 | Yes | No |
| `config.halos-lite-halpi2` | HaLOS-Lite-HALPI2 | HALPI2 | No | No |
| `config.halos-marine-rpi` | HaLOS-Marine-RPI | Generic Pi | Yes | Yes |
| `config.halos-marine-lite-rpi` | HaLOS-Marine-Lite-RPI | Generic Pi | No | Yes |
| `config.halos-rpi` | HaLOS-RPI | Generic Pi | Yes | No |
| `config.halos-lite-rpi` | HaLOS-Lite-RPI | Generic Pi | No | No |

**Variant dimensions:**
- **Hardware**: HALPI2 vs Generic Raspberry Pi
- **Desktop**: Full desktop environment vs Lite (headless)
- **Marine**: Pre-installed marine stack vs base system only

## Build Commands

### Quick Start

```bash
# Build a specific variant
./run docker-build "HaLOS-Marine-HALPI2"

# Build all enabled variants
./run docker-build-all

# Clean up Docker containers
./run docker-clean
```

### Using act for Local CI Testing

```bash
# Test PR workflow locally
act pull_request --container-architecture linux/arm64

# List available workflows
act -l

# Run specific job
act pull_request -j build-halos-marine-halpi2
```

**Requirements:**
- Docker installed and running
- [act](https://github.com/nektos/act) for local CI testing (optional)
- [gh](https://github.com/cli/cli) CLI tool (optional, for workflows)
- Sufficient disk space (~20GB per variant)

### Build Output

Built images are placed in:
- Local builds: `deploy/`
- CI builds: `artifacts/`

Files created:
- `<variant-name>-<date>.img.xz`: Compressed disk image
- `<variant-name>-<date>.img.xz.sha256`: Checksum file
- `build.log`: Detailed build log

## Architecture

### Build System Structure

The project is based on Raspberry Pi's `pi-gen` builder, which uses a stage-based approach. During build:

1. The `pi-gen` repository is cloned (arm64 branch)
2. Custom HaLOS stage directories are copied into `pi-gen/`
3. A config file is copied to `pi-gen/config`
4. The pi-gen Docker builder runs with the custom stages

### Stage System

Pi-gen uses a stage-based system where each stage adds functionality. Stages run in alphanumeric order.

#### Standard Pi-Gen Stages

These come from the upstream pi-gen project:

- **stage0**: Bootstrap - creates minimal Debian root filesystem
- **stage1**: Base system - adds essential packages and configuration
- **stage2**: Raspberry Pi OS Lite - minimal bootable system (Trixie)
- **stage3**: Raspberry Pi OS - adds desktop environment
- **stage4**: Raspberry Pi OS Full - adds additional applications
- **stage5**: Raspberry Pi OS Complete - adds even more applications

#### Custom HaLOS Stages

##### stage-halos-base/
**Applies to:** All HaLOS variants
**Purpose:** Install core web management tools

Tasks:
- **00-install-cockpit/**: Install and configure Cockpit web UI (port 9090)
  - System monitoring and configuration
  - Service management
  - Terminal access
  - File management
- **01-install-casaos/**: Install and configure CasaOS (port 80/443)
  - Docker container management
  - App store interface
  - User-friendly web UI
- **02-configure-services/**: Enable services, configure firewall rules

##### stage-halpi2-common/
**Applies to:** All HALPI2 variants
**Purpose:** Hardware-specific customization for HALPI2

Tasks:
- **00-add-sources/**: Add Hat Labs APT repository (apt.hatlabs.fi)
- **01-enable-i2c/**: Enable I2C interface
- **02-add-halpid/**: Install `halpid` hardware daemon package
- **03-add-halpi2-firmware/**: Install firmware for HALPI2 hardware
- **04-enable-ext-ant/**: Configure external antenna support
- **05-setup-can/**: Configure CAN bus interfaces
- **06-setup-rs485/**: Configure RS-485 serial interfaces
- **07-disable-sd/**: Disable SD card to prevent wear (boot from USB/NVMe)

##### stage-halos-marine/
**Applies to:** Marine variants only
**Purpose:** Pre-configured marine software stack

Tasks:
- **00-install-docker/**: Install Docker CE and Docker Compose
- **01-setup-services/**: Deploy Signal K, InfluxDB, Grafana via docker-compose
  - Files include: `docker-compose.yml`, service configurations
  - Signal K (port 3000): Marine data hub
  - InfluxDB (port 8086): Time-series database
  - Grafana (port 3001): Data visualization
- **02-configure-casaos-store/**: Enable marine app store for CasaOS

##### stage-halpi2-rpi/
**Applies to:** HALPI2 desktop variants
**Purpose:** Desktop-specific HALPI2 customization

Tasks:
- **00-desktop-config/**: Set wallpaper, theme customizations
- **01-vnc-config/**: Configure VNC server for remote desktop

### Stage Execution Details

#### Task Numbering
Within each stage, tasks execute in numeric order (00-, 01-, 02-, etc.).

#### Task Types
Each task directory can contain:
- **00-run.sh**: Script executed on build host (outside chroot)
- **01-run-chroot.sh**: Script executed inside Pi OS filesystem (chroot)
- **00-packages**: List of apt packages to install (one per line)
- **00-packages-nr**: Packages to install without recommendations
- **files/**: Configuration files copied into image

#### Stage Control Files
- **SKIP**: Place in stage directory to skip the entire stage
- **SKIP_IMAGES**: Skip creating `.img` file after this stage
- **EXPORT_IMAGE**: Create `.img` file after this stage completes
- **EXPORT_NOOBS**: Create NOOBS archive after this stage

### Configuration Files

Each image variant has a config file that defines:
- `IMG_NAME`: Output image name
- `STAGE_LIST`: Ordered list of stages to execute
- `DEPLOY_COMPRESSION`: Compression format (xz)
- `COMPRESSION_LEVEL`: Compression level (3 or 6)
- `CONTAINER_NAME`: Docker container name

Example `config.halos-marine-halpi2`:
```bash
IMG_NAME="HaLOS-Marine-HALPI2"
STAGE_LIST="stage0 stage1 stage2 stage-halos-base stage-halpi2-common stage3 stage-halos-marine stage-halpi2-rpi"
DEPLOY_COMPRESSION="xz"
COMPRESSION_LEVEL="6"
CONTAINER_NAME="pigen_work_halos_marine_halpi2"
```

### CI/CD Workflows

**`.github/workflows/pull_request.yml`**: Builds images on PRs and manual triggers
- Runs on ARM64 runners (`ubuntu-latest-arm64`)
- Matrix builds multiple image variants in parallel
- Uploads `.xz` artifacts with 3-day retention
- Uses `pi-gen`'s `arm64` branch with `build-docker.sh`

**`.github/workflows/release.yml`**: Creates GitHub releases
- Triggers on pushes to `main` branch or manual dispatch
- Downloads artifacts from the last successful PR workflow run
- Creates a GitHub release with all image files
- Generates release notes

## Creating New Image Variants

1. **Create config file**: `config.halos-new-variant`

   ```bash
   # Example: HaLOS Marine variant for HALPI2
   IMG_NAME="HaLOS-Marine-HALPI2"
   STAGE_LIST="stage0 stage1 stage2 stage-halos-base stage-halpi2-common stage3 stage-halos-marine stage-halpi2-rpi"
   DEPLOY_COMPRESSION="xz"
   COMPRESSION_LEVEL="6"
   CONTAINER_NAME="pigen_work_halos_marine_halpi2"
   ```

2. **Define stage list**:
   - Start with base pi-gen stages: `stage0 stage1 stage2`
   - Add `stage-halos-base` for Cockpit and CasaOS (required for all HaLOS)
   - Add `stage-halpi2-common` if targeting HALPI2 hardware
   - Add `stage3` for desktop environment (omit for Lite variants)
   - Add `stage-halos-marine` for marine software stack
   - Add `stage-halpi2-rpi` for HALPI2 desktop customizations

3. **Add to CI/CD**: Update `.github/workflows/pull_request.yml` matrix

4. **Test locally**: `./run docker-build "HaLOS-Marine-HALPI2"`

## Common Development Patterns

### Adding a New Stage Task

1. Create a numbered directory in the appropriate stage (e.g., `stage-halpi2-common/08-new-task/`)
2. Add a `00-run.sh` script for host operations or `01-run-chroot.sh` for chroot operations
3. Use `${ROOTFS_DIR}` to reference the root filesystem when writing from host scripts
4. Use `on_chroot << EOF` heredocs in `00-run.sh` to run commands inside the chroot

Example structure:
```bash
stage-halpi2-common/
└── 08-new-task/
    ├── 00-packages          # Optional: packages to install
    ├── 01-run-chroot.sh     # Script runs inside chroot
    └── files/               # Optional: files to copy
        └── config.conf
```

### Installing Packages

Create a `00-packages` file in the task directory with one package name per line.

Example `00-packages`:
```
vim
htop
tmux
```

### Modifying Config Files

Place configuration files in a `files/` subdirectory within the task directory.

Example `01-run-chroot.sh`:
```bash
#!/bin/bash -e

# Copy config file
install -m 644 files/config.conf "${ROOTFS_DIR}/etc/myapp/config.conf"

# Append to existing file
cat files/additional.conf >> "${ROOTFS_DIR}/etc/myapp/main.conf"
```

### Working with pi-gen Variables

Key pi-gen environment variables available in stage scripts:
- `${ROOTFS_DIR}`: Path to the root filesystem being built
- `${STAGE_DIR}`: Current stage directory
- `IMG_NAME`, `IMG_DATE`: Image naming variables from config

### Testing Changes

For faster iteration during development:
1. **Disable unnecessary stages**: Add `SKIP` files to stages you're not testing
2. **Use smaller base**: Start from stage2 instead of stage0 when possible
3. **Test specific tasks**: Manually run task scripts in chroot for quick validation

Full builds take 30+ minutes depending on hardware.

## Modifying Existing Stages

### Adding Hardware Support (HALPI2)
Edit tasks in `stage-halpi2-common/`. Changes automatically affect all HALPI2 variants.

Example: Adding new hardware interface
```bash
cd stage-halpi2-common/08-new-interface
# Create 01-run-chroot.sh to enable new interface
```

### Modifying Web Management
Edit tasks in `stage-halos-base/`.

Example: Changing Cockpit configuration
```bash
cd stage-halos-base/00-install-cockpit
# Edit files/cockpit.conf or 01-run-chroot.sh
```

### Adding Marine Services

**Option 1: Pre-installed service** (recommended for core services)
```bash
cd stage-halos-marine/01-setup-services/files
# Edit docker-compose.yml to add new service
```

**Option 2: CasaOS app store** (recommended for optional apps)
Add app to the separate `casaos-marine-store/` repository. See [../casaos-marine-store/CLAUDE.md](../casaos-marine-store/CLAUDE.md).

## Troubleshooting

### Build Fails in Stage
- Check `deploy/build.log` for detailed error messages
- Look for failed package installations
- Verify network connectivity for package downloads
- Check disk space (builds need ~20GB)

### Docker Issues
```bash
# Clean up failed builds
./run docker-clean

# Remove all build artifacts
rm -rf deploy/ work/

# Reset Docker environment
docker system prune -af
```

### Chroot Debugging
To debug issues inside the build environment:

```bash
# Enter the chroot manually
sudo chroot work/<stage-name>/rootfs /bin/bash

# Test package installation
apt-get update
apt-get install <package-name>
```

### Common Issues

**Issue:** `E: Unable to locate package`
**Solution:** Ensure APT repository is added in earlier stage, run `apt-get update`

**Issue:** Stage scripts fail with permission errors
**Solution:** Ensure scripts have executable permissions (`chmod +x`)

**Issue:** Out of disk space
**Solution:** Clean up old builds, increase disk space, or reduce number of concurrent builds

## Best Practices

### Stage Organization
- Keep stages focused on a single responsibility
- Use descriptive task names (00-install-foo, 01-configure-foo)
- Document complex scripts with comments
- Test stages independently when possible

### Configuration Management
- Use `files/` directories for configuration files
- Avoid hardcoding paths - use variables
- Make configurations conditional on variant type when appropriate

### Package Installation
- Prefer `.deb` packages from apt repositories
- Use `00-packages` files for simple package lists
- Use chroot scripts for complex installation logic
- Pin package versions for reproducible builds (when needed)

### Docker Compose Services
- Use persistent volumes for data
- Set restart policies appropriately
- Document port mappings
- Include health checks

## File Locations Reference

- **Config files**: `config.*`
- **Stage directories**: `stage-*/`
- **Build script**: `./run`
- **Build output**: `deploy/` or `artifacts/`
- **Build workspace**: `work/` (temporary)
- **CI workflows**: `.github/workflows/`

## Related Documentation

- **Parent project**: [../CLAUDE.md](../CLAUDE.md) - Overall HaLOS architecture
- **CasaOS**: [../casaos-docker-service/CLAUDE.md](../casaos-docker-service/CLAUDE.md) - CasaOS deployment
- **Marine apps**: [../casaos-marine-store/CLAUDE.md](../casaos-marine-store/CLAUDE.md) - App store content
- **Pi-gen upstream**: https://github.com/RPi-Distro/pi-gen
- **Legacy images**: `openplotter-halpi` repository - OpenPlotter and HALPI (CM4) images (Bookworm)
