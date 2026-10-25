local home = os.getenv("HOME")

hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.focus({ monitor = "eDP-1" }))
    local lock = home .. "/.config/hypr/scripts/lock.sh"
    local swayidle = table.concat({
        "swayidle -w",
        "timeout 400 '" .. lock .. "'",
        [[timeout 600 "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'"]],
        [[resume "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"]],
        "timeout 900 'systemctl suspend'",
        "before-sleep '" .. lock .. "'",
    }, " ")
    local cmds = {
        "waybar -c " .. home .. "/.config/hypr/waybar/config.jsonc -s " .. home .. "/.config/hypr/waybar/style.css",
        "sleep 2 && udiskie -t --no-menu-checkbox-workaround",
        "swaybg -i " .. home .. "/Pictures/wallpapers3/forest-vector-wallpapers.jpg -m fill",
        "firewall-applet",
        "lxpolkit",
        "conky -c " .. home .. "/.config/hypr/conky/conky.conf",
        "flameshot",
        "gammastep-indicator -c " .. home .. "/.config/gammastep/config_wayland.ini",
        "sudo balance.sh",
        swayidle,
        -- "wl-paste --watch cliphist -max-items 10 store",
    }

    for _, cmd in ipairs(cmds) do
        hl.exec_cmd(cmd)
    end
end)
