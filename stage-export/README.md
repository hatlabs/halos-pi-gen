# Terminal Export Stage

**Purpose:** This is a terminal stage that triggers image export. It contains only the `EXPORT_IMAGE` file and performs no functional changes to the image.

**Design Philosophy:**
- Provides explicit control over when image export happens
- Single reusable stage for all image variants
- Prevents multiple export points in complex stage compositions
- Must be the last stage in `STAGE_LIST`

**Usage:**
All image variants should append this stage as their final stage:

```bash
STAGE_LIST="... stage-halos-base stage-halos-headless stage-export"
```

**Used by:**
- `config.halos-halpi2` - Headless Halos for HALPI2
- `config.halos-desktop-halpi2` - Desktop Halos for HALPI2
- `config.raspios-halpi2` - RaspiOS Desktop for HALPI2
- `config.raspios-lite-halpi2` - RaspiOS Lite for HALPI2
