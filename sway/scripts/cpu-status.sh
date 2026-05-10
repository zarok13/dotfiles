#!/bin/bash
STATUS=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)

case $STATUS in
    "power")
        echo " Power Save"
        ;;
    "balance_power")
        echo " Balance"
        ;;
    "performance")
        echo " Performance"
        ;;
    *)
        echo " $STATUS"
        ;;
esac

#if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
#    temp=$(cat /sys/class/thermal/thermal_zone*/temp)
#    echo $((temp/1000))°C
#else
#    echo "N/A"
#fi
