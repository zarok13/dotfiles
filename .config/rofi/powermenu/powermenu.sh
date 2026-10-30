#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/powermenu"
theme='style-1'

# Options
lock='󰌾 Lock'
suspend='󰒲 Suspend'
hibernate='󰋊 Hibernate'
logout='󰍃 Logout'
reboot='󰜉 Reboot'
shutdown='󰐥 Shutdown'
yes='󰄬 Yes'
no='󰜺 No'

rofi_cmd() {
	rofi -dmenu \
		-p "power menu" \
		-theme ${dir}/${theme}.rasi
}

confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}

confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
	echo -e "$lock\n$suspend\n$hibernate\n$logout\n$reboot\n$shutdown" | rofi_cmd
}


lock_screen() {
    swaylock -f \
    --screenshots \
    --clock \
    --timestr "%H:%M" \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --effect-blur 7x5 \
    --effect-vignette 0.5:0.5 \
    --effect-greyscale \
    --ring-color a89984 \
    --ring-clear-color fabd2f \
    --ring-ver-color 83a598 \
    --ring-wrong-color fb4934 \
    --key-hl-color fe8019 \
    --bs-hl-color fb4934 \
    --inside-color 28282888 \
    --inside-clear-color 28282888 \
    --inside-ver-color 28282888 \
    --inside-wrong-color 28282888 \
    --line-color 00000000 \
    --separator-color 00000000 \
    --text-color ebdbb2 \
    --text-clear-color fabd2f \
    --text-ver-color 83a598 \
    --text-wrong-color fb4934 \
    --fade-in 0.1 \
    --font-size 25 \
    --layout-bg-color 00000000 \
    --layout-text-color 928374
}

run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			systemctl suspend
        elif [[ $1 == '--hibernate' ]]; then
			systemctl hibernate
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'qtile' ]]; then
				qtile cmd-obj -o cmd -f shutdown
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
            elif [[ "$DESKTOP_SESSION" == 'sway' ]]; then
                swaymsg exit
            elif [[ "$DESKTOP_SESSION" == 'hyprland' ]]; then
                hyprctl dispatch exit
			fi
		fi
	else
		exit 0
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $lock)
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
            if [[ -x '/usr/bin/swaylock' ]]; then
                mpc -q pause
                lock_screen
            fi
        else
            if [[ -x '/usr/bin/betterlockscreen' ]]; then
                betterlockscreen -l
            elif [[ -x '/usr/bin/i3lock' ]]; then
                i3lock
            fi
        fi
        ;;
    $suspend)
        run_cmd --suspend
        ;;
    $hibernate)
        run_cmd --hibernate
        ;;
    $logout)
		run_cmd --logout
        ;;
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
esac
