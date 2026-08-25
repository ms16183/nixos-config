local terminal = "wezterm"
local filer    = "ranger"
local editor   = "vim"
local launcher = "hyprlauncher"
local mainMod  = "SUPER"

hl.on("hyprland.start", function()
  hl.exec_cmd("fcitx5")
end)

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 5,
    border_size = 3,

    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 0.95,
    inactive_opacity = 0.90,

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },

    shadow = {
      enabled = false,
    },
  },

  input = {
    kb_layout = "us",

    follow_mouse = 1,
    sensitivity = 0,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 2,
    disable_hyprland_logo = false,

    animate_manual_resizes = true,
  },
})

-- blur the quickshell bar the same way regular windows are blurred
-- above (decoration.blur), via the "quickshell:bar" layer-shell
-- namespace set in wayland/quickshell/config/shell.qml.
hl.layer_rule({
  match = { namespace = "quickshell:bar" },
  blur = true,
})

-- binds that still work through hyprlock (lid switch, mute keys)
-- `description` here doubles as the label shown in the settings window's
-- Shortcuts section (read via `hyprctl binds -j`), not just documentation.
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprlock --immediate-render"), { locked = true, description = "Lock (Lid Close)" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, description = "Mute" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, description = "Mic Mute" })

-- same, but also repeat while held
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume Up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true, description = "Volume Down" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true, description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true, description = "Brightness Down" })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move Window (Drag)" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Window (Drag)" })

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), { description = "Terminal" })
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(filer), { description = "File Manager" })
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(launcher), { description = "App Launcher" })
hl.bind(mainMod .. " + P",      hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland Config" })
hl.bind(mainMod .. " + Q",      hl.dsp.window.close(), { description = "Close Window" })
hl.bind(mainMod .. " + M",      hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("brave"), { description = "Browser" })

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating" })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Toggle Fullscreen" })

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"), { description = "Screenshot (Area)" })

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --immediate-render"), { description = "Lock Screen" })

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })

hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.swap({ direction = "left" }), { description = "Swap Window Left" })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "right" }), { description = "Swap Window Right" })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.swap({ direction = "up" }), { description = "Swap Window Up" })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.swap({ direction = "down" }), { description = "Swap Window Down" })

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Resize Window Left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 100,  y = 0, relative = true }), { description = "Resize Window Right" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Resize Window Up" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 100,  relative = true }), { description = "Resize Window Down" })

-- workspaces 1-9 on the number row (keycode 10 = "1" ... 18 = "9",
-- matching the old "code:1${i}" hyprlang binds)
for ws = 1, 9 do
  local code = 9 + ws
  hl.bind(mainMod .. " + code:" .. code, hl.dsp.focus({ workspace = ws }), { description = "Workspace " .. ws })
  hl.bind(mainMod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = ws }), { description = "Move to Workspace " .. ws })
end
