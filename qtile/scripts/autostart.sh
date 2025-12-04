#!/bin/bash

function run {
	if ! pgrep -x $(basename $1 | head -c 15) 1>/dev/null;
	then
		$@&
	fi
}

#mouse settings values range from -1 (slowest) to 1 (fastest).
xinput set-prop "pointer:Logitech Wireless Mouse" "libinput Accel Speed" -0.5

#monitors setting HDMI-1 after primary-2
xrandr --newmode "1440x900" 106.50 1440 1528 1672 1904 900 903 909 934 -hsync +vsync
xrandr --addmode eDP-1 "1440x900"
xrandr --output eDP-1 --mode "1440x900"
xrandr --output HDMI-1 --mode 1920x1080 --left-of eDP-1  --output eDP-1 --mode "1440x900"
#xrandr --output HDMI-1 --auto --left-of eDP-1

#export SESSION_MANAGER="local/$HOSTNAME:0.0"

run xfce4-power-manager &
run blueman-applet &
run nm-applet &
run conky -d
run sxhkd -c $HOME/.config/qtile/sxhkd/sxhkdrc &
run picom -b &
run nitrogen --restore &
run flameshot &
run firewall-applet &
run gammastep-indicator &
run lxpolkit &
#feh --bg-fill $HOME/Pictures/wallpapers2/0001.jpg

