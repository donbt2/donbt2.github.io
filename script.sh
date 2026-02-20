#!/bin/bash

# Detect OS
OS_TYPE="$(uname -s)"
ID_LIKE=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    ID_LIKE=$ID
fi

echo "Detected OS: $OS_TYPE / $ID_LIKE"

# --- MACOS LOGIC ---
if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "Running macOS setup..."
    # Install Homebrew if missing
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    apps=(firefox iterm2 steam brave-browser sublime-text spotify vlc discord 1password raycast)
    brew install --cask "${apps[@]}"

# --- FEDORA LOGIC ---
elif [[ "$ID" == "fedora" ]]; then
    echo "Running Fedora setup..."
    sudo dnf update -y
    sudo dnf install -y firefox steam sublime-text vlc discord
    # Note: Brave and 1Password usually require adding specific repos on Fedora
    echo "Note: You may need to manually add repos for Brave and 1Password on Fedora."

# --- DEBIAN/UBUNTU LOGIC ---
elif [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
    echo "Running Debian-based setup..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y firefox vlc discord steam
    # Note: Spotify and Sublime often require Snap or Flatpak on Ubuntu
    
# --- WINDOWS (WSL) DETECTION ---
elif [[ "$OS_TYPE" == *"NT"* || "$ID_LIKE" == *"microsoft"* ]]; then
    echo "Windows detected. Please use a PowerShell (.ps1) script for native Windows apps."
    exit 1

else
    echo "Unsupported OS."
    exit 1
fi

# --- UNIVERSAL: OH MY ZSH ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Setup complete for $OS_TYPE!"
