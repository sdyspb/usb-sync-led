# usb-sync-led – Visual LED indicator for USB backup on BananaNAS (Armbian + OMV)

**usb-sync-led** adds a physical LED status indicator to the `openmediavault-usbbackup` plugin.  
Useful for headless BananaNAS setups (BPI‑M7, Sige7) where you want immediate visual confirmation that an automatic USB backup is running.

## Features

- **Red LED** turns on while USB backup is active, turns off after completion.
- **Green system LED** is temporarily disabled during backup – makes red clearly visible.
- **Debounce protection** (2 seconds) prevents flickering on short `rsync` interruptions.
- **Non‑invasive** – monitors the plugin’s process, does not modify any OMV files.
- **Runs as a systemd service** – starts automatically on boot, low CPU overhead.

## Hardware requirements

- BananaNAS (BPI‑M7, Sige7) with integrated card reader or any SBC with external USB card reader.
- Built‑in **red** (`GPIO4_C5`) and **green** (`GPIO0_B7`) LEDs – already available on BananaNAS.
- OMV with **openmediavault-usbbackup** plugin installed.

## Software prerequisites

- Armbian
- OpenMediaVault
- `openmediavault-usbbackup` – configured backup job
- `openmediavault-resetperms` (recommended – see note about permissions)

## Installation

### 1. Install required OMV plugins

Via OMV web interface → **System > Plugins**:

- `openmediavault-usbbackup`
- `openmediavault-resetperms`

Configure your USB backup job as usual.

### 2. Install the LED indicator

SSH into your BananaNAS and run:

```bash
git clone https://github.com/YOUR_USERNAME/usb-sync-led.git
cd usb-sync-led
sudo chmod +x install.sh
sudo ./install.sh
