#!/bin/bash

set -euo pipefail

# Function to check if required dependencies are installed
check_dependencies() {
    local deps=("go" "curl" "jq" "systemctl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: Required dependency '$dep' is not installed."
            exit 1
        fi
    done
}

# Main installation logic
if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run as a regular user."
    exit 1
fi

check_dependencies

# Define XDG directories
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Build the binary assuming we are in the repo directory
go build -o openlinkhub_tray || { echo "Error: Failed to build the binary."; exit 1; }

# Install binary to XDG-compliant user directory
mkdir -p "$BIN_DIR"
cp openlinkhub_tray "$BIN_DIR/" || { echo "Error: Failed to copy binary to $BIN_DIR."; exit 1; }

# Create systemd user service in XDG-compliant directory
mkdir -p "$CONFIG_DIR/systemd/user/"
cat > "$CONFIG_DIR/systemd/user/openlinkhub-tray.service" <<EOF
[Unit]
Description=OpenLinkHub System Tray Application
After=graphical-session.target network-online.target
ExecCondition=/bin/bash -c 'code=\$(curl -s -f http://127.0.0.1:27003/api/ | jq -r .code) && [ "\$code" = "200" ]'

[Service]
ExecStart=$BIN_DIR/openlinkhub_tray -ip 127.0.0.1 -port 27003
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to create systemd service file."
    exit 1
fi

# Automatically reload daemon, enable, and start the service
systemctl --user daemon-reload
systemctl --user enable --now openlinkhub-tray.service || { echo "Warning: Failed to enable or start the service. You may need to check systemctl --user status openlinkhub-tray.service."; }

echo "Installation completed successfully. The service has been enabled and started."
