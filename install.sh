#!/bin/bash
#
# Ugeek Smart UPS V3 setup script.
#

TITLE="UGEEK WORKSHOP"
BACKTITLE="UGEEK WORKSHOP [ ugeek.aliexpress.com | ukonline2000.taobao.com ]"
INSTALLED=0
BRIGHTNESS=127
GPIO=18
FILENAME="smartups.py"
LIBNEO="neopixel.py"
FILEPATH="/usr/local/bin/"
SERVICENAME="smartups"
SERVICEFILE="smartups.service"
SERVICEPATH="/etc/systemd/system/"
SOFTWARE_LIST="scons"

function brightness_to_percent(){
	case $1 in 
		0)
		return 0
		;;
		26)
		return 1
		;;
		51)
		return 2
		;;
		77)
		return 3
		;;
		102)
		return 4
		;;
		127)
		return 5
		;;
		153)
		return 6
		;;
		179)
		return 7
		;;
		204)
		return 8
		;;
		230)
		return 9
		;;
		255)
		return 10
		;;
		*)
		return 5
		;;
	esac
}

function percnet_to_brightness() {
	case $1 in 
		0)
		return 0
		;;
		1)
		return 26
		;;
		2)
		return 51
		;;
		3)
		return 77
		;;
		4)
		return 102
		;;
		5)
		return 127
		;;
		6)
		return 153
		;;
		7)
		return 179
		;;
		8)
		return 204
		;;
		9)
		return 230
		;;
		10)
		return 255
		;;
		*)
		return 127
		;;
	esac
}

# install system required
function install_sysreq(){
	pip install rpi-ws281x
}
# get current gpio
function get_gpio(){
	if [ -f '$FILEPATH$FILENAME' ] ; then
		GPIO=$(grep -n '^LED_PIN' $FILEPATH$FILENAME | awk -F " " '{print $3}')
	else
		GPIO=$(grep -n '^LED_PIN' smartups.py | awk -F " " '{print $3}')
	fi
}

# get current brightness
function get_brightness(){
	BRIGHTNESS=$(grep -n '^LED_BRIGHTNESS' $FILEPATH$FILENAME | awk -F " " '{print $3}')
}

# check the script is installed
function check_installed(){
	if [ -f "$FILEPATH$FILENAME" ]; then
		if [ -f "$SERVICEPATH$SERVICEFILE" ]; then
			return 1
		fi
	fi
	return 0
}

function enable_service(){
	systemctl enable $SERVICENAME
}

function disable_service(){
	systemctl disable $SERVICENAME
}

function stop_service(){
	systemctl stop $SERVICENAME
}

function start_service(){
	systemctl start $SERVICENAME
}

# enable ups
function enable_ups(){
	echo "Enable ups"
	check_installed
	SOFT=$(dpkg -l $SOFTWARE_LIST | grep "<none>")
	if [ -n "$SOFT" ]; then
		apt update
		apt -y install $SOFTWARE_LIST
	fi
	SOFT=$(pip search rpi-ws281x | grep "INSTALLED")
	if [ -z "$SOFT" ]; then
		pip install rpi-ws281x
		echo "rpi-ws281x install complete!"
	else
		echo "rpi-ws281x already exists."
	fi
	if [ $? -eq 1 ]; then
		INSTALLED=1
		stop_service
		disable_service
	else
		INSTALLED=0
	fi
	if [ -f '$FILENAME' ]; then
		cp $FILENAME $FILEPATH$FILENAME
	fi
	if [ -f '$LIBNEO' ]; then
		cp $LIBNEO $FILEPATH$LIBNEO
	fi
	if [ -f '$SERVICEFILE' ]; then
		cp $SERVICEFILE $SERVICEPATH$SERVICEFILE
	fi
	enable_service
	start_service
	return
}

# disable ups
function disable_ups(){
	echo "Disable ups"
	check_installed
	if [ $? -eq 1 ]; then
		echo "disable ups"
		stop_service
		disable_service
		if [ -f '$FILEPATH$FILENAME' ]; then
			rm $FILEPATH$FILENAME
		fi
		if [ -f '$FILEPATH$LIBNEO' ]; then
			rm $FILEPATH$LIBNEO
		fi
		if [ -f '$SERVICEPATH$SERVICEFILE' ]; then
			rm $SERVICEPATH$SERVICEFILE
		fi
	fi
}

# menu gpio
function menu_gpio(){
	OPTION=$(whiptail --title "$TITLE" \
	--menu "Select the GPIO:" \
	--backtitle "$BACKTITLE" \
	--nocancel \
	14 60 6 \
	"1" "GPIO18" \
	"2" "GPIO12" 3>&1 1>&2 2>&3)
	return $OPTION
}

# menu brightness
function menu_brightness(){
	OPTION=$(whiptail --title "$TITLE" \
	--menu "Select the brightness:" \
	--backtitle "$BACKTITLE" \
	--nocancel \
	14 60 6 \
	"0" "Off." \
	"1" "10%" \
	"2" "20%" \
	"3" "30%" \
	"4" "40%" \
	"5" "50%" \
	"6" "60%" \
	"7" "70%" \
	"8" "80%" \
	"9" "90%" \
	"10" "100%" 3>&1 1>&2 2>&3)
	return $OPTION
}

# menu reboot
function menu_reboot(){
	if (whiptail --title "$TITLE" \
		--yes-button "Reboot" \
		--no-button "Exit" \
		--yesno "Reboot system to apply new settings?" 10 60) then
		reboot
	else
		exit 1
	fi
}

# main menu
function menu_main(){
	OPTION=$(whiptail --title "$TITLE" \
	--menu "Select the appropriate options:" \
	--backtitle "$BACKTITLE" \
	--nocancel \
	14 60 6 \
	"1" "UPS GPIO <$GPIO>" \
	"2" "LED Brightness <$BRIGHTNESS_MENU>" \
	"3" "Apply Settings" \
	"4" "Disable UPS" \
	"5" "Exit"  3>&1 1>&2 2>&3)
	return $OPTION
}

# Superuser privileges
if [ $UID -ne 0 ]; then
	whiptail --title "UGEEK WORKSHOP" \
	--msgbox "Superuser privileges are required to run this script.\ne.g. \"sudo $0\"" 10 60
    exit 1
fi

#brightness_to_percent 230
#echo $?

# main
get_gpio
get_brightness

while [ True ]
do
	check_installed
	if [ $? -eq 1 ]; then
		INSTALLED=1
	else
		INSTALLED=0
	fi
	get_brightness
	brightness_to_percent $BRIGHTNESS
	BRIGHTNESS_MENU=$?"0%"
	menu_main
	case $? in
		1)
		menu_gpio
		case $? in
			1)
			GPIO=18
			;;
			2)
			GPIO=12
			;;
		esac
		if [ -f $FILENAME ]; then
			sed -i 's/^LED_PIN.*/LED_PIN = '$GPIO'/' $FILENAME
		fi
		if [ -f $FILEPATH$FILENAME ]; then
			sed -i 's/^LED_PIN.*/LED_PIN = '$GPIO'/' $FILEPATH$FILENAME
		fi
		;;
		2)
		menu_brightness
		PERCENT=$?
		percnet_to_brightness $PERCENT
		BRIGHTNESS=$?
		if [ -f $FILENAME ]; then
			sed -i 's/^LED_BRIGHTNESS.*/LED_BRIGHTNESS = '$BRIGHTNESS'/' $FILENAME
		fi
		if [ -f $FILEPATH$FILENAME ]; then
			sed -i 's/^LED_BRIGHTNESS.*/LED_BRIGHTNESS = '$BRIGHTNESS'/' $FILEPATH$FILENAME
		fi
		;;
		3)
		if [ $INSTALLED -eq 1 ]; then
			disable_ups
			enable_ups
		else
			enable_ups
		fi
		;;
		4)
		disable_ups
		;;
		5)
		exit
		;;
		*)
		;;
	esac
done