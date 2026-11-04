#!/usr/bin/env bash
# ~/.config/hypr/scripts/wallpaper-cycle.sh
#
# Usage:
#   wallpaper-cycle.sh next     # advance  → applies to ALL monitors
#   wallpaper-cycle.sh prev     # go back  → applies to ALL monitors
#   wallpaper-cycle.sh random   # pick a random image (≠ current) → ALL monitors
#   wallpaper-cycle.sh apply    # re-apply current image to ALL monitors
#   wallpaper-cycle.sh init     # seed index from STATIC_IMAGE (called at startup)
#   wallpaper-cycle.sh show     # print current image path (debug)
#
# Wallpapers come from $WALLPAPER_DIR (default ~/Pictures/wallpapers3).

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers3}"
STATIC_IMAGE="${STATIC_IMAGE:-$WALLPAPER_DIR/forest-vector-wallpapers.jpg}"
ACTION="${1:-next}"

TRANSITION_TYPE="${TRANSITION_TYPE:-wave}"
TRANSITION_FPS="${TRANSITION_FPS:-60}"
TRANSITION_STEP="${TRANSITION_STEP:-10}"

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/awww-cycle"
STATE_FILE="$STATE_DIR/index"
mkdir -p "$STATE_DIR"

# --- build sorted image list (shared by all monitors) -----------------------
mapfile -t IMAGES < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort
)
N=${#IMAGES[@]}
if [ "$N" -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR" >&2
    exit 1
fi

# --- load current index -----------------------------------------------------
cur=-1
if [ -s "$STATE_FILE" ]; then
    raw=$(<"$STATE_FILE")
    case "$raw" in
        ''|*[!0-9-]*) cur=-1 ;;
        *)            cur=$raw ;;
    esac
fi

# --- state machine ----------------------------------------------------------
case "$ACTION" in
    init)
        # Seed the index to the static image's position so the first `next`
        # shows the following file, not the static image again.
        cur=-1
        for i in "${!IMAGES[@]}"; do
            [ "${IMAGES[$i]}" = "$STATIC_IMAGE" ] && { cur=$i; break; }
        done
        echo "$cur" > "$STATE_FILE"
        echo "Seeded index=$cur (of $N) at $STATIC_IMAGE"
        exit 0
        ;;
    next)  if [ "$cur" -lt 0 ]; then cur=0; else cur=$(( (cur + 1) % N )); fi ;;
    prev)  if [ "$cur" -lt 0 ]; then cur=$(( N - 1 )); else cur=$(( (cur - 1 + N) % N )); fi ;;
    random)
        # If only one wallpaper exists, reuse it. Otherwise pick any index ≠ cur.
        if [ "$N" -eq 1 ]; then
            cur=0
        else
            while :; do
                r=$(( RANDOM % N ))
                [ "$r" -ne "$cur" ] && { cur=$r; break; }
            done
        fi
        ;;
    apply) [ "$cur" -lt 0 ] && cur=0 ;;
    show)  [ "$cur" -lt 0 ] && { echo "(none yet)"; exit 0; } ; echo "${IMAGES[$cur]}"; exit 0 ;;
    *)     echo "Usage: $0 {next|prev|random|apply|init|show}" >&2; exit 1 ;;
esac

echo "$cur" > "$STATE_FILE"
IMG="${IMAGES[$cur]}"
echo "Applying [$((cur + 1))/$N] $IMG (all monitors)"

# --- ensure daemon is up ----------------------------------------------------
if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon &
    sleep 0.5
fi

# No `-o` → applies to every output Hyprland reports.
awww img "$IMG" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-fps  "$TRANSITION_FPS" \
    --transition-step "$TRANSITION_STEP"
