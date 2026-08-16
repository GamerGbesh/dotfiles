function update_all --wraps='yay && sudo flatpak update && sudo pacman -Syu' --description 'alias update_all=yay && sudo flatpak update && sudo pacman -Syu'
    yay && sudo flatpak update && sudo pacman -Syu $argv
end
