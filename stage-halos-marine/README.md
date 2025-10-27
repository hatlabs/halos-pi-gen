# Stage: halos-marine

Configures the marine stack for HaLOS, including:
- Runtipi Marine App Store (preconfigured)
- Signal K Server docker image (preloaded)

## Structure

### 00-configure-marine-appstore
Configures the runtipi-marine-app-store as an additional app store in Runtipi.
- Clones marine app store repository from GitHub to `/opt/runtipi/repos/marine/`
- Creates systemd service to add app store on first boot using `runtipi-cli appstore add`
- Makes marine apps (Signal K, InfluxDB) available for installation

### 01-pull-signalk-image
Preloads the Signal K docker image into the system image.
- Uses skopeo to pull `signalk/signalk-server:v2.17.2-24.x` (Docker Hub)
- Saves image to `/opt/runtipi/images/signalk.tar`
- Will be loaded on first boot by the existing `load-runtipi-images.service`
- Makes Signal K installation instant (no download required)

## Installation

Signal K is **not** automatically installed. After first boot:
1. Access Runtipi dashboard (port 80)
2. Navigate to Marine app store
3. Click "Install" on Signal K (instant - image preloaded)

## Future Enhancement

**TODO**: Once runtipi-cli adds an `app install` subcommand (see [runtipi/cli#XXX](https://github.com/runtipi/cli/issues/XXX)), add automatic Signal K installation via systemd service.

## Usage

This stage is included in the `config.halos-marine-halpi2` variant.

```bash
./run docker:build "HaLOS-Marine-HALPI2"
```

## Dependencies

- stage-halos-base (Runtipi must be installed)
- Marine app store: https://github.com/hatlabs/runtipi-marine-app-store
