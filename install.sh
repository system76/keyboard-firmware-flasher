#!/usr/bin/env bash

echo "[Desktop Entry]
Name=Keyboard Firmware Flasher
Comment=Internal Tool
Exec=$(pwd)/src/run.sh
Path=$(pwd)
Icon=org.gnome.Terminal
Terminal=true
Type=Application" > /usr/share/applications/keyboard-firmware-flasher.desktop
