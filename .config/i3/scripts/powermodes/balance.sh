#!/bin/bash

# 1. Scaling Governor
#see available governors by running: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 2. Energy Performance Preference (EPP)
#EPP: see available preferences by running: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences: default performance balance_performance balance_power power
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then
    echo "balance_power" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
fi

# 3. Energy Performance Bias (EPB)
# EPB (Energy Performance Bias) for the intel_pstate driver
# see conversion info: https://www.kernel.org/doc/html/latest/admin-guide/pm/intel_epb.html
# available EPB options include a numeric value between 0-15
# (where 0 = maximum performance and 15 = maximum power saving),
# or one of the following strings:
# performance (0), balance_performance (4), default (6), balance_power (8), or power (15)
if [ -f /sys/devices/system/cpu/cpu0/power/energy_perf_bias ]; then
    echo "8" | tee /sys/devices/system/cpu/cpu*/power/energy_perf_bias
fi

# 4. Platform Profile
# See available options by running:
# cat /sys/firmware/acpi/platform_profile_choices
# low-power balanced performance
if [ -f /sys/firmware/acpi/platform_profile ]; then
    echo "balanced" | tee /sys/firmware/acpi/platform_profile
fi

# 5. Scaling Max Frequency
# Value is in kHz (1700000 = 1.7GHz)
# echo "1700000" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq

# 6. Turbo Boost
#enable: 0, disable: 1
if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
    echo "1" | tee /sys/devices/system/cpu/intel_pstate/no_turbo
fi

echo "Balance power profile applied."
