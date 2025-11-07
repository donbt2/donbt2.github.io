#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="/tmp/distro-flash"
ISO_PATH="$TMP_DIR/linux.iso"
mkdir -p "$TMP_DIR"

# --- FUNCTIONS ---

select_distro() {
    echo "Select a Linux distribution to download:"
    echo "1) Ubuntu (Desktop)"
    echo "2) Ubuntu Server"
    echo "3) Fedora Workstation"
    echo "4) Linux Mint"
    echo "5) Arch Linux"

    while true; do
        read -rp "Enter choice [1-5]: " choice
        case "$choice" in
            1) DISTRO="Ubuntu"; break;;
            2) DISTRO="Ubuntu Server"; break;;
            3) DISTRO="Fedora"; break;;
            4) DISTRO="Mint"; break;;
            5) DISTRO="Arch"; break;;
            *) echo "Invalid choice. Please enter 1–5.";;
        esac
    done
}

get_iso_url() {
    case "$DISTRO" in
        "Ubuntu")
            ver=$(wget -qO- https://releases.ubuntu.com/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n1)
            ISO_URL="https://releases.ubuntu.com/$ver/ubuntu-$ver-desktop-amd64.iso"
            ;;
        "Ubuntu Server")
            ver=$(wget -qO- https://releases.ubuntu.com/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n1)
            ISO_URL="https://releases.ubuntu.com/$ver/ubuntu-$ver-live-server-amd64.iso"
            ;;
        "Fedora")
            ver=$(wget -qO- https://download.fedoraproject.org/pub/fedora/linux/releases/ | grep -oE '[0-9]+' | sort -V | tail -n1)
            ISO_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/$ver/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-$ver-1.2.iso"
            ;;
        "Mint")
            ver=$(wget -qO- https://mirrors.edge.kernel.org/linuxmint/stable/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n1)
            ISO_URL="https://mirrors.edge.kernel.org/linuxmint/stable/$ver/linuxmint-$ver-cinnamon-64bit.iso"
            ;;
        "Arch")
            ISO_URL="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
            ;;
        *)
            echo "Error: no URL for distro."
            exit 1
            ;;
    esac
}

select_disk() {
    echo
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
    echo
    read -rp "Enter device to flash (e.g. sdb): " DEV
    if [[ ! -b "/dev/$DEV" ]]; then
        echo "Invalid device: /dev/$DEV"
        exit 1
    fi
    TARGET_DISK="/dev/$DEV"
}

confirm() {
    read -rp "Proceed? (y/N): " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

# --- MAIN ---

select_distro
echo "Selected: $DISTRO"
echo "Locating latest ISO..."
get_iso_url
echo "Download URL: $ISO_URL"

echo
echo "Downloading ISO to $ISO_PATH..."
wget -O "$ISO_PATH" "$ISO_URL"

select_disk

echo
echo "You are about to overwrite $TARGET_DISK with $DISTRO image."
if ! confirm; then
    echo "Aborted."
    exit 0
fi

echo
echo "Flashing image..."
sudo dd if="$ISO_PATH" of="$TARGET_DISK" bs=4M status=progress conv=fsync

echo
echo "Done. $DISTRO image written to $TARGET_DISK."
