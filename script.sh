# <#
# --- BASH SECTION (macOS / Linux) ---
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
    OS_TYPE="$(uname -s)"
    echo "Unix-like system detected: $OS_TYPE"

    # 1. macOS Logic
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        apps=(firefox iterm2 steam brave-browser sublime-text spotify vlc discord 1password raycast)
        brew install --cask "${apps[@]}"

    # 2. Linux Logic (Fedora/Debian)
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Linux detected: $ID"
        if [[ "$ID" == "fedora" ]]; then
            sudo dnf install -y firefox steam vlc discord
        elif [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            sudo apt update && sudo apt install -y firefox vlc discord steam
        fi
    fi

    # Install Oh My Zsh (Universal for Unix)
    [ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    exit
fi
# >

# --- POWERSHELL SECTION (Windows) ---
Write-Host "Windows detected. Starting Winget installation..." -ForegroundColor Cyan

$apps = @(
    "Mozilla.Firefox",
    "Brave.Brave",
    "SublimeText.SublimeText.4",
    "Spotify.Spotify",
    "VideoLAN.VLC",
    "Discord.Discord",
    "AgileBits.1Password",
    "Valve.Steam",
    "Microsoft.WindowsTerminal"
)

foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Yellow
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}

Write-Host "Windows setup complete! Note: Raycast/iTerm2 are Mac-only; installed Windows Terminal instead." -ForegroundColor Green
