# HALPI2 OS Images

Raspberry Pi OS images customized for the HALPI2 hardware.

The built images include:

**Stock Raspberry Pi OS (HALPI2-customized):**
- Raspios-lite-HALPI2: Headless Raspberry Pi OS with HALPI2 drivers
- Raspios-HALPI2: Desktop Raspberry Pi OS with HALPI2 drivers

**Halos Images** (Cockpit + Runtipi web management):
- Halos-HALPI2: Headless for HALPI2 hardware
- Halos-Desktop-HALPI2: Desktop for HALPI2 hardware

**Halos Marine Images** (adds Signal K, InfluxDB, Grafana):
- Halos-Marine-HALPI2: Headless marine for HALPI2
- Halos-Desktop-Marine-HALPI2: Desktop marine for HALPI2

## Downloading the Images

The images are available for download on the [releases page](https://github.com/hatlabs/halos/releases).

## Flashing the Images

The images can be flashed to an SSD drive (or a micro-SD card) using the Raspberry Pi Imager. The Raspberry Pi Imager can be downloaded from the [Raspberry Pi website](https://www.raspberrypi.org/software/). Use an SSD USB adapter to connect the SSD drive to your computer. Open the Raspberry Pi Imager and select the OpenPlotter-HALPI image you downloaded. Select the SSD drive as the target and click Write. Do not apply any customizations.

## Building the Images

The image can be built manually using the [act](https://nektosact.com/) GitHub Actions local runner. You also need Docker installed and running on your computer, and the GH-CLI GitHub command line tool needs to be installed and configured.

With the prerequisites in place, run the following commands to build the image:

```bash
./run docker-build
```

This command will mimic the GitHub Actions workflow and build the images locally. The image files are stored in the `artifacts` directory. All artifacts are zip files that can be extracted to get the `xz` compressed image files. The image can then be flashed to an SSD drive or SD card using the Raspberry Pi Imager as described above.
