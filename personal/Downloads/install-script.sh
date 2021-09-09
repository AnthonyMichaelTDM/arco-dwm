#!/bin/sh

#goto home directory
cd /home/${USER}/

##variables, storing file paths
CONFIG_DIRECTORY="/home/${USER}/Downloads/" #for end user: change this to be the directory you stored my configs in
readonly CONFIG_DIRECTORY

CURSOR_SOURCE="/home/${USER}/.icons/BloodMoon-Cursor/"
CURSOR_TARGET="/usr/share/.icons/"
readonly CURSOR_SOURCE
readonly CURSOR_TARGET

GTK_SOURCE="/home/${USER}/themes/Bloodmoon/"
GTK_TARGET="/usr/share/themes/"
readonly GTK_SOURCE
readonly GTK_TARGET

VIMRC_SOURCE="${CONFIG_DIRECTORY}vimrc"
VIMRC_TARGET="/etc/"
readonly VIMRC_SOURCE
readonly VIMRC_TARGET

SDDM_SOURCE="${CONFIG_DIRECTORY}BloodMoon-sugar-candy/"
SDDM_TARGET="/usr/share/SDDM/themes/"
SDDM_CONF="/etc/sddm.conf"
readonly SDDM_SOURCE
readonly SDDM_TARGET
readonly SDDM_CONF

BACKGROUND_IMAGE_SOURCE="${SDDM_SOURCE}Backgrounds/bloodmoon.jpg"
BACKGROUND_IMAGE_TARGET="/usr/share/backgrounds/arcolinux/"
readonly BACKGROUND_IMAGE_SOURCE
readonly BACKGROUND_IMAGE_TARGET

GTK3_SETTINGS="/home/${USER}/.config/gtk-3.0/settings.ini"
readonly GTK3_SETTINGS

DWM_MAKE_DIR="/home/${USER}/.config/arco-dwm/"
ST_MAKE_DIR="/home/${USER}/.config/arco-st/"
SLSTATUS_MAKE_DIR="/home/${USER}/.config/arco-slstatus/"
readonly DWM_MAKE_DIR
readonly ST_MAKE_DIR
readonly SLSTATUS_MAKE_DIR

SCRIPT_SOURCE="${CONFIG_DIRECTORY}configure-brightness"
SCRIPT_TARGET="/home/${USER}/.bin/my-scripts/configure-brightness.sh"    
readonly SCRIPT_SOURCE
readonly SCRIPT_TARGET


## ask if they want the cursor and gtk themes copied over to the root directory
echo "################################################################## "
echo "Phase 1 : optional stuff"
echo "- copy gtk and cursor themes to root user"
echo "     - remove gtk and cursor themes from home directory"
echo "- brightness scipt"
echo "     - copy brightness scipt to bin"
echo "     - create sudoers exeption for script"
echo "     - add alias for brightness script to .zshrc-personal"
echo "     - modify sxhkdrc to use brightness script rather than xbackligh"
echo "################################################################## "

read -p "do you want the cursor and gtk themes installed to the root user? y/n" -n 1 -r rootYN
echo
case $rootYN in
	y|Y ) #install
        echo "copying cursor and gtk themes to /usr/share directory"
        #copy cursor and gtk themes to the root user
		sudo cp -rf $CURSOR_SOURCE $CURSOR_TARGET
        sudo cp -rf $GTK_SOURCE $GTK_TARGET
        echo "done"
        #remove them from user
        echo "cleaning up"
        rm -rf $CURSOR_SOURCE
        rm -rf $GTK_SOURCE
        echo "done"
		echo ;;
	* ) #do not install
		echo ;;
esac

read -p "do your brightness keys work as intended? y/n" -n 1 -r brightnessYN
echo
case $brightnessYN in
	n|N ) #modify sxhkdrc and .zshrc-personal, also copy the brightness changing script, and make it so that said script can run without needing a sudo password
        
        #copy brighness changing script
        cd /home/${USER}/.bin/
        mkdir my-scripts
        cd /home/${USER}/
        cp -f "${SCRIPT_SOURCE}.sh" $SCRIPT_TARGET
        cp -f "${SCRIPT_SOURCE}-README.md" $SCRIPT_TARGET

        #create sudoers exeption for brightness changing script
        echo "${USER} ALL=(ALL) NOPASSWD:${SCRIPT_TARGET}" >> /etc/sudoers.d/brightness

        #modify .zshrc-personal
        sed -i 's/#alias brightness="sudo -n \/home\/ruby\/.bin\/my-scripts\/configure-brightness.sh"/alias brightness="sudo -n ${SCRIPT_TARGET}"/' ~/.zshrc-personal

        #modify sxhkdrc
        sed -i 's/xbacklight/#xbacklight\n    sudo -n ${SCRIPT_TARGET}/g' ~/.config/arco-dwm/sxhkd/sxhkdrc

        echo "done"
        echo ;;
	* ) #do not install
        #remove references to a brightness script from .zshrc-personal
        sed -i 's/#personal aliases/ /' ~/.zshrc-personal
        sed -i 's/#alias brightness="sudo -n \/home\/ruby\/.bin\/my-scripts\/configure-brightness.sh"/ /' ~/.zshrc-personal
		echo ;;
esac

##copy over the other things
echo "################################################################## "
echo "Phase 2 : non-optional stuff"
echo "- copy vimrc"
echo "- copy sddm theme"
echo "- set sddm theme to copied theme"
echo "- copy background from sddm theme, and put it somewhere nice"
echo "- set GTK and Cursor themes to my custom themes"
echo "################################################################## "
#vimrc
echo "copying vimrc"
sudo cp -f $VIMRC_SOURCE $VIMRC_TARGET
echo "done"

#sddm
echo "copying sddm theme"
sudo cp -rf $SDDM_SOURCE $SDDM_TARGET
echo "done"
echo "setting SDDM theme to copied theme"
#replace the lines that set current sddm config, and the cursor theme, with my sddm and cursor themes  
sudo sed -i 's/Current=/ # Current=/' $SDDM_CONF
sudo sed -i 's/CursorTheme=/CursorTheme=BloodMoon-Cursor\nCurrent=BloodMoon-sugar-candy # /' $SDDM_CONF
echo "done"

echo "- copying background image"
sudo cp -f $BACKGROUND_IMAGE_SOURCE $BACKGROUND_IMAGE_TARGET
echo "done"

echo "setting GTK and Cursor themes to my custom themes"
sed -i 's/gtk-theme-name=/gtk-theme-name=BloodMoon\n # /' $GTK3_SETTINGS
sed -i 's/gtk-cursor-theme-name=/gtk-cursor-theme-name=BloodMoon-Cursor\n # /' $GTK3_SETTINGS
echo "done"

## run make on the suckless utilities
echo "################################################################## "
echo "Phase 3 : make the custom suckless stuff"
echo "- make DWM"
echo "- make ST"
echo "- make SLSTATUS"
echo "################################################################## "

sudo make clean install -C $DWM_MAKE_DIR
sudo make clean install -C $ST_MAKE_DIR
sudo make clean install -C $SLSTATUS_MAKE_DIR
echo "done"

##clean up Downloads folder
echo "################################################################## "
echo "Phase 4 : clean up downloads folder"
echo "- clear contents of downloads folder, including this script"
echo "################################################################## "

rm -rf $SDDM_SOURCE
rm -f $VIMRC_SOURCE
rm -f "${CONFIG_DIRECTORY}install-script.sh"
rm -f "${SCRIPT_SOURCE}.sh"
rm -f "${SCRIPT_SOURCE}-README.md"
echo "done"

#exit script with success message
echo "restart your computer now"
exit 0