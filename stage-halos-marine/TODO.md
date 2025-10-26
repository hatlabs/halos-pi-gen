# TODO: Automatic Signal K Installation

## Status
**Blocked** - Waiting for runtipi-cli to add `app install` subcommand.

## GitHub Issue
Track progress at: https://github.com/runtipi/cli/issues/XXX
(Update with actual issue number)

## Implementation Plan

Once runtipi-cli adds the `app install` command, implement automatic Signal K installation:

### 1. Create `02-autoinstall-signalk/00-run-chroot.sh`

This script should:
- Create a systemd one-shot service: `install-signalk.service`
- Service should run after:
  - `add-marine-appstore.service`
  - `load-runtipi-images.service`
  - `runtipi.service`

### 2. Service Implementation

```bash
[Unit]
Description=Install Signal K App
After=add-marine-appstore.service load-runtipi-images.service runtipi.service
Requires=runtipi.service

[Service]
Type=oneshot
# Wait for Runtipi to be ready
ExecStartPre=/bin/bash -c 'for i in {1..60}; do docker exec runtipi-db pg_isready -U tipi 2>/dev/null && break || sleep 2; done'
# Wait for app store to be added
ExecStartPre=/bin/sleep 10
# Install Signal K using runtipi-cli
ExecStart=/bin/bash -c 'cd /opt/runtipi && ./runtipi-cli app install marine/signalk'
# Disable service after successful execution
ExecStartPost=/bin/systemctl disable install-signalk.service
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### 3. Testing

1. Test on halpi2.local first with new runtipi-cli
2. Verify correct command syntax (check if it's `marine/signalk` or `marine signalk`)
3. Ensure service handles errors gracefully
4. Verify Signal K starts automatically

### 4. Documentation

Update `README.md`:
- Remove "Future Enhancement" section
- Update "Installation" section to note automatic installation
- Document that Signal K will be running on port 3000 after first boot
