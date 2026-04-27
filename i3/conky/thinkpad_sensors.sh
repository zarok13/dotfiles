#!/bin/bash

find_thinkpad_hwmon() {
    for hwmon in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon/name" ] && [ "$(cat "$hwmon/name")" = "thinkpad" ]; then
            echo "$hwmon"
            return 0
        fi
    done
    echo ""
}

case "$1" in
    "temp")
        hwmon_path=$(find_thinkpad_hwmon)
        if [ -n "$hwmon_path" ] && [ -f "$hwmon_path/temp1_input" ]; then
            temp=$(cat "$hwmon_path/temp1_input")
            echo "$((temp / 1000))"
        else
            echo "0"
        fi
        ;;
    "fan")
        hwmon_path=$(find_thinkpad_hwmon)
        if [ -n "$hwmon_path" ] && [ -f "$hwmon_path/fan1_input" ]; then
            cat "$hwmon_path/fan1_input"
        else
            echo "0"
        fi
        ;;
    *)
        echo "Usage: $0 {temp|fan}"
        exit 1
        ;;
esac
