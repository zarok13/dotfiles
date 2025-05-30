#!/bin/bash

function run {
	if ! pgrep -x $(basename $1 | head -c 15) 1>/dev/null;
	then
		$@&
	fi
}

#mouse settings values range from -1 (slowest) to 1 (fastest).
xinput set-prop "pointer:PIXART HP Wireless Keyboard and Mouse" "libinput Accel Speed" -0.5

#monitors setting HDMI-1 after primary-2
xrandr --newmode "1440x810_60.00" 95.50 1440 1512 1656 1872 810 813 823 831 -hsync +vsync
xrandr --addmode eDP-1 "1440x810_60.00"
xrandr --output eDP-1 --mode "1440x810_60.00"
xrandr --output HDMI-1 --mode 1920x1080 --output eDP-1 --mode "1440x810_60.00"
xrandr --output HDMI-1 --auto --left-of eDP-1

#export SESSION_MANAGER="local/$HOSTNAME:0.0"

run xfce4-power-manager &
run blueman-applet &
#run bluetoothctl power off &
run nm-applet &
run conky -d
run sxhkd -c $HOME/.config/qtile/sxhkd/sxhkdrc &
run picom -b &
run nitrogen --restore &
run flameshot &
run lxpolkit &
#feh --bg-fill $HOME/Pictures/wallpapers2/0001.jpg

