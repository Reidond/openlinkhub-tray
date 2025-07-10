#!/bin/bash

set -euo pipefail

# Function to check if required dependencies are installed
check_dependencies() {
    local deps=("git" "go" "curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: Required dependency '$dep' is not installed."
            exit 1
        fi
    done
}

# Function for installation
install() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Installation must be run as root."
        exit 1
    fi

    check_dependencies

    local tempdir
    tempdir=$(mktemp -d) || { echo "Error: Failed to create temporary directory."; exit 1; }

    go build -o openlinkhub_tray || { echo "Error: Failed to build the binary."; rm -rf "$tempdir"; exit 1; }
    cp openlinkhub_tray /usr/local/bin/ || { echo "Error: Failed to copy binary to /usr/local/bin."; rm -rf "$tempdir"; exit 1; }

    cat > /etc/systemd/user/openlinkhub-tray.service <<EOF
[Unit]
Description=OpenLinkHub System Tray Application
After=graphical-session.target network-online.target
ExecCondition=/bin/bash -c 'code=\$(curl -s -f http://127.0.0.1:27003/api/ | jq -r .code) && [ "\$code" = "200" ]'

[Service]
ExecStart=/usr/local/bin/openlinkhub_tray -ip 127.0.0.1 -port 27003
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create systemd service file."
        rm -rf "$tempdir"
        exit 1
    fi

    rm -rf "$tempdir"

    echo "Installation completed successfully."
    echo "To enable and start the service for a user, execute: systemctl --user enable --now openlinkhub-tray.service"
}

# Function for uninstallation
uninstall() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: Uninstallation must be run as root."
        exit 1
    fi

    rm -f /usr/local/bin/openlinkhub_tray
    rm -f /etc/systemd/user/openlinkhub-tray.service

    echo "Uninstallation completed successfully."
    echo "If the service was enabled for any user, disable it manually with: systemctl --user disable --now openlinkhub-tray.service"
    echo "You may also need to run 'systemctl --user daemon-reload' for each affected user."
}

# Main script logic
if [ $# -ne 1 ]; then
    echo "Usage: $0 {install|uninstall}"
    exit 1
fi

case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Error: Invalid argument. Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
