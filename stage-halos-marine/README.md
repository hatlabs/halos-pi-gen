# stage-halos-marine

This stage adds marine navigation and monitoring software to HaLOS.

## What it Does

Installs the `halos-marine` metapackage from apt.hatlabs.fi, which provides:

- **marine-container-store** - Marine app store for Docker-based marine applications
- **signalk-server-container** - Signal K server for marine data collection

The `halos-marine` metapackage depends on `halos`, so the base system is automatically included.

## Structure

```
stage-halos-marine/
├── 00-install-halos-marine/
│   └── 00-packages      # halos-marine metapackage
├── 01-setup-gpsd/
│   └── 01-run.sh        # Default gpsd config (HALPI2 overrides in stage-halpi2-marine)
├── prerun.sh
└── README.md
```

## Dependencies

- **stage-hatlabs-common** must run before this stage to add the apt.hatlabs.fi repository
- **stage-halos-base** provides the base HaLOS system (automatically satisfied via metapackage dependency)

## Applies To

This stage is included in marine HaLOS image variants:
- Halos-Marine-HALPI2
- Halos-Marine-RPI
- Halos-Desktop-Marine-HALPI2
- Halos-Desktop-Marine-RPI
