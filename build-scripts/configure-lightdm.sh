#!/bin/bash
# Configure LightDM for AASMI OS custom login screen

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Configuring LightDM for custom login screen..."

# Install dependencies for custom greeter if not already installed by base setup
# lightdm-gtk-greeter-settings is a GUI tool, not strictly needed for this script to work.
# feh is useful for setting wallpaper from command line, which might be used during testing.
apt-get install -y --no-install-recommends \
    lightdm-gtk-greeter \
    x11-xserver-utils \
    feh

# Define source and destination for login background
LOGIN_BG_SOURCE="ui-ux/wallpapers/aasmi-login-bg.png" # Assuming this path
LOGIN_BG_DEST="/usr/share/backgrounds/aasmi-login-bg.png"

# Backup original LightDM config
if [ -f "/etc/lightdm/lightdm.conf" ]; then
    cp -p /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bak
    echo "Backed up /etc/lightdm/lightdm.conf to /etc/lightdm/lightdm.conf.bak"
else
    echo "No existing /etc/lightdm/lightdm.conf to backup."
fi

# Configure LightDM to use GTK greeter with custom settings
echo "Configuring LightDM to use lightdm-gtk-greeter..."
cat > /etc/lightdm/lightdm.conf <<EOF
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce
EOF

# Copy the provided PNG wallpaper as login background
if [ -f "$LOGIN_BG_SOURCE" ]; then
    cp "$LOGIN_BG_SOURCE" "$LOGIN_BG_DEST"
    chown root:root "$LOGIN_BG_DEST"
    echo "Copied login background from $LOGIN_BG_SOURCE to $LOGIN_BG_DEST"
else
    echo "Warning: Login background image not found at $LOGIN_BG_SOURCE. Please ensure it exists."
fi


# Configure GTK greeter settings for background and theme
echo "Configuring GTK greeter settings..."
mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
cat > /etc/lightdm/lightdm-gtk-greeter.conf.d/50-aasmi.conf <<EOF
[greeter]
background=$LOGIN_BG_DEST
theme-name=candy-pastel-dark # Use one of your custom themes
icon-theme-name=Azure-Dark-Icons # Use your custom icon theme
font-name=Sans 12
xft-antialias=true
xft-dpi=96
xft-hintstyle=hintfull
xft-rgba=rgb
EOF

echo "LightDM configuration completed."
echo "You may need to restart LightDM (sudo systemctl restart lightdm) to see changes immediately."