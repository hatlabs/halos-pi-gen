#!/bin/bash -e

# Install a wrapper for the netplan systemd generator that prevents
# a D-Bus deadlock during daemon-reload (see files/netplan for details).
# /etc/systemd/system-generators/ takes precedence over
# /usr/lib/systemd/system-generators/, so this overrides the package default.
install -D -m 755 files/netplan "${ROOTFS_DIR}/etc/systemd/system-generators/netplan"
