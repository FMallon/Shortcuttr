#!/bin/sh 

# This should enable flexible use across other Users' distros by creating a set Absolute Path to User's program location;
if [ -n "$BASH_VERSION" ]; then
  INSTALLATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then  
  INSTALLATION_DIR="$(cd "$(dirname "$0")" && pwd)"
fi  


SCRIPT_DIR="$INSTALLATION_DIR/../Scripts"
CONFIG_DIR="$INSTALLATION_DIR/../Config"
IMAGES_DIR="$INSTALLATION_DIR/../Images"
MAIN_DIR="$INSTALLATION_DIR/../Main"

PROGRAM_DIR="$INSTALLATION_DIR/../../Shortcuttr"
DEPENDENCIES_DIR="$INSTALLATION_DIR/../Dependencies"
DOCUMENTATION_DIR="$INSTALLATION_DIR/../Documentation"

MANUAL_DIR="/usr/local/share/man/man1"

# Import printDelayedText function;
"$SCRIPT_DIR/printDelayedText.sh"



#Subshell kill -SIGINT $$ fix - adds true/false to temp file, takes from it if in subshell;
SCRIPT_PID="$$"
###############################################


# remove all of the contents of the folder, and make sure to remove the line from .bashrc

userValidation(){
  
# Remove Shortcuttr 

  \printf "\n"

  if [ -n "$BASH_VERSION" ]; then

    read -p "Are you sure you wish to uninstall the Program & your saved Data? (y/n): " answer
  
  elif [ -n "$ZSH_VERSION" ]; then
    
    \printf "\n\nAre you sure you wish to uninstall the Program & your saved Data (y/n): \c" 
    
    read answer
  
  else

    read -p "Are you sure you wish to uninstall the Program & your saved Data? (y/n):" answer

  fi
  

  
  case "$answer" in
  
    [yY] | [yY][eE][sS])

      \printf "\nProceeding with Uninstall process.........\n"
      \sleep 1

    ;;
    
    *)
      printDelayedText "Aborting Uninstall process........."
      . "$SCRIPT_DIR/exitScript.sh" "$$"
    ;;

  esac  


}


removeFolder(){

      \cd "$PROGRAM_DIR/../"
      \sudo rm -rf "Shortcuttr" && printf "\nShortcuttr Directory removed.... \n" || { printf "Error: Failed to remove Shortcuttr folder!\n"; }
      \sleep 1

}



removeAlias(){
# Remove Alias from .bashrc & .zshrc;


  \printf "\nRemoving Alias from .rc files....\n\n"

  if \grep -q "alias sc=" "$HOME/.bashrc"; then
    
    \sed -i "/^alias sc=/d" "$HOME/.bashrc" 2>/dev/null && \printf "Alias' successfully removed from .bashrc\n"

  else

    \printf "Failed to remove alias from .bashrc! Either an error occurred or the alias didn't exist!\n"

  fi


  if \grep -q "alias sc=" "$HOME/.zshrc"; then

    \sed -i "/^alias sc=/d" "$HOME/.zshrc" 2>/dev/null && \printf "Alias' successfully removed from .zshrc\n"

  else

    \printf "Failed to remove alias from .zshrc! Either an error occurred or the alias didn't exist!\n"

  fi

  \printf "\n"
  
  \sleep 1


}



removeManual(){
# Remove Man Page

  \sudo rm "$MANUAL_DIR/sc.1" && \printf "Man page successfully removed!\n" || { \printf "\nFailed to remove man page! Either an error occurred or the man page was not initially installed!\n"; }


}


uninstallShortcuttr(){
  

  userValidation
  removeAlias
  removeManual
  removeFolder

  \printf "\n\nShortcuttr should now be Uninstalled!\n\n"

  sleep 0.3

  if [ -n "$BASH_VERSION" ]; then

    \exec bash

  elif [ -n "$ZSH_VERSION" ]; then

    \exec zsh

  fi
  

} 


uninstallShortcuttr
