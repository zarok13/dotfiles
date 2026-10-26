local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name        = "flameshot",
    match       = { class = "flameshot" },
    float       = true,
    center      = true,
    border_size = 0,
})

hl.window_rule({
    name   = "nmtui",
    match  = { class = "com.mitchellh.ghostty", title = "nmtui" },
    float  = true,
    center = true,
    size   = "1000 800",
})

hl.window_rule({
    name  = "conky",
    match = { class = "conky" },
    float = true,
    no_focus = true,
    border_size = 0,
})

local assign = {
    { "firefox",     "1" },
    { "rustdesk",    "2" },
    { "discord",     "3" },
    { "sublime_text", "3" },
    { "brave-browser", "5" },
    { "librewolf",   "6" },
    { "Tor Browser", "7" },
}

for _, a in ipairs(assign) do
    hl.window_rule({
        name      = "assign-" .. a[1],
        match     = { class = a[1] },
        workspace = a[2] .. " silent",
    })
end
