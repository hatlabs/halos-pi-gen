# HaLOS Image Builder

Builds HaLOS (Hat Labs Operating System) images using pi-gen for HALPI2 and generic Raspberry Pi.

## Git Workflow Policy

**IMPORTANT:** Always ask before committing, pushing, tagging, or running destructive git operations.

## Image Variants

### Stock Raspberry Pi OS (HALPI2-customized)
- `config.raspios-lite-halpi2` → **raspios-lite-halpi2**: Headless Raspberry Pi OS with HALPI2 drivers
- `config.raspios-halpi2` → **raspios-halpi2**: Desktop Raspberry Pi OS with HALPI2 drivers

### HaLOS for HALPI2 Hardware
Cockpit + Runtipi web management + HALPI2 drivers:
- `config.halos-halpi2` → **Halos-HALPI2**: Headless HaLOS for HALPI2
- `config.halos-desktop-halpi2` → **Halos-Desktop-HALPI2**: Desktop HaLOS for HALPI2
- `config.halos-marine-halpi2` → **Halos-Marine-HALPI2**: Headless marine HaLOS for HALPI2
- `config.halos-desktop-marine-halpi2` → **Halos-Desktop-Marine-HALPI2**: Desktop marine HaLOS for HALPI2

### HaLOS for Generic Raspberry Pi
Cockpit + Runtipi web management (no HALPI2-specific drivers):
- `config.halos-rpi` → **Halos-RPI**: Headless HaLOS for generic RPi
- `config.halos-desktop-rpi` → **Halos-Desktop-RPI**: Desktop HaLOS for generic RPi
- `config.halos-marine-rpi` → **Halos-Marine-RPI**: Headless marine HaLOS for generic RPi
- `config.halos-desktop-marine-rpi` → **Halos-Desktop-Marine-RPI**: Desktop marine HaLOS for generic RPi

## Building Images

```bash
# Build specific variant
./run docker:build "Halos-Marine-HALPI2"

# Build all enabled variants
./run docker:build-all

# Clean up
./run docker:clean
```

## Stage System

Pi-gen uses stages (run in order). Custom HaLOS stages:

- **stage-halos-base**: Cockpit + Runtipi (all variants)
- **stage-halpi2-common**: HALPI2 hardware drivers, firmware, interfaces
- **stage-halos-marine**: Marine stack (marine app store, preinstalled marine apps)

**Files:** `stage-*/` directories contain numbered tasks (00-, 01-, 02-). Each task can have: `00-run.sh` (host), `01-run-chroot.sh` (chroot), `00-packages` (apt packages), `files/` (config files).

**Config:** Each `config.*` file defines IMG_NAME, STAGE_LIST, compression. Example:
```bash
IMG_NAME="Halos-Marine-HALPI2"
STAGE_LIST="stage0 stage1 stage2 stage-halos-base stage-halpi2-common stage3 stage-halos-marine"
```

## CI/CD

- **`.github/workflows/pull_request.yml`**: Builds on PRs (ARM64 runners)
- **`.github/workflows/release.yml`**: Creates releases with artifacts

## Related

- **Parent**: [../CLAUDE.md](../CLAUDE.md)
- **Runtipi**: [../runtipi-docker-service/CLAUDE.md](../runtipi-docker-service/CLAUDE.md)
- **Marine apps**: [../runtipi-marine-app-store/CLAUDE.md](../runtipi-marine-app-store/CLAUDE.md)
- **Legacy images**: `openplotter-halpi` repository (Bookworm)
