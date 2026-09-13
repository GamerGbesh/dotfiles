function ws-layout
        if test (count $argv) -eq 1
                set workspace (hyprctl activeworkspace -j | jq -r '.id')
                set layout $argv[1]
        else if test (count $argv) -eq 2
                set workspace $argv[1]
                set layout $argv[2]
        else
                echo "Usage: ws-layout <layout>"
                echo "       ws-layout <workspace> <layout>"
                return 1
        end
    
        hyprctl eval "hl.workspace_rule({workspace = '$workspace', layout = '$layout'})"
end
