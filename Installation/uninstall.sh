#!/bin/sh 

# This should enable flexible use across other Users' distros by creating a set Absolute Path to User's program location;

if [ -n "$BASH_VERSION" ]; then
  INSTALLATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZHS_VERSION"]; then  
  INSTALLATION_DIR="$(cd "$(dirname "$0")" && pwd)"
fi  

SCRIPT_DIR="$INSTALLATION_DIR/../Scripts"
CONFIG_DIR="$INSTALLATION_DIR/../Config"
IMAGES_DIR="$INSTALLATION_DIR/../Images"
MAIN_DIR="$INSTALLATION_DIR/../Main"

PROGRAM_DIR="$INSTALLATION_DIR/../../Shortcuttr"
DEPENDENCIES_DIR="$INSTALLATION_DIR/../Dependencies"
DOCUMENTATION_DIR="$INSTALLATION_DIR/../Documentation"

MANUAL_DIR="/usr/local/share/man/man1/"

# Import printDelayedText function;
. "$SCRIPT_DIR/printDelayedText.sh"

# remove all of the contents of the folder, and make sure to remove the line from .bashrc

removeFolder(){
  
# Remove Shortcuttr  
  
  read -p "Are you sure you wish to uninstall the Program & your saved Data? (y/n):" answer

  case "$answer" in
  
    [yY] | [yY][eE][sS])

      cd "$PROGRAM_DIR/../"
      sudo rm -rf "Shortcuttr"
      printDelayedText "Folder removed...."
    ;;
    
    *)
      printDelayedText "Aborting Uninstall process........."
     ;;

  esac  

}


removeAlias(){
# Remove ALias from .bashrc

  sed -i "/^alias sc=/d" "$HOME/.bashrc" &
  sed -i "/^alias sc=/d" "$HOME/.zshrc" &

  printDelayedText "Alias removed from .bashrc & .zshrc"

}

removeManual(){
# Remove Man Page
  sudo rm "$MANUAL_DIR/sc.1"

}

uninstallShortcuttr(){
  
  removeFolder && 
  removeAlias &&
  removeManual &&

  printDelayedText "Shortcuttr has been fully Uninstalled" &&
  
  sleep 0.3
  
} 

uninstallShortcuttr
