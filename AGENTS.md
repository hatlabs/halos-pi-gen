⚠️ **THESE RULES ONLY APPLY TO FILES IN /halos-pi-gen/** ⚠️

# HaLOS Image Builder

Builds HaLOS (Hat Labs Operating System) images using pi-gen for HALPI2 and generic Raspberry Pi.

**Local Instructions**: For environment-specific instructions and configurations, see @CLAUDE.local.md (not committed to version control).

## Git Workflow Policy

**IMPORTANT:** Always ask before pushing, creating/pushing tags, or running destructive git operations that affect remote repositories. Local commits and branch operations are fine.

## Image Variants

### Stock Raspberry Pi OS (HALPI2-customized)
- `config.raspios-lite-halpi2` → **raspios-lite-halpi2**: Headless Raspberry Pi OS with HALPI2 drivers
- `config.raspios-halpi2` → **raspios-halpi2**: Desktop Raspberry Pi OS with HALPI2 drivers

### HaLOS for HALPI2 Hardware
Cockpit web management + HALPI2 drivers:
- `config.halos-halpi2` → **Halos-HALPI2**: Headless HaLOS for HALPI2
- `config.halos-desktop-halpi2` → **Halos-Desktop-HALPI2**: Desktop HaLOS for HALPI2
- `config.halos-marine-halpi2` → **Halos-Marine-HALPI2**: Headless marine HaLOS for HALPI2
- `config.halos-desktop-marine-halpi2` → **Halos-Desktop-Marine-HALPI2**: Desktop marine HaLOS for HALPI2
- `config.halos-desktop-marine-halpi2-ap` → **Halos-Desktop-Marine-HALPI2-AP**: Desktop marine HaLOS for HALPI2 with default AP (pre-installation image)

### HaLOS for Generic Raspberry Pi
Cockpit web management (no HALPI2-specific drivers):
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

- **stage-halos-base**: Cockpit + Docker (all variants)
- **stage-halpi2-common**: HALPI2 hardware drivers, firmware, interfaces
- **stage-halos-marine**: Marine stack (marine app store, preinstalled marine apps)

**Files:** `stage-*/` directories contain numbered tasks (00-, 01-, 02-). Each task can have: `00-run.sh` (host), `01-run-chroot.sh` (chroot), `00-packages` (apt packages), `files/` (config files).

**Config:** Each `config.*` file defines IMG_NAME, STAGE_LIST, compression. Example:
```bash
IMG_NAME="Halos-Marine-HALPI2"
STAGE_LIST="stage0 stage1 stage2 stage-halos-base stage-halpi2-common stage3 stage-halos-marine"
```

## CI/CD

- **`.github/workflows/pr.yml`**: Lightweight PR checks via shared workflow (shellcheck, stage/config validation)
- **`.github/workflows/main.yml`**: Builds all image variants on push to main, then creates a draft GitHub release

## Related

- **Parent**: [../AGENTS.md](../AGENTS.md)
- **Marine containers**: [../halos-marine-containers/AGENTS.md](../halos-marine-containers/AGENTS.md)
- **Legacy images**: `openplotter-halpi` repository (Bookworm)
