#!/usr/bin/env bash
set -eu

TIME_FILE="/tinytmp/arttime.txt"
TIME_FILE2=$(mktemp /tinytmp/arttime.XXXXXXXXXX)
MUSIC_FILE="/tinytmp/artmusic.txt"
TEMP_FILE=$(mktemp /tinytmp/artmusic.XXXXXXXXXX)

bye() {
    rm -f "$TEMP_FILE" "$TIME_FILE" "$MUSIC_FILE"
    echo # yeah, this is dumb
    exit 1
}

trap bye SIGINT SIGTERM

echo "Click inside Spotify window or press Ctrl-C"
id=$(xwininfo | sed -En 's/.*Window id: (0x[0-9a-fA-F]+).*/\1/p')
echo "Ok"

# background
while true; do
    date '+%H:%M %Z' >"$TIME_FILE2"
    if ! cmp -s "$TIME_FILE" "$TIME_FILE2"; then
        mv "$TIME_FILE2" "$TIME_FILE"
    fi
    sleep 1
done &

# foreground
while true; do
    if xprop -id $id >"$TEMP_FILE"; then
        sed_err=no
        name=$(sed <"$TEMP_FILE" -En \
            's/_NET_WM_NAME\(UTF8_STRING\) = "([^"]*)"/\1/p' \
            || sed_err=yes)
        if [[ $sed_err == yes ]]; then
            echo "[can't get track title]"
        elif [[ "$name" == Spotify ]]; then
            echo "[no music]"
        else
            echo "$name" | sed -r 's/ - / – /'
        fi >"$TEMP_FILE"
        if ! cmp -s "$TEMP_FILE" "$MUSIC_FILE"; then
            mv "$TEMP_FILE" "$MUSIC_FILE"
        fi
    else
        cat "$TEMP_FILE" >&2
        echo "[can't get track title]" >"$TEMP_FILE"
        mv "$TEMP_FILE" "$MUSIC_FILE"
        sleep inf
    fi

    sleep 1
done
