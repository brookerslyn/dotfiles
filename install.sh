#!/usr/bin/env bash
# Hyprland rice installer
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
LOG_PREFIX="[install]"

c_red()   { printf '\033[31m%s\033[0m\n' "$*"; }
c_green() { printf '\033[32m%s\033[0m\n' "$*"; }
c_blue()  { printf '\033[34m%s\033[0m\n' "$*"; }
c_yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

info()  { c_blue   "$LOG_PREFIX $*"; }
ok()    { c_green  "$LOG_PREFIX $*"; }
warn()  { c_yellow "$LOG_PREFIX $*"; }
fail()  { c_red    "$LOG_PREFIX $*"; exit 1; }

# ---

# Sanity check
[ "$(id -u)" -eq 0 ] && fail "Don't run as root"
[ ! -f "$REPO_DIR/.config/hypr/hyprland.lua" ] && fail "Run from the repo root"

# Detect distro
if ! command -v pacman >/dev/null 2>&1; then
    fail "Pacman not found. This installer targets Arch-based distros."
fi

# Pick AUR helper
AUR_HELPER=""
for h in yay paru; do
    if command -v "$h" >/dev/null 2>&1; then
        AUR_HELPER="$h"
        break
    fi
done

if [ -z "$AUR_HELPER" ]; then
    warn "No AUR helper found. Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
    AUR_HELPER="yay"
fi

ok "Using AUR helper: $AUR_HELPER"

# ---

PACKAGES=(
    # Compositor / shell
    hyprland hypridle quickshell-git
    # Theming
    matugen-bin waypaper
    # Launcher / notifications
    rofi-wayland swaync
    # Terminal
    kitty
    # Clipboard
    cliphist wl-clipboard
    # Screenshots / color picker
    grim slurp hyprpicker satty
    # Audio / brightness / media
    brightnessctl playerctl wireplumber
    # Visualizer
    cava
    # Logout
    wlogout
    # Misc utils
    jq inotify-tools socat ffmpeg imagemagick
    # Fonts
    ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji
)

info "Installing packages..."
"$AUR_HELPER" -S --needed --noconfirm "${PACKAGES[@]}" || warn "Some packages failed to install. Continuing anyway."

# ---

mkdir -p "$BACKUP_DIR"
info "Backing up existing configs to $BACKUP_DIR"

for d in "$REPO_DIR"/.config/*/; do
    name=$(basename "$d")
    if [ -e "$HOME/.config/$name" ] && [ ! -L "$HOME/.config/$name" ]; then
        mv "$HOME/.config/$name" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

# ---

mkdir -p "$HOME/.config"
info "Copying dotfiles into ~/.config"

cp -r "$REPO_DIR"/.config/. "$HOME/.config/"

# ---

info "Making scripts executable"

find "$HOME/.config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/quickshell" -type f -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/quickshell" -type f -name "*.py" -exec chmod +x {} \;

# ---

info "Setting up SDDM autologin (optional)"
if [ -d /etc/sddm.conf.d ]; then
    if ! grep -q "Session=hyprland" /etc/sddm.conf.d/*.conf 2>/dev/null; then
        warn "Skipping SDDM autologin - configure manually if desired"
        warn "Example: echo -e '[Autologin]\\nUser=$USER\\nSession=hyprland' | sudo tee /etc/sddm.conf.d/autologin.conf"
    fi
fi

# ---

# Hyprland uses Lua config; ensure entry point points to it
HYPR_ENTRY="$HOME/.config/hypr/hyprland.conf"
if ! grep -q '\$configProvider' "$HYPR_ENTRY" 2>/dev/null; then
    echo '$configProvider = lua' > "$HYPR_ENTRY"
    ok "Set hyprland.conf to use lua configProvider"
fi

# ---

ok "Installation complete!"
echo
info "Next steps:"
echo "  1. Log out and select Hyprland from your display manager"
echo "  2. Pick a wallpaper:           waypaper"
echo "  3. Toggle layout (US / RU):    Alt+Shift"
echo "  4. Open clipboard:             SUPER+V"
echo "  5. Open sidebar:               SUPER+N"
echo "  6. Open launcher:              SUPER+R"
echo "  7. Lock screen:                SUPER+L"
echo
warn "Backup of your previous configs: $BACKUP_DIR"
