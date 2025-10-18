# HALPI2 OS Images

Raspberry Pi OS images customized for the HALPI2 hardware.

The built images include:
- Raspberry Pi OS Lite with HALPI2 customizations
- Raspberry Pi OS with Desktop and HALPI2 customizations
- HaLOS: Containerized Raspberry Pi OS for HALPI2 with common marine applications pre-installed
- HaLOS-Lite: Containerized Raspberry Pi OS Lite for HALPI2 with common marine applications pre-installed
- HaLOS-Generic: Containerized Raspberry Pi OS for generic Raspberry Pi hardware with common marine applications pre-installed
- HaLOS-Generic-Lite: Containerized Raspberry Pi OS Lite for generic Raspberry Pi hardware with common marine applications pre-installed

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
