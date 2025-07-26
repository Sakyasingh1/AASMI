#!/bin/bash
# Enhanced AASMI OS Builder with USB Flashing
# Usage: sudo ./build-aasmi-os.sh [--usb /dev/sdX] [--persistence SIZE_GB]

set -eo pipefail
trap 'cleanup $?' EXIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
TARGET_USB=""
PERSISTENCE_SIZE=0
PROJECT_ROOT=$(dirname "$(readlink -f "$0")")/..
BUILD_DIR="${PROJECT_ROOT}/live-build-output"
ISO_NAME="aasmi-os-$(date +%Y%m%d).iso"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --usb)
            TARGET_USB="$2"
            shift 2
            ;;
        --persistence)
            PERSISTENCE_SIZE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

cleanup() {
    if [[ $1 -ne 0 ]]; then
        echo -e "${RED}Build failed! Check ${BUILD_DIR}/build.log${NC}"
    fi
    umount_loopbacks
}

umount_loopbacks() {
    for mount in $(mount | grep "$BUILD_DIR" | awk '{print $3}'); do
        sudo umount "$mount" 2>/dev/null || true
    done
    losetup -D || true
}

check_dependencies() {
    local deps=("live-build" "squashfs-tools" "xorriso" "parted" "dosfstools")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Installing missing dependencies...${NC}"
        sudo apt-get update && sudo apt-get install -y "${missing[@]}"
    fi
}

build_iso() {
    echo -e "${GREEN}>>> Starting ISO build...${NC}"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    # Clean previous build
    lb clean 2>&1 | tee -a build.log

    # Configure live-build
    lb config \
        --architectures amd64 \
        --binary-images iso-hybrid \
        --distribution bookworm \
        --archive-areas "main contrib non-free" \
        --bootappend-live "boot=live components splash quiet" \
        --debian-installer none \
        2>&1 | tee -a build.log

    # Copy custom configurations
    cp -r "$PROJECT_ROOT/config"/* config/

    # Build ISO
    echo -e "${GREEN}>>> Building ISO (this may take 30+ minutes)...${NC}"
    lb build 2>&1 | tee -a build.log

    # Rename output
    mv live-image-amd64.hybrid.iso "$ISO_NAME"
    echo -e "${GREEN}>>> ISO built: ${BUILD_DIR}/${ISO_NAME}${NC}"
}

create_persistence() {
    local usb="$1"
    local size="$2"
    
    echo -e "${YELLOW}>>> Creating ${size}GB persistence partition...${NC}"
    sudo parted "$usb" mkpart primary ext4 4GB ${size}GB 2>&1 | tee -a build.log
    sudo mkfs.ext4 -L persistence "${usb}3" 2>&1 | tee -a build.log
    sudo mount "${usb}3" /mnt
    echo "/ union" | sudo tee /mnt/persistence.conf
    sudo umount /mnt
}

flash_to_usb() {
    local usb="$1"
    local iso="$2"

    echo -e "${GREEN}>>> Flashing to ${usb}...${NC}"
    
    # Verify USB
    if ! lsblk "$usb" &>/dev/null; then
        echo -e "${RED}Error: ${usb} not found!${NC}"
        exit 1
    fi

    # Confirm write
    read -rp "This will ERASE all data on ${usb}. Continue? (y/N) " confirm
    [[ "$confirm" =~ [yY] ]] || exit 1

    # Flash ISO
    sudo dd if="$iso" of="$usb" bs=4M status=progress conv=fdatasync 2>&1 | tee -a build.log

    # Add persistence if requested
    if [[ $PERSISTENCE_SIZE -gt 0 ]]; then
        create_persistence "$usb" "$PERSISTENCE_SIZE"
    fi

    echo -e "${GREEN}>>> USB ready at ${usb}${NC}"
}

main() {
    # Start logging
    exec > >(tee -a "${BUILD_DIR}/build.log") 2>&1
    
    check_dependencies
    build_iso

    if [[ -n "$TARGET_USB" ]]; then
        flash_to_usb "$TARGET_USB" "${BUILD_DIR}/${ISO_NAME}"
    fi
}

main