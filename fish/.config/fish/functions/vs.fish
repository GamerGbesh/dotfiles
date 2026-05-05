function vs --description "Open VS Code and exit shell"
    if test (count $argv) -eq 0
        code .; and exit
    else
        code $argv; and exit
    end
end
