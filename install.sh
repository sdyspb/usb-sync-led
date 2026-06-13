
#!/bin/bash
set -e

echo "Installing usb-sync-led for BananaNAS..."

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

SCRIPT_SRC="./src/usb_sync_led.sh"
SCRIPT_DEST="/usr/local/bin/usb_sync_led.sh"
SERVICE_FILE="/etc/systemd/system/usb-sync-led.service"

if [ ! -f "$SCRIPT_SRC" ]; then
    echo "Error: $SCRIPT_SRC not found."
    exit 1
fi

cp "$SCRIPT_SRC" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=USB Sync LED Indicator for BananaNAS
After=multi-user.target

[Service]
Type=simple
ExecStart=$SCRIPT_DEST
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable usb-sync-led.service
systemctl start usb-sync-led.service

if systemctl is-active --quiet usb-sync-led.service; then
    echo "✅ usb-sync-led is now active."
    echo "   Check status: sudo systemctl status usb-sync-led"
else
    echo "❌ Service failed to start. Check logs: journalctl -u usb-sync-led -e"
    exit 1
fi
