if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias gs='git status'
alias gac='git add . && git commit -m'

starship init fish | source
