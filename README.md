## Install
1) `sudo ./install.sh` from within this directory
2) Add `Keyboard Firmware Flasher` to the dock.
**NOTE:**The first run of this program will likely require admin privledges to install dependences, but following runs will not. Please make sure one keyboard has been sucessfully flashed before handing off to production.

This is a temporary (famous last words) solution for production to be able to flash any launch firmware on any launch.

Currently this is just a basic script that uses [gum](https://github.com/charmbracelet/gum) to simplify the process. Though this should eventually be added into the [keyboard-configurator](https://github.com/pop-os/keyboard-configurator/).

This script will "auto update" itself. It pulls from the main branch before running.
