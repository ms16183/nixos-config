local terminal = "wezterm"
local filer    = "ranger"
local editor   = "vim"
local launcher = "rofi"
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
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprlock --immediate-render"), { locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- same, but also repeat while held
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(filer))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(launcher .. " -show drun"))
hl.bind(mainMod .. " + P",      hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("brave"))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --immediate-render"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.swap({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 100,  y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 100,  relative = true }))

-- workspaces 1-9 on the number row (keycode 10 = "1" ... 18 = "9",
-- matching the old "code:1${i}" hyprlang binds)
for ws = 1, 9 do
  local code = 9 + ws
  hl.bind(mainMod .. " + code:" .. code, hl.dsp.focus({ workspace = ws }))
  hl.bind(mainMod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = ws }))
end
