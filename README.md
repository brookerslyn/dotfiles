# dotfiles

My Hyprland rice on CachyOS. Material You theming via [matugen](https://github.com/InioX/matugen) — colors regenerate from the wallpaper.

## Features

- **Hyprland** with Lua config
- **Quickshell** topbar + sidebar + lock screen
- **Matugen** dynamic theming for kitty, rofi, gtk, cava, waybar, hyprland borders
- **Custom Quickshell sidebar** (`SUPER+N`) with music player, volume/brightness sliders, system stats, quick toggles, notifications
- **Windows-style clipboard manager** (`SUPER+V`) with image thumbnails, opens near cursor
- **Custom lock screen** with curtain reveal animation and random wallpaper
- **Random wallpapers** in rofi launcher background

## Stack

| Component | Tool |
|-----------|------|
| Compositor | Hyprland |
| Shell | Quickshell |
| Launcher | Rofi |
| Notifications | swaync |
| Wallpaper | waypaper |
| Theme engine | matugen |
| Terminal | kitty |
| Lock | Custom Quickshell lockscreen |
| Logout | wlogout |
| Audio visualizer | cava |
| Idle daemon | hypridle |
| Session | uwsm |

## Install

### Quick install

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer:
- Detects (or installs) yay
- Installs all required packages
- Backs up any existing configs to `~/.config/dotfiles_backup_<timestamp>/`
- Copies the configs into `~/.config/`
- Makes scripts executable
- Sets up the lua config provider for Hyprland

### Manual install

```bash
yay -S \
  hyprland hypridle quickshell-git \
  matugen-bin waypaper rofi-wayland swaync \
  kitty cliphist wl-clipboard grim slurp hyprpicker \
  brightnessctl playerctl wireplumber \
  cava wlogout \
  ttf-jetbrains-mono-nerd noto-fonts-cjk

git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
cp -rn .config/* ~/.config/

chmod +x ~/.config/hypr/scripts/*.sh
find ~/.config/hypr/scripts/quickshell -name "*.sh" -exec chmod +x {} \;

waypaper
```

## Keybinds

| Keys | Action |
|------|--------|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + R` | App launcher (rofi) |
| `SUPER + V` | Clipboard manager |
| `SUPER + N` | Sidebar (sys info, music, toggles, notifications) |
| `SUPER + L` | Lock screen |
| `SUPER + W` | Wallpaper picker |
| `SUPER + E` | File manager |
| `SUPER + C` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `Print` | Region screenshot to clipboard |
| `SHIFT + Print` | Region screenshot to file |
| `ALT + Print` | Annotate screenshot (satty) |
| `Alt+Shift` | Toggle US ⇄ RU keyboard |

## Matugen workflow

1. Pick wallpaper via waypaper (`SUPER+W`)
2. `wallpaper-watcher.sh` detects waypaper config change
3. `wallpaper-matugen.sh` extracts a frame, runs matugen
4. Matugen regenerates color files for all themed apps
5. Quickshell, kitty, rofi etc. live-reload via inotify or post-hooks

To add a new themed app: add a `[templates.appname]` section to `.config/matugen/config.toml` and create the corresponding template under `.config/matugen/templates/`.

## Notes

- Auto-generated color files are gitignored — they regenerate on first wallpaper change.
- Quickshell preview images and notification sounds account for most of the repo size.
