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

export QT_IM_MODULE=ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

~/.config/i3/polybar/launch.sh &

run xfce4-power-manager &
run blueman-applet &
run nm-applet &
run conky -c ~/.config/i3/conky/conky.conf -d
run sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &
run picom --config ~/.config/i3/picom/picom.conf -b &
run nitrogen --restore &
run flameshot &
run firewall-applet &
run gammastep-indicator 
run lxpolkit &
ibus-daemon -rxRd
#feh --bg-fill $HOME/Pictures/wallpapers2/0001.jpg

