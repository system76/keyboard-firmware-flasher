#!/usr/bin/env bash

set -e
set -m

####################
##     CONFIG     ##
####################

# Name of keyboards, name must match name in system76/qmk_firmware/tree/master/keyboards/system76
# And the hash to checkout when flashing the keyboard
declare -A KEYBOARDS
KEYBOARDS=([launch_heavy_1]="223cd288c5903d9378e1ec2411d0930c359336b1"
	   [launch_lite_1]="7fd2f588fd8798b635c630796124a49bdd587c3e"
	   [launch_1]="ee4be795927e18b85123f921c2e3747bdca17113"
	   [launch_2]="d235be6729095d07bb578981a4866e1c16fb86aa"
)

# The URL of the system76 repo to https clone
REPO="https://github.com/system76/qmk_firmware.git"


####################
##   END CONFIG   ##
####################

function close {
	gum style --background 52 --foreground 555 --align center --width 75 --margin "1 2" --padding "10 4" --underline --bold 'Flashing Failed!' "$1"
	sleep 3
	exit
	
}

# Install dependencies if not installed already, then install [gum](https://github.com/charmbracelet/gum)
# We are assuming if gum isn't installed, then we need to install other deps as well
if ! $(dpkg --get-selections gum | grep install -q); then
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
	echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
	sudo apt-get update && sudo apt-get install gum avrdude gcc-avr avr-libc -y
	clear
fi

# Pretty Print Name
gum style --foreground 214 --align center --width 50 --margin "1 2" --padding "2 4" --underline 'System76 Keyboard Firmware Imager'

# Get requested keyboard firmware
gum style --foreground 214 --align left --width 50 'Choose the plugged in keyboard:'
keyboard=$(gum choose --cursor.foreground="214" --item.foreground="555" "${!KEYBOARDS[@]}")
clear

# If build dir doesn't exist, create it
if ! [ -e ../qmk_firmware ]; then
	mkdir ../qmk_firmware
fi

# We have a repository for each keyboard, so we dont have to checkout different commits for each
# keyboard all the time. If it doesn't exist, clone it
if ! [ -d ../qmk_firmware/$keyboard/keyboards/system76/$keyboard ]; then
	gum spin --spinner globe --title "Downloading keyboard firmware. This may take a while..." -- git clone $REPO ../qmk_firmware/$keyboard --single-branch \
	|| close "Git clone failed. $?"
fi

# Pull latest changes from repo (always), and checkout the correct commit, and update submodules
current_dir=$(pwd)
cd "../qmk_firmware/$keyboard"

gum spin --spinner globe --title "Pulling down latest firmware..." -- git pull origin || close "'git pull origin' failed $?"
gum spin --spinner minidot --title "Switching to latest firmware..." -- git checkout ${KEYBOARDS[$keyboard]} || close "'git checkout ${KEYBOARDS[$keyboard]}' failed $?"
gum spin --spinner minidot --title "Building firmware submodules. This may take a while..." -- make git-submodule || close "submodule `make` failed $?"

# Confirm the action, and then install firmware
# Run the flashing `make` command in the background. Its output is written to a file `tmp` we follow that file
# listening for keywords, and provde instruction when each match is found.
gum style --foreground 120 --align left --width 50 --padding "2 4" "Are you ready to install $keyboard firmware?"
yes_text="Yes, Install $keyboard firmware!"
confirm=$(gum choose --cursor.foreground="214" --item.foreground="555" "$yes_text" "No, exit now.")
if [ "$confirm" == "$yes_text" ]; then
	$current_dir/src/flash.sh $keyboard &
	gum spin --spinner minidot --title "Building Firmware..." -- grep -q 'Bootloader not found. Trying again in 5s.' <(tail -f ./tmp) \
	&& gum style --foreground 120 --align left --width 75 --underline "Now we need to flash the keyboard's firmware:" \
	&& gum style --foreground 120 --align left --width 75 --padding "2 4" --bold "1) Unplug Keyboard" "" "2) Hold the Esc key" "" "3) Continue to hold Esc and plug in the keyboard" \
	&& gum spin --spinner minidot --title "Flashing Firmware" -- grep -q 'Bootloader Version:' <(tail -f ./tmp) \
	&& clear \
	&& gum style --background 22 --foreground 555 --align center --width 75 --margin "1 2" --padding "10 4" --underline --bold 'Flashing complete!' \
	&& echo "You may now let go of the Esc key" \
	&& sleep 3 \
	&& exit \
	|| close $?
else
	close
fi

rm tmp
