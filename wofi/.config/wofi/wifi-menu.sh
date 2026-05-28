#!/usr/bin/env bash

FIELDS="SSID,SECURITY"
POSITION="center"

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')


KNOWNCON=$(nmcli connection show)
CONSTATE=$(nmcli -fields WIFI g)

CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi \
    | awk -F: '$1 ~ /^yes/ {print $2}')

if [[ "$CONSTATE" =~ "enabled" ]]; then
    TOGGLE="󰖩  Disable Wi-Fi"
else
    TOGGLE="󰖪  Enable Wi-Fi"
fi

MENU=$(printf "%s\nmanual\n%s" "$TOGGLE" "$LIST")

CHENTRY=$(echo -e "$MENU" | uniq -u | wofi \
    --dmenu \
    --insensitive \
    --prompt "Wi-Fi" \
    --width 700 \
    --height 500 \
    --location center \
    --conf ~/.config/wofi/config \
    --style ~/.config/wofi/style.css)

CHSSID=$(echo "$CHENTRY" \
    | sed 's/\s\{2,\}/|/g' \
    | awk -F "|" '{print $1}')

if [ "$CHENTRY" = "manual" ]; then

    MSSID=$(echo "" | wofi \
        --dmenu \
        --prompt "SSID,password" \
        --lines 1 \
        --width 500 \
        --conf ~/.config/wofi/config \
        --style ~/.config/wofi/style.css)

    MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
    MSSIDONLY=$(echo "$MSSID" | awk -F "," '{print $1}')

    if [ -z "$MPASS" ]; then
        nmcli dev wifi connect "$MSSIDONLY"
    else
        nmcli dev wifi connect "$MSSIDONLY" password "$MPASS"
    fi

elif [[ "$CHENTRY" =~ "Enable Wi" ]]; then
    nmcli radio wifi on

elif [[ "$CHENTRY" =~ "Disable Wi" ]]; then
    nmcli radio wifi off

else

    if [ "$CHSSID" = "*" ]; then
        CHSSID=$(echo "$CHENTRY" \
            | sed 's/\s\{2,\}/|/g' \
            | awk -F "|" '{print $3}')
    fi

    if nmcli connection show | grep -q "$CHSSID"; then

        nmcli connection up "$CHSSID"

    else

        if [[ "$CHENTRY" =~ "WPA" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then

            WIFIPASS=$(echo "" | wofi \
                --dmenu \
                --password \
                --prompt "Password" \
                --lines 1 \
                --width 500 \
                --conf ~/.config/wofi/config \
                --style ~/.config/wofi/style.css)
        fi

        nmcli dev wifi connect "$CHSSID" password "$WIFIPASS"
    fi
fi
