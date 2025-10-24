# Halos Headless Stage

This stage contains configurations specific to headless Halos variants that need immediate network accessibility.

**Included in:** Headless variants only (not desktop variants with first-boot wizard)

**Design Philosophy:**
- Headless variants need immediate network access for web-based configuration
- Uses dual WiFi approach: wlan0 for client connections, wlan9 for AP mode
- NetworkManager-based configuration for reliability and integration

**Tasks:**
- **00-setup-wlan-ap/**: Configure WiFi Access Point using NetworkManager for immediate network access

## WiFi Access Point Configuration

**Default Settings:**
- **SSID:** Halos-HALPI2
- **Password:** halos1234
- **Interface:** wlan9 (virtual AP interface)
- **IP Range:** Managed by NetworkManager (shared method)

**Technical Implementation:**
- Creates virtual WiFi interface (wlan9) for AP mode
- Keeps wlan0 available for client connections to existing networks
- Uses NetworkManager connection profiles instead of hostapd/dnsmasq
- Systemd service creates virtual interface at boot
- IPv4 method "shared" provides automatic DHCP and NAT
