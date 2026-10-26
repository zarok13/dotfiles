#!/usr/bin/env bash
dir="$1"
[[ "$dir" == up || "$dir" == down ]] || { echo "Usage: ${0##*/} up|down" >&2; exit 1; }

active=$(hyprctl activeworkspace -j)
mon=$(jq '.monitorID' <<<"$active")
cur=$(jq '.id' <<<"$active")

target=$(hyprctl workspaces -j | jq -r --argjson m "$mon" --argjson c "$cur" --arg d "$dir" '
  [.[] | select(.monitorID == $m and .id > 0) | .id] | sort as $ids
  | ($ids | index($c)) as $i
  | if $i == null then empty
    elif $d == "up"   then (if $i > 0 then $ids[$i - 1] else empty end)
    else (if $i < ($ids | length - 1) then $ids[$i + 1] else empty end) end
')

[[ -n "$target" ]] && hyprctl dispatch "hl.dsp.focus({ workspace = \"$target\" })"
