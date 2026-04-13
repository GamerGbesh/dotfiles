function hyprconf --wraps='cd ~/.config/hypr; and nvim; and cd -' --wraps='cd ~/.config/hypr && nvim $argv; and cd -'
    set -l prev $PWD
    builtin cd ~/.config/hypr
    nvim $argv
    builtin cd $prev
end
