set -e fish_user_paths
set -U fish_user_paths $HOME/.bin  $HOME/.local/bin /var/lib/flatpak/exports/bin/ $fish_user_paths

set fish_greeting

set -g __fish_git_autostatus 0
set -U fish_color_command brgreen
if status is-interactive
end

alias gs='git status'
alias gac='git add . && git commit -m'

starship init fish | source
set -gx EDITOR vim

if status is-login
    # Check if Sway or Wayland is targeted
    if test "$XDG_SESSION_TYPE" = "wayland" -o "$XDG_CURRENT_DESKTOP" = "sway"
        set -gx QT_QPA_PLATFORM wayland
        set -gx XDG_CURRENT_DESKTOP sway
        set -gx XDG_SESSION_DESKTOP sway
    end
end
