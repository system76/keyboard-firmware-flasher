#!/usr/bin/env bash

echo "[Desktop Entry]
Name=Keyboard Firmware Flasher
Comment=Internal Tool
Exec=$(pwd)/src/run.sh
Path=$(pwd)
Icon=/path/to/icon
Terminal=false
Type=Application" > /usr/share/applications/keyboard-firmware-flasher.desktop
