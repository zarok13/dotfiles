local home = os.getenv("HOME")
local mod  = "SUPER"

local function exec(keys, cmd)
    hl.bind(keys, hl.dsp.exec_cmd(cmd))
end

hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + q", hl.dsp.exit())
----------------------------------------------------------------
-- Workspaces
----------------------------------------------------------------
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + ALT + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + ALT + Left",  hl.dsp.focus({ workspace = "e-1" }))

-- move workspace to output right
hl.bind(mod .. " + SHIFT + Right", hl.dsp.workspace.swap_monitors({ monitor1 = "HDMI-A-1", monitor2 = "eDP-1" }))

-- Move container to next monitor
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ monitor = "+1" }))

----------------------------------------------------------------
-- Focus (arrows and vim keys)
----------------------------------------------------------------
local dirs = { h = "left", j = "down", k = "up", l = "right",
               Left = "left", Down = "down", Up = "up", Right = "right" }
for key, dir in pairs(dirs) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
end

----------------------------------------------------------------
-- Window state
----------------------------------------------------------------
-- Layouots
hl.config({
    general = {
        layout = "master",   -- dwindle, master, scrolling
    },
    master = {
        orientation = "left",   -- master on the right, stack on the left
        new_status = "slave",
    },
})
hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.layout("swapwithmaster master")) --master only

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

local window = hl.dsp.window -- EDIT: Forgot this in initial post >.<
local mainMod = 'SUPER' -- EDIT: Added mainMod as a var to match OPs setup
local left = { x = -10, y = 0, relative = true }
local down = { x = 0, y = 10, relative = true }
local up = { x = 0, y = -10, relative = true }
local right = { x = 10, y = 0, relative = true }

local function opts(direction)
  return { description = 'Resize the active window ' .. direction, repeating = true }
end

local left = { x = -10, y = 0, relative = true }
local down = { x = 0, y = 10, relative = true }
local up = { x = 0, y = -10, relative = true }
local right = { x = 10, y = 0, relative = true }
hl.bind(mod .. ' + CTRL + h', window.resize(left), opts('left'))
hl.bind(mod .. ' + CTRL + j', window.resize(down), opts('down'))
hl.bind(mod .. ' + CTRL + k', window.resize(up), opts('up'))
hl.bind(mod .. ' + CTRL + l', window.resize(right), opts('right'))

hl.bind(mod .. " + f", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
--hl.bind(mod .. " + f", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + q", hl.dsp.window.close())
hl.bind(mod .. " + t", hl.dsp.window.float({ action = "toggle" }))
--hl.bind(mod .. " + e", hl.dsp.layout("togglesplit"))   -- dwindle only
--hl.bind(mod .. " + w", hl.dsp.group.toggle())          -- closest to sway's tabbed

----------------------------------------------------------------
-- Scratchpad (special workspace)
----------------------------------------------------------------
--hl.bind(mod .. " + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }))
--hl.bind(mod .. " + equal", hl.dsp.workspace.toggle_special("scratchpad"))

-- Example special workspace (scratchpad)
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

----------------------------------------------------------------
-- Apps
----------------------------------------------------------------
exec(mod .. " + Return",         "alacritty")
exec("CTRL + ALT + t",           "alacritty")
exec(mod .. " + F8",             "thunar")
exec("CTRL + ALT + f",           "thunar")
exec(mod .. " + F5",             "brave-browser")
exec(mod .. " + F11",            "rofi -theme-str 'window {width: 100%;height: 100%;}' -show drun")
exec(mod .. " + F12",            "rofi -show drun -disable-history True")
exec(mod .. " + SHIFT + Return", "rofi -show drun")
exec(mod .. " + d",              "rofi -no-config -no-lazy-grab -show drun -disable-history True -modi drun -theme " .. home .. "/.config/rofi/launcher8.rasi")
exec(mod .. " + x",              home .. "/.config/rofi/powermenu/powermenu.sh")
exec(mod .. " + m",              home .. "/.config/rofi/powermenu/powerprofile.sh")
exec("CTRL + ALT + m",           "xfce4-settings-manager")
exec("CTRL + ALT + u",           "pavucontrol")
exec("CTRL + ALT + r",           "rofi-theme-selector")
exec("CTRL + Print",             "flameshot gui")

----------------------------------------------------------------
-- Media keys (see the notes about repeat and locked below)
----------------------------------------------------------------
exec("XF86AudioRaiseVolume",  "amixer set Master 5%+")
exec("XF86AudioLowerVolume",  "amixer set Master 5%-")
exec("XF86AudioMute",         "amixer -D pulse set Master 1+ toggle")
exec("XF86AudioPlay",         "playerctl play-pause")
exec("XF86AudioNext",         "playerctl next")
exec("XF86AudioPrev",         "playerctl previous")
exec("XF86AudioStop",         "playerctl stop")
exec("XF86MonBrightnessUp",   "brightnessctl set +5%")
exec("XF86MonBrightnessDown", "brightnessctl set 5%-")
