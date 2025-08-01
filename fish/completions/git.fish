function __fish_git_using_command
    set cmd (commandline -opc)
    set subcommands $argv
    for subcommand in $subcommands
        if contains -- $subcommand $cmd
            return 0
        end
    end
    return 1
end

function __fish_git_add_files
    find . -maxdepth 1 \( -type f -o -type d \) -not -path '*/\.*' | sed 's|^\./||'
end

complete -c git -n '__fish_git_using_command add' -a '(__fish_git_add_files)' -f

