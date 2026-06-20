function launch
    hyprctl dispatch "hl.dsp.exec_cmd('[workspace $argv[1] silent] $argv[2]')"
end
