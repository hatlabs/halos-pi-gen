# Halos Headless Stage

This stage contains configurations specific to headless Halos variants.

**Included in:** Headless variants only (not desktop variants with first-boot wizard)

## Network Access for Headless Variants

Headless variants include a default WiFi Access Point for initial setup:

- **SSID:** `Halos-XXXX` (where XXXX is the last 4 hex digits of the device's WiFi MAC address)
- **Password:** `halos1234`
- **IP Address:** Connect and access the device at `10.42.0.1`

The unique SSID allows multiple HaLOS devices to be set up simultaneously without SSID conflicts.

Additional access methods:

1. **Pre-configured WiFi** (recommended): Configure WiFi credentials in Raspberry Pi Imager before flashing
2. **Ethernet**: Connect via ethernet cable to access Cockpit web UI

Once connected, WiFi AP mode can be managed through the Cockpit NetworkManager interface (cockpit-networkmanager-halos), which supports simultaneous STA+AP mode using a virtual `wlan0ap` interface.

## WiFi STA+AP Mode

The STA+AP feature ensures that both WiFi client and Access Point modes can operate simultaneously:

- **Base support** (`stage-halos-base/02-configure-wifi-sta-ap/`): Restricts pre-configured WiFi credentials from RPi Imager to `wlan0`, keeping the virtual AP interface (`wlan0ap`) available
- **Default AP** (`00-setup-default-ap/`): Creates the `wlan0ap` interface at boot and generates a default AP connection with unique SSID (`Halos-XXXX`) and low priority (`autoconnect-priority=-100`), so it only activates when no higher-priority connections are available

See cockpit-networkmanager-halos for AP management functionality.
