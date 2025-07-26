#!/bin/bash
# Setup script for AASMI OS base environment

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Starting AASMI OS base setup..."

# Update package lists and upgrade existing packages
apt-get update
apt-get dist-upgrade -y

# Install essential base system packages
echo "Installing minimal base system packages..."
apt-get install -y --no-install-recommends \
    systemd-sysv \
    sudo \
    wget \
    curl \
    ca-certificates \
    apt-transport-https \
    locales \
    dialog \
    net-tools \
    iproute2 \
    iputils-ping \
    bash-completion \
    software-properties-common \
    build-essential \
    gnupg \
    dirmngr

# Set locale
echo "Setting system locale..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
export LANG=en_US.UTF-8 # Apply immediately for the current session

# Install lightweight desktop environment (XFCE) and its dependencies
echo "Installing XFCE desktop environment..."
apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    lightdm \
    lightdm-gtk-greeter \
    xorg \
    xserver-xorg \
    xinit \
    dbus-x11

# Enable lightdm service
echo "Enabling LightDM service..."
systemctl enable lightdm.service

# Install basic multimedia and audio utilities
echo "Installing multimedia and audio utilities..."
apt-get install -y --no-install-recommends \
    pulseaudio \
    pavucontrol \
    simplescreenrecorder \
    cheese \
    scrot \
    ffmpeg

# Install network management and connectivity tools
echo "Installing network and connectivity tools..."
apt-get install -y --no-install-recommends \
    network-manager \
    network-manager-gnome \
    hostapd \
    dnsmasq \
    ifplugd

# Install lightweight open-source hacking/security tools
echo "Installing hacking/security tools..."
apt-get install -y --no-install-recommends \
    nmap \
    tcpdump \
    aircrack-ng \
    hydra \
    john \
    nikto \
    sqlmap \
    netcat-openbsd \
    wireshark-cli \
    dnsutils \
    hashcat \
    gufw \
    keepassxc

# Install power & performance management tools
echo "Installing power and performance management tools..."
apt-get install -y --no-install-recommends \
    cpufrequtils \
    tlp \
    thermald \
    powertop \
    preload \
    zram-tools \
    earlyoom \
    systemd-top # Renamed from systemd-cgtop for accuracy, though both exist

# Install lightweight developer tools
echo "Installing developer tools..."
apt-get install -y --no-install-recommends \
    micro \
    git \
    git-gui \
    postman-cli \
    hexedit \
    grep \
    jq \
    build-essential # Redundant if installed above, but harmless

# Install accessibility tools
echo "Installing accessibility tools..."
apt-get install -y --no-install-recommends \
    espeak \
    orca \
    xmag \
    onboard

# Install system monitoring and utility tools
echo "Installing system utilities..."
apt-get install -y --no-install-recommends \
    conky-all \
    htop \
    baobab \
    logwatch

# Install lightweight automation & scripting tools
echo "Installing automation and scripting tools..."
apt-get install -y --no-install-recommends \
    cron \
    inotify-tools \
    rsync \
    unattended-upgrades

echo "Base OS setup completed."