function hyprconf --wraps='cd ~/.config/hypr; and nvim; and cd -' --wraps='cd ~/.config/hypr && nvim $argv; and cd -'
    set -l prev $PWD
    builtin cd ~/.config/hypr

    set -l target .
    if test (count $argv) -gt 0
        set target $argv
    end
    nvim $target

    builtin cd $prev
end
