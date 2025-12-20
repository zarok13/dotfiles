#!/bin/bash

polybar-msg cmd quit

polybar -c ~/.config/i3/polybar/config.ini bar1 &
polybar -c ~/.config/i3/polybar/config.ini bar2 &
polybar -c ~/.config/i3/polybar/config.ini bar3 &
polybar -c ~/.config/i3/polybar/config.ini bar4 &
polybar -c ~/.config/i3/polybar/config.ini bar5 &
