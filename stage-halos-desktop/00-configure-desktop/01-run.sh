#!/bin/bash -e

# Create user's wf-panel-pi config directory
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/wf-panel-pi"

# Configure panel launchers
PANEL_CONFIG="${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/wf-panel-pi/wf-panel-pi.ini"

if [ -f "${PANEL_CONFIG}" ]; then
    # File exists, validate and update launchers line
    if grep -Eq '^[[:space:]]*launchers[[:space:]]*=' "${PANEL_CONFIG}"; then
        # Update the launchers line, allowing for spaces around '='
        sed -i -E 's/^([[:space:]]*launchers[[:space:]]*=[[:space:]]*)(.*)$/\1\2 cockpit homarr/' "${PANEL_CONFIG}"
    else
        # Add launchers line if it does not exist
        echo "launchers=cockpit homarr" >> "${PANEL_CONFIG}"
    fi
else
    # File doesn't exist, install default configuration
    install -m 644 -o 1000 -g 1000 files/wf-panel-pi.ini "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config/wf-panel-pi/"
fi
