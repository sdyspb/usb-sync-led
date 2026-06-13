#!/bin/bash

RED_LED="/sys/class/leds/red/brightness"
GREEN_LED="/sys/class/leds/green"
GREEN_TRIGGER="$GREEN_LED/trigger"
GREEN_BRIGHT="$GREEN_LED/brightness"

# Save original green LED trigger
save_green_trigger() {
    if [ -f "$GREEN_TRIGGER" ]; then
        ORIG_TRIGGER=$(cat "$GREEN_TRIGGER" | sed -n 's/.*\[\(.*\)\].*/\1/p')
        [ -z "$ORIG_TRIGGER" ] && ORIG_TRIGGER="default-on"
    else
        ORIG_TRIGGER="default-on"
    fi
}

# Disable green LED (take control)
disable_green() {
    [ -f "$GREEN_TRIGGER" ] && echo none > "$GREEN_TRIGGER" 2>/dev/null
    [ -f "$GREEN_BRIGHT" ] && echo 0 > "$GREEN_BRIGHT" 2>/dev/null
}

# Restore green LED to original state
restore_green() {
    [ -f "$GREEN_TRIGGER" ] && echo "$ORIG_TRIGGER" > "$GREEN_TRIGGER" 2>/dev/null
    [ -f "$GREEN_BRIGHT" ] && echo 255 > "$GREEN_BRIGHT" 2>/dev/null
}

# Red LED control
red_on()  { echo 255 > "$RED_LED"; }
red_off() { echo 0   > "$RED_LED"; }

# Initialize
save_green_trigger
restore_green
red_off

# Detect active USB backup
is_backup_active() {
    pgrep -f "/var/lib/openmediavault/usbbackup.d/systemd-" > /dev/null && return 0
    pgrep -f "rsync.*--delete.*--log-file" > /dev/null && return 0
    pgrep -f "rsync.*--delete.*/srv/" > /dev/null && return 0
    pgrep -f "rsync.*--log-file.*usbbackup" > /dev/null && return 0
    return 1
}

# Main loop
while true; do
    if is_backup_active; then
        red_on
        disable_green
    else
        red_off
        restore_green
    fi
    sleep 0.5
done
