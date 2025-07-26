#!/bin/bash
# Apply UI/UX customizations for AASMI OS

set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Applying UI/UX customizations..."

# Define default user and their home directory
DEFAULT_USER="aasmi"
DEFAULT_USER_HOME="/home/$DEFAULT_USER"

# Ensure user's config directory exists
mkdir -p "$DEFAULT_USER_HOME/.config"
chown "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_USER_HOME/.config"

# --- IMPORTANT NOTE FOR LIVE-BUILD / CHROOT ---
# When running these commands in a `live-build` chroot environment,
# direct `xfconf-query` commands for a specific user (even with sudo -u)
# might not work reliably because a D-Bus session for that user is not active.
# The most robust way to apply default XFCE settings in a live image is to
# place the pre-configured XFCE XML files directly into `/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/`.
# This ensures that any new user created (including the live user) gets these settings.
# The following `xfconf-query` commands are more suitable for a running system's post-installation setup.
# However, for completeness and assuming this script might be run post-chroot in a different context,
# they are kept with a note.
# --- END IMPORTANT NOTE ---

# Set GTK theme and icon theme for default user 'aasmi'
echo "Setting GTK theme and icon theme..."
# These xfconf-query commands ideally modify settings for the current user's session.
# For default settings in a live image, place relevant XML files in /etc/skel.
# Example for /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml:
# <property name="Net" type="empty">
#   <property name="ThemeName" type="string" value="candy-pastel-light"/>
#   <property name="IconThemeName" type="string" value="Azure-Dark-Icons"/>
# </property>
sudo -u "$DEFAULT_USER" xfconf-query -c xsettings -p /Net/ThemeName -s "candy-pastel-light" --create -t string -r || true
sudo -u "$DEFAULT_USER" xfconf-query -c xsettings -p /Net/IconThemeName -s "Azure-Dark-Icons" --create -t string -r || true

# Set wallpaper for default user 'aasmi' (as done in setup-wallpaper.sh, but reinforcing here)
sudo -u "$DEFAULT_USER" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "/usr/share/backgrounds/aasmi-wallpaper.png" --create -t string -r || true

# Configure XFCE Panel
echo "Configuring XFCE Panel..."
# These are tricky to automate reliably in a chroot.
# Manual configuration and then copying the panel's XML files from a test user's
# `~/.config/xfce4/panel/` directory to `/etc/skel/.config/xfce4/panel/` is best.
# For example, to add clock and calendar, you'd configure them manually, then copy the
# `xfce4-panel.xml` and `datetime-*.rc` files.
# The commands below are symbolic and might not work directly in a chroot.
# A more direct approach is to edit xfce4-panel.xml directly for /etc/skel.

# Install Plank dock and Conky for widgets
echo "Installing Plank and Conky..."
apt-get install -y plank conky-all

# Create Plank dock config for default user
echo "Creating Plank dock configuration..."
PLANK_CONFIG_DIR="$DEFAULT_USER_HOME/.config/plank/dock1"
mkdir -p "$(dirname "$PLANK_CONFIG_DIR")"
cat > "$PLANK_CONFIG_DIR" <<EOF
[PlankDockPreferences]
Theme=Gtk+ # Use GTK theme integration
Position=1 # Bottom
Alignment=0 # Center
Iconsize=48
ShowDockItem=org.gnome.Nautilus.desktop
ShowDockItem=firefox.desktop
ShowDockItem=xfce4-terminal.desktop
ShowDockItem=mousepad.desktop
ShowDockItem=vlc.desktop
ShowDockItem=xfce4-settings-manager.desktop
ShowDockItem=aasmi-start-menu.desktop # Your custom menu launcher
EOF
chown -R "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_USER_HOME/.config/plank"

# Enable Plank to start on login for default user
echo "Enabling Plank to start on login..."
AUTOSTART_DIR="$DEFAULT_USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/plank.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank Dock
Comment=Start Plank dock on login
EOF
chown "$DEFAULT_USER":"$DEFAULT_USER" "$AUTOSTART_DIR/plank.desktop"

# Enable AASMI Start Menu to start on login for default user
echo "Enabling AASMI Start Menu to start on login..."
AASMI_MENU_SCRIPT_SYS_PATH="/usr/share/aasmi/start-menu/aasmi-start-menu.py"
mkdir -p "$(dirname "$AASMI_MENU_SCRIPT_SYS_PATH")"
# Copy start menu script to system directory
PROJECT_ROOT=$(dirname "$(readlink -f "$0")")/..
cp "${PROJECT_ROOT}/ui-ux/start-menu/aasmi-start-menu.py" "$AASMI_MENU_SCRIPT_SYS_PATH"
chmod +x "$AASMI_MENU_SCRIPT_SYS_PATH"
chown root:root "$AASMI_MENU_SCRIPT_SYS_PATH"

cat > "$AUTOSTART_DIR/aasmi-start-menu.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=python3 $AASMI_MENU_SCRIPT_SYS_PATH
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=AASMI Start Menu
Comment=Start menu launcher for AASMI OS
EOF
chown "$DEFAULT_USER":"$DEFAULT_USER" "$AUTOSTART_DIR/aasmi-start-menu.desktop"

# Setup Conky config for candy-themed system info widget
echo "Setting up Conky system info widget..."
CONKY_CONFIG_DIR="$DEFAULT_USER_HOME/.config/conky"
mkdir -p "$CONKY_CONFIG_DIR"
cat > "$CONKY_CONFIG_DIR/conky.conf" <<'EOF'
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 0, # No border
    cpu_avg_samples = 2,
    double_buffer = true,
    draw_shades = false,
    minimum_width = 250,
    minimum_height = 100,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_stderr = false,
    extra_newline = false,
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false,
    default_color = '#E6E6FA', -- Lavender Haze for general text
    color0 = '#FF69B4',       -- Bubblegum Highlight for main highlights
    color1 = '#FF85B8',       -- Soft Pink for secondary highlights
};

conky.text = [[
${color0}AASMI OS System Info${color}
${hr}
${color1}CPU:${color} ${cpu cpu0}% ${cpubar cpu0}
${color1}RAM:${color} ${memperc}% ${membar}
${color1}Disk (${fs_used_perc /}%):${color} ${fs_bar /}
${color1}Uptime:${color} ${uptime}
${color1}Kernel:${color} ${kernel}
${color1}Network:${color} ${addr eth0}
Upload: ${upspeed eth0} ${color1}Down:${color} ${downspeed eth0}
]];
EOF

chown -R "$DEFAULT_USER":"$DEFAULT_USER" "$CONKY_CONFIG_DIR"

# Enable Conky to start on login for default user
cat > "$AUTOSTART_DIR/conky.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=conky -c "$CONKY_CONFIG_DIR/conky.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky System Info
Comment=Candy-themed system info widget
EOF
chown "$DEFAULT_USER":"$DEFAULT_USER" "$AUTOSTART_DIR/conky.desktop"

# Add right-click context menu enhancements for XFCE desktop and Thunar file manager
echo "Enhancing XFCE desktop and Thunar context menus..."
# These should also ideally be set via /etc/skel for live-build.
sudo -u "$DEFAULT_USER" xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 1 --create -t int -r || true # Icon style (0: none, 1: solid, 2: transparent, 3: solid + single click)
sudo -u "$DEFAULT_USER" xfconf-query -c thunar -p /misc-show-context-menu -s true --create -t bool -r || true

# Setup user profiles directory and default profile
echo "Setting up user profiles..."
USER_PROFILES_DIR="$DEFAULT_USER_HOME/.config/aasmi-profiles"
mkdir -p "$USER_PROFILES_DIR"
chown "$DEFAULT_USER":"$DEFAULT_USER" "$USER_PROFILES_DIR"

DEFAULT_PROFILE="$USER_PROFILES_DIR/default"
if [ ! -d "$DEFAULT_PROFILE" ]; then
    mkdir -p "$DEFAULT_PROFILE"
    chown "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_PROFILE"
    # Copy default config files to default profile from user's actual config
    # This assumes `aasmi` user is already created and some default XFCE configs exist.
    # In a live-build, you'd copy from a prepared set.
    echo "Creating default profile from current user settings (if available)..."
    cp -r "$DEFAULT_USER_HOME/.config/xfce4" "$DEFAULT_PROFILE/" || true
    cp -r "$DEFAULT_USER_HOME/.config/gtk-3.0" "$DEFAULT_PROFILE/" || true
    cp -r "$DEFAULT_USER_HOME/.config/plank" "$DEFAULT_PROFILE/" || true
    cp -r "$DEFAULT_USER_HOME/.config/conky" "$DEFAULT_PROFILE/" || true
    chown -R "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_PROFILE"
fi

# Setup autostart for minimal and full profiles
echo "Setting up autostart profiles..."
mkdir -p "$AUTOSTART_DIR/minimal"
mkdir -p "$AUTOSTART_DIR/full"
chown -R "$DEFAULT_USER":"$DEFAULT_USER" "$AUTOSTART_DIR"

# Example: move some autostart apps to minimal or full profile
# Ensure these files exist before moving them.
if [ -f "$AUTOSTART_DIR/aasmi-start-menu.desktop" ]; then
    mv "$AUTOSTART_DIR/aasmi-start-menu.desktop" "$AUTOSTART_DIR/full/"
fi
if [ -f "$AUTOSTART_DIR/plank.desktop" ]; then
    mv "$AUTOSTART_DIR/plank.desktop" "$AUTOSTART_DIR/full/"
fi
if [ -f "$AUTOSTART_DIR/conky.desktop" ]; then
    mv "$AUTOSTART_DIR/conky.desktop" "$AUTOSTART_DIR/full/"
fi

# Create simple scripts for profile switching (can be launched from menu)
cat > "$DEFAULT_USER_HOME/.local/bin/switch-profile-minimal.sh" <<EOF
#!/bin/bash
rm -f "$AUTOSTART_DIR"/*.desktop # Remove all current autostart entries
cp "$AUTOSTART_DIR/minimal/"*.desktop "$AUTOSTART_DIR/" || true # Copy minimal profile entries
notify-send "AASMI Profile" "Switched to Minimal Profile."
EOF

cat > "$DEFAULT_USER_HOME/.local/bin/switch-profile-full.sh" <<EOF
#!/bin/bash
rm -f "$AUTOSTART_DIR"/*.desktop # Remove all current autostart entries
cp "$AUTOSTART_DIR/full/"*.desktop "$AUTOSTART_DIR/" || true # Copy full profile entries
notify-send "AASMI Profile" "Switched to Full Profile."
EOF

chmod +x "$DEFAULT_USER_HOME/.local/bin/switch-profile-minimal.sh"
chmod +x "$DEFAULT_USER_HOME/.local/bin/switch-profile-full.sh"
chown "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_USER_HOME/.local/bin/switch-profile-minimal.sh"
chown "$DEFAULT_USER":"$DEFAULT_USER" "$DEFAULT_USER_HOME/.local/bin/switch-profile-full.sh"

echo "UI/UX customizations applied. Remember to adjust /etc/skel for live-build robustness."