#!/bin/bash
# Setup default desktop wallpaper for AASMI OS (XFCE)

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Setting up default desktop wallpaper..."

# Define paths relative to the project root
PROJECT_ROOT=$(dirname "$(readlink -f "$0")")/.. # Adjust if needed
WALLPAPER_SOURCE="${PROJECT_ROOT}/ui-ux/wallpapers/aasmi-wallpaper.png"
WALLPAPER_DEST="/usr/share/backgrounds/aasmi-wallpaper.png" # System-wide location

# Check if wallpaper source exists
if [ ! -f "$WALLPAPER_SOURCE" ]; then
    echo "Error: Wallpaper source file not found at $WALLPAPER_SOURCE."
    echo "Please ensure the wallpaper 'aasmi-wallpaper.png' is in 'ui-ux/wallpapers/'."
    exit 1
fi

# Copy wallpaper to system backgrounds directory
echo "Copying wallpaper from $WALLPAPER_SOURCE to $WALLPAPER_DEST..."
cp "$WALLPAPER_SOURCE" "$WALLPAPER_DEST"
chown root:root "$WALLPAPER_DEST" # Ensure correct ownership

# --- IMPORTANT NOTE FOR LIVE-BUILD ---
# Directly running xfconf-query for a user within a live-build chroot
# often fails because there's no active D-Bus session for that user.
# The preferred method for setting default user settings in a live image
# is to copy the pre-configured xfce-perchannel-xml files to /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
# so they are inherited by newly created users or the 'live' user on first boot.
# The below commands are more suitable for a running system or a post-install script.
# For live-build, `build-live-image.sh` should handle copying these configs.
# --- END IMPORTANT NOTE ---

# Attempt to set wallpaper for root user (LightDM session / if root logs into graphical session)
echo "Attempting to set wallpaper for root (if graphical session exists)..."
# This might fail in a chroot. The LightDM configuration (configure-lightdm.sh) is more direct for login screen.
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$WALLPAPER_DEST" --create -t string -r || true

# Attempt to set wallpaper for default user 'aasmi'
echo "Attempting to set wallpaper for user 'aasmi' (if graphical session exists)..."
# To set xfconf settings for a specific user, especially in a chroot during build,
# it's better to copy the pre-configured XML files to /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
# or execute these commands in a chroot environment with the user's D-Bus environment properly set up.
# The simplest for live-build is /etc/skel.
# For a running system, this would typically be done by the user themselves or by a post-login script.
# Example for a running system (requires user 'aasmi' to be logged in and XFCE running):
# sudo -u aasmi DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u aasmi)/bus" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$WALLPAPER_DEST" --create -t string -r || true
# For live-build, ensure the `build-live-image.sh` script copies the XFCE desktop settings XML files
# into `config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml`
# with the wallpaper path already set.

echo "Default wallpaper setup completed. Remember to ensure XFCE default settings are copied to /etc/skel for live-build."