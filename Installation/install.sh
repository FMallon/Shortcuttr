#!/bin/sh

SCRIPT_PID="$$"

# this should ensure ability to install Program on zSh systems
if [ -n "$BASH_VERSION" ]; then
  INSTALLATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then  
  INSTALLATION_DIR="$(cd "$(dirname "$0")" && pwd)"
else
  \printf "Error: Unsupported shell environment! Exiting installation....\n"
  . "$SCRIPT_DIR/exitScript.sh" "$$"
fi  


SCRIPT_DIR="$INSTALLATION_DIR/../Scripts"
CONFIG_DIR="$INSTALLATION_DIR/../Config"
IMAGES_DIR="$INSTALLATION_DIR/../Images"
MAIN_DIR="$INSTALLATION_DIR/../Main"

PROGRAM_DIR="$INSTALLATION_DIR/../../Shortcuttr"
DEPENDENCIES_DIR="$INSTALLATION_DIR/../Dependencies"
DOCUMENTATION_DIR="$INSTALLATION_DIR/../Documentation"

MANUAL_DIR="/usr/local/share/man/man1/"


set_man_page(){

  # Copy Man Page
  \sudo mkdir -p "$MANUAL_DIR" || { \printf "Error: Failed to create manual directory!\n"; }
  \sudo cp "$DOCUMENTATION_DIR/sc.1" "$MANUAL_DIR" || { \printf "Error: Failed to copy man page\n"; }

}


set_permissions_owner(){

  local user=$(whoami)

  # Change file permission
  \sudo chmod 755 "$MAIN_DIR/directoryShortcut.sh" || { \printf "Error: Failed to chmod directoryShortcut.sh\n"; }
  \sudo chmod 755 "$INSTALLATION_DIR/uninstall.sh" || { \printf "Error: Failed to chmod uninstall.sh\n"; }
  \sudo chmod 755 "$SCRIPT_DIR"/* || { \printf "Error: Failed to chmod scripts\n"; }

  \sudo chown -R "$user:$user" "$PROGRAM_DIR" || { \printf "Error: Failed to change ownership\n"; }

}

set_alias_to_rc(){

  local alias_name="alias sc='. "$MAIN_DIR"/directoryShortcut.sh'"


  if \grep -q "$alias_name" "$HOME/.bashrc" 2>/dev/null; then

    \printf "\n$alias_name is already set in .bashrc\n"
   
  else

    \printf "\nSetting Alias to .bashrc file!\n"

    \printf "$alias_name" | sudo tee -a "$HOME/.bashrc" >/dev/null || { printf "Error: Failed to set alias in .bashrc!\n"; }

  fi


  if \grep -q "$alias_name" "$HOME/.zshrc" 2>/dev/null; then
  
    \printf "\n$alias_name is already set in .zshrc\n"

  else

    \printf "\nSetting Alias to .zshrc\n"
    
    \printf "%s\n" "$alias_name" | sudo tee -a "$HOME/.zshrc" >/dev/null || { printf "Error: Failed to set alias in .zshrc!\n"; }

  fi


  sleep 1


}



finish_install(){


  . "$SCRIPT_DIR/printDelayedText.sh"

  \printf "\n\n"

  printDelayedText "Shortcuttr is Installed!"
  \printf "\nCheck the installer output for any errors that may have occurred during installation.\n"
  \printf "Use 'sc --help' to view Usage; 'man sc' will bring up full Manual page too!\n"

  \cd "$HOME" || { \printf "Error: Failed to change directory to HOME!\n"; }

  \printf "\n"

  \sleep 5

  
  if [ -n "$BASH_VERSION" ]; then
  
    \exec bash

  elif [ -n "$ZSH_VERSION" ]; then
  
    \exec zsh

  fi

}


install_sc_main(){


  set_permissions_owner
  set_man_page
  set_alias_to_rc
  finish_install


}


install_sc_main
