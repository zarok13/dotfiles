#!/usr/bin/env bash

STATUS=$(cat /sys/devices/system/cpu/cpu0/power/energy_perf_bias)
case $STATUS in
    "15")
        icon="󰾆";
        text="POWER SAVE"
        fg="#458588"
        ;;
    "8")
        icon="󰾅";
        text="BALANCE"
        fg="#98971a"
        ;;
    "4")
        icon="󰓅";
        text="PERFORMANCE"
        fg="#d79921"
        ;;
    "0")
        icon="󰈸";
        text="TURBO"
        fg="#cc241d"
        ;;
esac

echo "<span foreground='$fg'><span font_family='$FONT'>$icon</span> $text</span>"
