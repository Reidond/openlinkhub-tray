#!/bin/bash

set -euo pipefail

# Function to check if required dependencies are installed
check_dependencies() {
    local deps=("systemctl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: Required dependency '$dep' is not installed."
            exit 1
        fi
    done
}

# Main uninstallation logic
if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run as a regular user."
    exit 1
fi

check_dependencies

# Define XDG directories
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Disable and stop the service if it exists
if systemctl --user is-active --quiet openlinkhub-tray.service || systemctl --user is-enabled --quiet openlinkhub-tray.service; then
    systemctl --user disable --now openlinkhub-tray.service || { echo "Warning: Failed to disable or stop the service."; }
fi

rm -f "$BIN_DIR/openlinkhub_tray"
rm -f "$CONFIG_DIR/systemd/user/openlinkhub-tray.service"

# Reload daemon after removal
systemctl --user daemon-reload

echo "Uninstallation completed successfully."
