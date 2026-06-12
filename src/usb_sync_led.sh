#!/bin/bash

# === CONFIGURATION ===
RED_LED="/sys/class/leds/red/brightness"
GREEN_LED="/sys/class/leds/green"
GREEN_TRIGGER="$GREEN_LED/trigger"
GREEN_BRIGHT="$GREEN_LED/brightness"
DEBOUNCE_SEC=2
# ====================

save_green_trigger() {
    if [ -f "$GREEN_TRIGGER" ]; then
        ORIG_TRIGGER=$(cat "$GREEN_TRIGGER" | sed -n 's/.*\[\(.*\)\].*/\1/p')
        [ -z "$ORIG_TRIGGER" ] && ORIG_TRIGGER="default-on"
    else
        ORIG_TRIGGER="default-on"
    fi
}

disable_green() {
    [ -f "$GREEN_TRIGGER" ] && echo none > "$GREEN_TRIGGER" 2>/dev/null
    [ -f "$GREEN_BRIGHT" ] && echo 0 > "$GREEN_BRIGHT" 2>/dev/null
}

restore_green() {
    [ -f "$GREEN_TRIGGER" ] && echo "$ORIG_TRIGGER" > "$GREEN_TRIGGER" 2>/dev/null
    [ -f "$GREEN_BRIGHT" ] && echo 255 > "$GREEN_BRIGHT" 2>/dev/null
}

red_on()  { echo 255 > "$RED_LED"; }
red_off() { echo 0   > "$RED_LED"; }

save_green_trigger
restore_green

red_active=0
debounce_pid=""

while true; do
    if pgrep -f "/var/lib/openmediavault/usbbackup.d/systemd-" > /dev/null; then
        if [ $red_active -eq 0 ]; then
            red_on
            disable_green
            red_active=1
            [ -n "$debounce_pid" ] && kill $debounce_pid 2>/dev/null && debounce_pid=""
        fi
    else
        if [ $red_active -eq 1 ] && [ -z "$debounce_pid" ]; then
            (
                sleep $DEBOUNCE_SEC
                if ! pgrep -f "/var/lib/openmediavault/usbbackup.d/systemd-" > /dev/null; then
                    red_off
                    restore_green
                fi
            ) &
            debounce_pid=$!
            sleep 0.1
        fi
    fi
    sleep 0.5
done
