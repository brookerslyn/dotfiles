-- Hyprland Lua Config
-- Migrated from binnewbs/arch-hyprland dotfiles
-- https://github.com/binnewbs/arch-hyprland

-- Load matugen-generated colors (border colors)
require("colors")

-------------------
---- VARIABLES ----
-------------------

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "~/.config/hypr/scripts/rofi.sh"
local mainMod = "SUPER"
local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

------------------
---- MONITORS ----
------------------

hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = "auto",
})

-------------------
---- AUTOSTART ----
-------------------

hl.exec_cmd("nm-applet")
hl.exec_cmd("blueman-applet")
hl.exec_cmd("swaync")
hl.exec_cmd("systemctl --user start hyprpolkitagent")
hl.exec_cmd("hypridle")
hl.exec_cmd("~/.config/hypr/scripts/autostart.sh &")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 0,
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.8,

    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },

    blur = {
      enabled = true,
      size = 5,
      passes = 3,
      special = false,
      popups = true,
      xray = true,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
  },

  input = {
    kb_layout = "us,ru",
    kb_options = "grp:alt_shift_toggle",
    follow_mouse = 1,
    sensitivity = 0,
    accel_profile = "flat",

    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("myBezier",  { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("been",      { type = "bezier", points = { {0.24, 0.9}, {0.25, 0.91} } })
hl.curve("been2",     { type = "bezier", points = { {0, 0.94}, {0.5, 0.99} } })
hl.curve("menu_decel",{ type = "bezier", points = { {0.1, 1}, {0, 1} } })
hl.curve("linear",    { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("wind",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn",     { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut",    { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("slow",      { type = "bezier", points = { {0, 0.85}, {0.3, 1} } })
hl.curve("overshot",  { type = "bezier", points = { {0.7, 0.6}, {0.1, 1.1} } })
hl.curve("bounce",    { type = "bezier", points = { {1.1, 1.6}, {0.1, 0.85} } })
hl.curve("sligshot",  { type = "bezier", points = { {1, -1}, {0.15, 1.25} } })
hl.curve("nice",      { type = "bezier", points = { {0, 1.9}, {0.5, -0.9} } })

hl.animation({ leaf = "windowsIn",    enabled = true, speed = 5,  bezier = "slow",    style = "popin" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 7,  bezier = "been",    style = "popin 70%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 5,  bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",       enabled = true, speed = 1,  bezier = "linear" })
hl.animation({ leaf = "fade",         enabled = true, speed = 5,  bezier = "overshot" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 5,  bezier = "wind" })
hl.animation({ leaf = "windows",      enabled = true, speed = 5,  bezier = "bounce",  style = "popin" })

---------------------
---- KEYBINDINGS ----
---------------------

-- Core (restored from your original config)
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(scripts .. "/clipboard.sh"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Scratchpad (restored)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Sidebar widget
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(scripts .. "/sidebar.sh"))

-- Screenshots (restored - grim/slurp/satty)
hl.bind("Print",
    hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))
hl.bind("SHIFT + Print",
    hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png']]))
hl.bind("ALT + Print",
    hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | satty --filename - --fullscreen --copy-command wl-copy']]))

-- Binnewbs scripts (moved to non-conflicting keys)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(scripts .. "/wbrestart.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('xdg-open "https://"'))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(scripts .. "/lock.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(scripts .. "/wppicker.sh"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(scripts .. "/KillActiveProcess.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd(scripts .. "/WaybarStyles.sh"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(scripts .. "/WaybarLayout.sh"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty yazi"))

-- klyppd
hl.bind("ALT + R",         hl.dsp.exec_cmd("/home/brook/Documents/Klyppd/src-tauri/target/debug/klyppd --cmd save-replay"))
hl.bind("ALT + SHIFT + R", hl.dsp.exec_cmd("/home/brook/Documents/Klyppd/src-tauri/target/debug/klyppd --cmd toggle-recording"))
hl.bind("ALT + F8",        hl.dsp.exec_cmd("/home/brook/Documents/Klyppd/src-tauri/target/debug/klyppd --cmd toggle-buffer"))

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0 }),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -50 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 50 }),  { repeating = true })

-- Switch workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "/volume.sh --inc"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "/volume.sh --dec"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "/volume.sh --toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "/brightness.sh --inc"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "/brightness.sh --dec"), { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-----------------
---- TAGS -------
-----------------

hl.window_rule({ match = { class = "^([Mm]pv|vlc)$" },              tag = "+multimedia_video" })
hl.window_rule({ match = { class = "^(nm-applet|nm-connection-editor|blueman-manager|org.gnome.FileRoller)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(org.gnome.DiskUtility|wihotspot(-gui)?)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(org.gnome.SystemMonitor)$" }, tag = "+viewer" })
hl.window_rule({ match = { class = "^(org.gnome.Evince)$" },       tag = "+viewer" })
hl.window_rule({ match = { class = "^(eog|org.gnome.Loupe)$" },    tag = "+viewer" })

------------------------
---- WINDOW RULES ------
------------------------

-- Opacity rules
hl.window_rule({ match = { tag = "multimedia_video" }, no_blur = true, opacity = "1.0" })
hl.window_rule({ match = { tag = "settings" },        opacity = "0.8" })
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$" },      opacity = "0.8" })
hl.window_rule({ match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, opacity = "0.9" })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, opacity = "0.9" })
hl.window_rule({ match = { class = "^(kitty)$" },                    opacity = "0.9" })
hl.window_rule({ match = { class = "^(discord|vesktop|org.telegram.desktop)$" }, opacity = "0.85 override 0.7 override 1 override" })
hl.window_rule({ match = { class = "^(Spotify)$" },                  opacity = "0.8 override 0.6 override 1 override" })
hl.window_rule({ match = { class = "^(zen)$" },                      opacity = "0.9 override 0.7 override 1 override" })

-- Float rules
hl.window_rule({ match = { tag = "settings" },          float = true })
hl.window_rule({ match = { tag = "viewer" },            float = true })
hl.window_rule({ match = { tag = "multimedia_video" },  float = true, size = {900, 506} })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true, size = {"50%", "60%"} })

-- Suppress maximize
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix XWayland drag
hl.window_rule({
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})

-- Popups and dialogues
hl.window_rule({ match = { title = "^(Save As|Save a File|Pick Files)$" }, float = true, size = {"50%", "60%"}, center = true })
hl.window_rule({ match = { initial_title = "(Open Files)" }, float = true, size = {"70%", "60%"} })

-----------------------
---- LAYER RULES ------
-----------------------

hl.layer_rule({ match = { namespace = "waybar" },    blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "quickshell" }, blur = true, ignore_alpha = 0.3, xray = false })
hl.window_rule({ match = { class = "^(Rofi)$" }, opacity = "0.85 override 0.85 override 1 override" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })

-- Swaync blur
hl.layer_rule({ match = { namespace = "swaync-control-center" },     blur = true, ignore_alpha = 0.5, xray = false })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5, xray = false })
