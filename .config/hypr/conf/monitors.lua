-- left: HDMI-A-1 (external monitor)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
    bitdepth = 8,
    vrr      = 0,
})

-- right: eDP-1 (laptop screen)
hl.monitor({
    output   = "eDP-1",
    mode     = "1440x900@59.89",
    position = "1920x0",
    scale    = 1,
    bitdepth = 8,
    vrr      = 0,
})
