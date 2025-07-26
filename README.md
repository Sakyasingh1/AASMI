# AASMI OS (Enhanced Version with Candy-Themed UI & Voice Assistant)

**Adaptive Advance System Management Interface**

---

![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Build](https://img.shields.io/badge/Build-Passing-green.svg)
![Version](https://img.shields.io/badge/Version-1.2.0--beta-orange.svg)

---

## Overview

AASMI OS is a modern, lightweight live operating system designed for portability, security, and productivity. This enhanced version features a unique candy-themed pastel UI with playful animations and an integrated voice assistant for hands-free control. It includes a comprehensive suite of preconfigured applications ready for immediate use in any environment.

---

## Key Features

### 🚀 Enhanced UI/UX Design

- **Candy-Themed Pastel Visuals:** Soft cotton candy pinks, ice blues, lavender haze, and bubblegum highlights.
- **Animated Login Screen:** Gradient pink-to-blue galaxy background with twinkling stars and glowing input prompt.
- **Playful Desktop Elements:**
  - Floating cloud-shaped menu button with gentle bounce animation.
  - Dark mode toggle shaped like a crescent moon and sun with melting animation.
  - Candy wrapper folder icons with jiggle hover effects.
  - Custom progress bars, battery icons, app install animations, network indicators, drag-and-drop prompts, and shutdown confirmation icons.
- **Motion Concepts:** Gentle bouncy animations, pastel particle effects, and gradient transitions that flow like melted ice cream.
- **Iconography:** Rounded candy-inspired shapes with soft glows and playful but clean lines.
- **Default Wallpaper:** Custom AASMI candy swirl wallpaper set as default on live boot.

### 🗣️ Voice Assistant Integration

- Integrated open-source voice assistant for hands-free OS control.
- Animated lollipop mascot wake prompt.
- Voice commands to launch applications, manage system settings, and more.
- Wake phrase: "Bubblegum".

### 📦 Preconfigured Application Suite

- Office Productivity: LibreOffice 7.4, OnlyOffice, PDF Arranger, Okular.
- Web Browsers: Firefox ESR, Google Chrome, Tor Browser.
- Development Tools: VS Code Lite, Xed++, Python 3.10 with libraries, Git, GitHub CLI, SQLite Browser.
- System Utilities: GParted, Timeshift, BleachBit, Synaptic, Grub Customizer.
- Multimedia: VLC, Audacity, GIMP, OBS Studio, Kdenlive.
- Security Tools: KeePassXC, Veracrypt, Wireshark, ClamAV, Lynis.

### 🔄 Persistence Options

- Full Persistence: Save all changes.
- Selective Persistence: Choose what to save (settings, files, apps).
- Encrypted Persistence: AES-256 encrypted containers.
- Cloud Persistence: Sync preferences with Nextcloud, Google Drive, Dropbox, OneDrive.

### 🧩 Modular Component System

- Install or remove modules like Full-Office, Dev-Pack, Media-Pro, Gaming, Science.
- Manage modules via `aasmi-module` CLI tool.

---

## System Requirements

| Requirement          | Minimum               | Recommended          | Optimal               |
|----------------------|-----------------------|---------------------|-----------------------|
| CPU                  | x86_64 dual-core 1.5GHz | Quad-core 2.4GHz+   | USB 3.2 SSD Drive     |
| RAM                  | 2GB                   | 8GB+                | 32GB+ Persistent Storage |
| Storage              | 8GB USB 3.0 drive     | 16GB+ USB 3.1 drive |                       |
| Graphics             | 1024x768 resolution   | 1080p with OpenGL 3.3+ |                       |
| Network              | Broadband for cloud features |                 |                       |

---

## Installation & Usage

### First Boot Options

- **Try AASMI:** Live mode without saving changes.
- **Install to USB:** Create persistent installation.
- **Troubleshooting Mode:** Limited drivers for problem systems.
- **Forensics Mode:** Read-only with special tools.

### Login Credentials

- **Username:** root
- **Password:** AASMI

### Quick Start Commands

```bash
# Launch common applications
aasmi-launch browser       # Open default browser
aasmi-launch office        # Start LibreOffice
aasmi-launch developer     # Open VS Code + terminal
aasmi-launch media         # Open VLC media player

# System management
aasmi-update              # Check for system updates
aasmi-backup              # Create system backup
aasmi-reset               # Reset to default settings
```

### Module Management

```bash
# List available modules
aasmi-module list

# Install a module
aasmi-module install dev-pack

# Remove a module  
aasmi-module remove full-office

# Update all modules
aasmi-module update-all
```

---

## Voice Assistant Usage

- Say **"Bubblegum"** or tap the floating lollipop mascot to activate.
- Use voice commands to open apps, adjust settings, and navigate the OS.

---

## Development & Contribution

We welcome contributions to enhance AASMI OS:

- Suggest new apps or features via GitHub issues.
- Package applications following our guidelines.
- Optimize configurations and themes.
- Create specialized modules.

Example packaging workflow:

```bash
git clone https://github.com/aasmi-os/app-packager.git
cd app-packager
./package-app.sh /path/to/application
```

---

## Support & Community

- Documentation: [docs.aasmi-os.org](https://docs.aasmi-os.org)
- Forum: [community.aasmi-os.org](https://community.aasmi-os.org)
- Discord: AASMI OS Chat
- Weekly Live Q&A: Fridays 14:00 UTC

---

**AASMI OS - Your complete computing environment in your pocket**
