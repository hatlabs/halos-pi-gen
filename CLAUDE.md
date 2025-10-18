# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository builds customized Raspberry Pi OS images for the HALPI2 hardware (Hat Labs' Raspberry Pi computers). The project uses the official `pi-gen` image builder with custom stage directories to create marine-focused OS images with hardware customizations.

The built images include:
- **Raspios-HALPI2**: Full desktop Raspberry Pi OS with HALPI2 hardware support
- **Raspios-lite-HALPI2**: Lite/headless Raspberry Pi OS with HALPI2 hardware support
- **OpenPlotter-HALPI2**: Desktop image with OpenPlotter, SignalK, OpenCPN, and XyGrib pre-installed

## Build Commands

### Local Development Build

Build all images locally using `act` to simulate GitHub Actions:

```bash
./run docker-build
```

Build a specific image by job name:

```bash
./run docker-build-image "Raspios-HALPI2"
./run docker-build-image "Raspios-lite-HALPI2"
```

Available job names match the matrix names in `.github/workflows/pull_request.yml`:
- `Raspios-HALPI2` - Full desktop image
- `Raspios-lite-HALPI2` - Lite/headless image
- `OpenPlotter-HALPI2` - OpenPlotter image (when uncommented in workflow)

These commands require:
- Docker installed and running
- `act` GitHub Actions local runner installed
- `gh` CLI tool installed and authenticated

Built image files are placed in the `artifacts/` directory as `.xz` compressed files.

### Clean Docker Containers

Remove lingering pi-gen Docker containers:

```bash
./run docker-clean
```

## Architecture

### Build System Structure

The project is based on Raspberry Pi's `pi-gen` builder, which uses a stage-based approach. During build:

1. The `pi-gen` repository is cloned (arm64 branch)
2. Custom stage directories are copied into the `pi-gen/` directory
3. A config file is copied to `pi-gen/config`
4. The pi-gen Docker builder runs with the custom stages

### Stage System

Stages are processed sequentially. Each stage directory can contain:
- `prerun.sh`: Runs before the stage
- `XX-taskname/`: Numbered subdirectories for tasks (executed in order)
  - `00-run.sh`: Shell script executed on the host system
  - `01-run-chroot.sh`: Shell script executed inside the chroot
  - `00-packages`: List of packages to install
  - `files/`: Files to copy into the image
- `SKIP`: Marker to skip this stage
- `SKIP_IMAGES`: Process stage but don't create an image afterward
- `EXPORT_IMAGE`: Create final image after this stage

### Stage Directories

Custom stages in this repository:

**Common preparation stages:**
- `stage-pre-halpi2-rpi`: Preparation for Raspberry Pi-based builds
- `stage-pre-halpi-op`: Preparation for OpenPlotter builds
- `stage-pre-openplotter`: Additional OpenPlotter preparation

**OpenPlotter stages:**
- `stage-openplotter`: Installs OpenPlotter, SignalK, OpenCPN, XyGrib

**HALPI2 customization stages:**
- `stage-halpi2-common`: Hardware customizations applied to all HALPI2 images:
  - `00-add-sources`: Adds Hat Labs APT repository
  - `01-enable-i2c`: Enables I2C interface
  - `02-add-halpid`: Installs `halpid` package
  - `03-add-halpi2-firmware`: Installs firmware for HALPI2 hardware
  - `04-enable-ext-ant`: Configures external antenna support
  - `05-setup-can`: Configures CAN bus interfaces
  - `06-setup-rs485`: Configures RS-485 serial interfaces
  - `07-disable-sd`: Disables SD card to prevent wear
- `stage-halpi2-rpi`: Desktop-specific customizations (wallpaper)
- `stage-halpi2-rpi-lite`: Lite/headless-specific customizations
- `stage-halpi2-op`: OpenPlotter-specific HALPI2 customizations

**Legacy stages:**
- `stage-halpi`: Original HALPI (non-HALPI2) customizations

### Configuration Files

Each image variant has a config file that defines:
- `IMG_NAME`: Output image name
- `STAGE_LIST`: Ordered list of stages to execute
- `DEPLOY_COMPRESSION`: Compression format (xz)
- `COMPRESSION_LEVEL`: Compression level (3 or 6)
- `CONTAINER_NAME`: Docker container name

Active configs:
- `config.rpi-halpi2`: Full desktop HALPI2 image
- `config.rpi-lite-halpi2`: Lite/headless HALPI2 image
- `config.openplotter-halpi2`: OpenPlotter HALPI2 image (currently commented out in CI)

### CI/CD Workflows

**`.github/workflows/pull_request.yml`**: Builds images on PRs and manual triggers
- Runs on ARM64 runners (`ubuntu-latest-arm64`)
- Matrix builds multiple image variants in parallel
- Uploads `.xz` artifacts with 3-day retention
- Uses `pi-gen`'s `arm64` branch with `build-docker.sh`

**`.github/workflows/release.yml`**: Creates GitHub releases
- Triggers on pushes to `main` branch
- Downloads artifacts from the last successful PR workflow run
- Creates a draft GitHub release with all image files

## Common Development Patterns

### Adding a New Stage Task

1. Create a numbered directory in the appropriate stage (e.g., `stage-halpi2-common/08-new-task/`)
2. Add a `00-run.sh` script for host operations or `01-run-chroot.sh` for chroot operations
3. Use `${ROOTFS_DIR}` to reference the root filesystem when writing from host scripts
4. Use `on_chroot << EOF` heredocs in `00-run.sh` to run commands inside the chroot

### Installing Packages

Create a `00-packages` file in the task directory with one package name per line. The pi-gen system will automatically install these packages.

### Modifying Config Files

Place configuration files in a `files/` subdirectory within the task directory. Use scripts to copy or append them to the appropriate locations in `${ROOTFS_DIR}`.

### Testing Changes

When modifying stages, test locally with `./run docker-build` before pushing. Note that full builds can take significant time (30+ minutes depending on hardware).

### Working with pi-gen Variables

Key pi-gen environment variables available in stage scripts:
- `${ROOTFS_DIR}`: Path to the root filesystem being built
- `${STAGE_DIR}`: Current stage directory
- `IMG_NAME`, `IMG_DATE`: Image naming variables from config
