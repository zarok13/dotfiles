gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Light"
#!/bin/bash

# --- Configuration ---
# File to store the current theme mode
THEME_MODE_FILE="$HOME/.theme_mode"
# Directories for your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
#DARK_WALLPAPERS="$WALLPAPER_DIR/Dark"
#LIGHT_WALLPAPERS="$WALLPAPER_DIR/Light"

# --- Determine Current and Next Mode ---
if [ "$(cat "$THEME_MODE_FILE" 2>/dev/null)" = "Light" ]; then
    NEXT_MODE="Dark"
    #WALLPAPER_PATH="$DARK_WALLPAPERS"
else
    NEXT_MODE="Light"
    #WALLPAPER_PATH="$LIGHT_WALLPAPERS"
fi

# --- Update Theme Mode File ---
echo "$NEXT_MODE" > "$THEME_MODE_FILE"

# --- Function to Send a Notification ---
notify_user() {
    notify-send -u low "Theme Switched" "Mode set to $NEXT_MODE"
}

# --- Apply Changes Based on the New Mode ---
if [ "$NEXT_MODE" = "Dark" ]; then
    # 1. Update GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

    # 2. Update Kitty terminal colors
    #sed -i 's/^foreground .*/foreground #dddddd/' ~/.config/kitty/kitty.conf
    #sed -i 's/^background .*/background #000000/' ~/.config/kitty/kitty.conf
    #kill -SIGUSR1 $(pidof kitty) 2>/dev/null

    # 3. Update Waybar style (example using symlinks)
    # ln -sf ~/.config/waybar/style/[Dark]*.css ~/.config/waybar/style.css
    # killall -SIGUSR2 waybar

    # 4. Set Wallpaper (requires swww or hyprpaper)
    # swww img "$WALLPAPER_PATH/$(ls "$WALLPAPER_PATH" | shuf -n 1)"
else
    # 1. Update GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Light"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"

    # 2. Update Kitty terminal colors
    #sed -i 's/^foreground .*/foreground #000000/' ~/.config/kitty/kitty.conf
    #sed -i 's/^background .*/background #dddddd/' ~/.config/kitty/kitty.conf
    #kill -SIGUSR1 $(pidof kitty) 2>/dev/null

    # 3. Update Waybar style
    # ln -sf ~/.config/waybar/style/[Light]*.css ~/.config/waybar/style.css
    # killall -SIGUSR2 waybar

    # 4. Set Wallpaper
    # swww img "$WALLPAPER_PATH/$(ls "$WALLPAPER_PATH" | shuf -n 1)"
fi

# --- Notify the User ---
notify_user
