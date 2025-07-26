#!/bin/bash
# Build live OS image and create bootable ISO for AASMI OS

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Starting live OS image build..."

# Install live-build if not installed
if ! command -v lb >/dev/null 2>&1; then
  echo "Installing live-build tool..."
  apt-get update
  apt-get install -y live-build
fi

# Define the base directory of the project
PROJECT_BASE_DIR=$(dirname "$(dirname "$(readlink -f "$0")")") # This gets the directory two levels up from this script

# Create build directory and navigate into it
BUILD_DIR="${PROJECT_BASE_DIR}/live-build-output" # Changed to a more descriptive name
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Cleaning previous build artifacts..."
lb clean # Clean previous build

# Configure live-build for AASMI OS
echo "Configuring live-build..."
lb config \
  --architecture amd64 \
  --distribution bookworm \
  --archive-areas "main contrib non-free" \
  --debian-installer false \
  --bootappend-live "boot=live persistence persistence-label=AASMI_PERSIST" \
  --binary-images iso-hybrid \
  --apt-indices false \
  --updates true \
  --security true \
  --backports false \
  --firmware-chroot true \
  --firmware-binary true \
  --iso-volume "AASMI_OS" \
  --iso-preparer "AASMI OS Team" \
  --iso-publisher "AASMI OS" \
  --iso-application "AASMI OS Live" \
  --memtest none \
  --chroot-packages "live-task-xfce" # Ensure XFCE task is included properly

# Copy custom files into chroot environment
echo "Copying custom files into chroot..."

# Create necessary directories in the chroot
mkdir -p config/includes.chroot/usr/share/backgrounds
mkdir -p config/includes.chroot/usr/share/themes
mkdir -p config/includes.chroot/usr/share/icons
mkdir -p config/includes.chroot/opt/mycroft-core
mkdir -p config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml # For default user XFCE settings
mkdir -p config/includes.chroot/etc/skel/.config/autostart # For default user autostart

# Copy wallpaper
WALLPAPER_PATH="${PROJECT_BASE_DIR}/ui-ux/wallpapers/aasmi-wallpaper.png"
if [ -f "$WALLPAPER_PATH" ]; then
    cp "$WALLPAPER_PATH" config/includes.chroot/usr/share/backgrounds/aasmi-wallpaper.png
    chown root:root config/includes.chroot/usr/share/backgrounds/aasmi-wallpaper.png
else
    echo "Warning: Wallpaper file not found at $WALLPAPER_PATH. Skipping."
fi

# Copy UI/UX themes
THEMES_DIR="${PROJECT_BASE_DIR}/ui-ux/themes"
if [ -d "${THEMES_DIR}/candy-pastel-light" ]; then
    cp -r "${THEMES_DIR}/candy-pastel-light" config/includes.chroot/usr/share/themes/
    chown -R root:root config/includes.chroot/usr/share/themes/candy-pastel-light
else
    echo "Warning: Candy Pastel Light theme not found at ${THEMES_DIR}/candy-pastel-light. Skipping."
fi
if [ -d "${THEMES_DIR}/candy-pastel-dark" ]; then
    cp -r "${THEMES_DIR}/candy-pastel-dark" config/includes.chroot/usr/share/themes/
    chown -R root:root config/includes.chroot/usr/share/themes/candy-pastel-dark
else
    echo "Warning: Candy Pastel Dark theme not found at ${THEMES_DIR}/candy-pastel-dark. Skipping."
fi

# Copy Azure Dark Icons
ICONS_DIR="${PROJECT_BASE_DIR}/ui-ux/icons"
if [ -d "${ICONS_DIR}/azure-dark-icons" ]; then
    cp -r "${ICONS_DIR}/azure-dark-icons" config/includes.chroot/usr/share/icons/Azure-Dark-Icons
    chown -R root:root config/includes.chroot/usr/share/icons/Azure-Dark-Icons
else
    echo "Warning: Azure Dark Icons not found at ${ICONS_DIR}/azure-dark-icons. Skipping."
fi

# Copy voice assistant setup and configuration files
VOICE_ASSISTANT_SCRIPT="${PROJECT_BASE_DIR}/build-scripts/integrate-voice-assistant.sh"
if [ -f "$VOICE_ASSISTANT_SCRIPT" ]; then
    cp "$VOICE_ASSISTANT_SCRIPT" config/includes.chroot/opt/mycroft-core/integrate-voice-assistant.sh
    chmod +x config/includes.chroot/opt/mycroft-core/integrate-voice-assistant.sh
    chown root:root config/includes.chroot/opt/mycroft-core/integrate-voice-assistant.sh
else
    echo "Warning: integrate-voice-assistant.sh not found at $VOICE_ASSISTANT_SCRIPT. Skipping."
fi

# Additional customization scripts can be added here
# For example, copying the GTK CSS theme directly into the chroot
GTK_CSS_PATH="${PROJECT_BASE_DIR}/ui-ux/themes/candy-pastel-dark/gtk-3.0/gtk.css" # Assuming this is where it would be
mkdir -p config/includes.chroot/etc/skel/.config/gtk-3.0/
if [ -f "$GTK_CSS_PATH" ]; then
    cp "$GTK_CSS_PATH" config/includes.chroot/etc/skel/.config/gtk-3.0/gtk.css
    chown root:root config/includes.chroot/etc/skel/.config/gtk-3.0/gtk.css
fi

# Build the live ISO image
echo "Building the live ISO image... This may take a while."
lb build

echo "Live OS image build completed."
echo "ISO image located at: $BUILD_DIR/live-image-amd64.hybrid.iso"