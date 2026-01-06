dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-8'


powersave='󰌪 '
balance=' '
performance='󰓅 '
turbo='󱐋'
yes=''
no='󰜺'
rofi_cmd() {
	rofi -dmenu \
		-theme ${dir}/${theme}.rasi
}
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
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
	echo -e "$powersave\n$balance\n$performance\n$turbo" | rofi_cmd
}
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--powersave' ]]; then
			sudo power-saver.sh
		elif [[ $1 == '--balance' ]]; then
			sudo balance.sh
		elif [[ $1 == '--performance' ]]; then
			sudo performance.sh
		elif [[ $1 == '--turbo' ]]; then
            sudo turbo.sh
		fi
	else
		exit 0
	fi
}
chosen="$(run_rofi)"
case ${chosen} in
    $powersave)
		run_cmd --powersave
        ;;
    $balance)
		run_cmd --balance
        ;;
    $performance)
        run_cmd --performance
        ;;
    $turbo)
		run_cmd --turbo
        ;;
esac
