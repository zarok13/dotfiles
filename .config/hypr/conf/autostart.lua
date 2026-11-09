local home = os.getenv("HOME")

local WALLPAPER_STATIC = home .. "/Pictures/wallpapers3/forest-vector-wallpapers.jpg"
local CYCLE_SCRIPT     = home .. "/.config/hypr/scripts/wallpaper-cycle.sh"

hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.focus({ monitor = "eDP-1" }))
    local hypridle = "hypridle"
    local cmds = {
        --"waybar -c " .. home .. "/.config/hypr/waybar/config.jsonc -s " .. home .. "/.config/hypr/waybar/style.css",
        "noctalia",
        "sleep 2 && udiskie -t --no-menu-checkbox-workaround",
        --"hyprpaper",
        --"sh -c 'awww-daemon & sleep 0.5 && awww img " .. WALLPAPER_STATIC
        --    .. " --transition-type grow --transition-fps 60 --transition-step 10'",
        --"sh -c 'sleep 1 && " .. CYCLE_SCRIPT .. " init'", --Seed the shared cycle index (static image position)
        "firewall-applet",
        "lxpolkit",
        "sleep 3 && conky -c " .. home .. "/.config/hypr/conky/conky.conf",
        "flameshot",
        --"gammastep-indicator -c " .. home .. "/.config/gammastep/config_wayland.ini",
        "sudo balance.sh",
        hypridle,
        -- "wl-paste --watch cliphist -max-items 10 store",
    }

    for _, cmd in ipairs(cmds) do
        hl.exec_cmd(cmd)
    end
end)
