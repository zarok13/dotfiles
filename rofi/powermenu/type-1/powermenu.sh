#!/usr/bin/env bash

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-1"
theme='style-1'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"

# Options
lock='🔒Lock'
suspend='🌙 Sleep'
hibernate='💤 Hibernate'
logout='🚪 Logout'
reboot='🔄 Reboot'
shutdown='⏻ Shutdown'
yes='󰄬 Yes'
no='󰅖 No'

rofi_cmd() {
	rofi -dmenu \
		-p "power menu" \
		-mesg "Uptime: $uptime" \
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

run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--lock' ]]; then
            if [[ -n "$WAYLAND_DISPLAY" ]]; then
                if [[ -x '/usr/bin/swaylock' ]]; then
                    swaylock -f
                fi
            else
                if [[ -x '/usr/bin/betterlockscreen' ]]; then
                    betterlockscreen -l
                elif [[ -x '/usr/bin/i3lock' ]]; then
                    i3lock
                fi
            fi
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			systemctl suspend
		elif [[ $1 == '--hibernate' ]]; then
			mpc -q pause
			systemctl hibernate
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'qtile' ]]; then
				qtile cmd-obj -o cmd -f shutdown
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
            elif [[ "$DESKTOP_SESSION" == 'sway' ]]; then
                swaymsg exit
			fi
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		fi
	else
		exit 0
	fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $lock)
        run_cmd --lock
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
    $reboot)
		run_cmd --reboot
        ;;
    $shutdown)
		run_cmd --shutdown
        ;;
esac
