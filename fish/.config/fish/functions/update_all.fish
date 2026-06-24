function update_all --wraps='paru && sudo flatpak update && sudo pacman -Syu' --description 'alias update_all=yay && sudo flatpak update && sudo pacman -Syu'
    paru && sudo flatpak update && sudo pacman -Syu $argv
end
