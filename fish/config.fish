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
