function zed --description "Open Zed Code and exit shell"
    if test (count $argv) -eq 0
        zeditor .; and exit
    else
        zeditor $argv; and exit
    end
end
