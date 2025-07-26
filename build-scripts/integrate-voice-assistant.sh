#!/bin/bash
# Install and configure Mycroft AI voice assistant for AASMI OS

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Installing Mycroft AI voice assistant..."

# Check for internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
    echo "Error: No internet connectivity. Mycroft AI installation requires an active internet connection."
    exit 1
fi

# Update package lists
apt-get update

# Install dependencies
echo "Installing Mycroft dependencies..."
apt-get install -y git python3 python3-pip python3-venv pulseaudio ffmpeg libjpeg-dev zlib1g-dev portaudio19-dev

# Clone Mycroft core repository
MYCROFT_DIR="/opt/mycroft-core"
if [ ! -d "$MYCROFT_DIR" ]; then
  echo "Cloning Mycroft core repository into $MYCROFT_DIR..."
  git clone https://github.com/MycroftAI/mycroft-core.git "$MYCROFT_DIR"
else
  echo "Mycroft core repository already exists at $MYCROFT_DIR. Skipping clone."
fi

cd "$MYCROFT_DIR"

# Checkout stable release
echo "Checking out Mycroft stable release..."
git fetch --all
git checkout stable

# Setup Mycroft environment
# Note: --allow-root is used here as per original script. For production,
# it's generally better to run Mycroft as a dedicated non-root user.
echo "Setting up Mycroft environment. This may take some time..."
./dev_setup.sh --allow-root

# Enable Mycroft service to start on boot
echo "Enabling Mycroft service to start on boot..."
# Mycroft's dev_setup.sh should handle systemd service setup, but we ensure it's enabled.
systemctl daemon-reload # Reload systemd units
systemctl enable mycroft.service || { echo "Warning: Could not enable mycroft.service. It might not be available yet."; }

echo "Mycroft AI installation completed."

echo "Starting Mycroft service..."
systemctl start mycroft.service || { echo "Warning: Could not start mycroft.service. Please check its status."; }

echo "Voice assistant integration completed. You may need to configure Mycroft settings after first boot."