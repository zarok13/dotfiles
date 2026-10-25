hl.config({
    input = {
        -- keyboard
        kb_layout    = "us,ru,ge",
        kb_options   = "grp:alt_space_toggle",
        repeat_delay = 650,
        repeat_rate  = 20,

        -- mouse (-1 slowest to 1 fastest, same range as sway)
        accel_profile = "flat",
        sensitivity   = 0.2,

        -- touchpad
        touchpad = {
            tap_to_click   = true,
            natural_scroll = true,
        },
    },

    cursor = {
        inactive_timeout = 30,  -- seconds (sway used 30000 ms)
    },
})

-- cursor theme and size
hl.env("XCURSOR_THEME", "Qogir")
hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_SIZE", "30")
