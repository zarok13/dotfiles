#!/bin/bash
STATUS=$(cat /sys/devices/system/cpu/cpu0/power/energy_perf_bias)
case $STATUS in
    "15")
        echo "  POWER SAVE"
        ;;
    "8")
        echo "   BALANCE"
        ;;
    "4")
        echo "   PERFORMANCE"
        ;;
    "0")
        echo "   TURBO"
        ;;
    *)
        echo "DEFAULT"
        ;;
esac
