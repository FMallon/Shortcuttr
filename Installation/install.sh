#!/bin/sh

# this should ensure ability to install Program on zSh systems
if [ -n "$BASH_VERSION" ]; then  
  INSTALLATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then 
  INSTALLATION_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

SCRIPT_DIR="$INSTALLATION_DIR/../Scripts/"
CONFIG_DIR="$INSTALLATION_DIR/../Config/"
IMAGES_DIR="$INSTALLATION_DIR/../Images/"
MAIN_DIR="$INSTALLATION_DIR/../Main/"

PROGRAM_DIR="$INSTALLATION_DIR/../../Shortcuttr/"
DEPENDENCIES_DIR="$INSTALLATION_DIR/../Dependencies/"
DOCUMENTATION_DIR="$INSTALLATION_DIR/../Documentation/"

MANUAL_DIR="/usr/local/share/man/man1/"

# Import printDelayedText function;
. "$SCRIPT_DIR/printDelayedText.sh"

# Copy Man Page
sudo mkdir /usr/local/share/man/man1/ &
sudo cp "$DOCUMENTATION_DIR/sc.1" "$MANUAL_DIR"

# Change file permission
sudo chmod u+x $MAIN_DIR/directoryShortcut.sh &&
sudo chmod u+x $INSTALLATION_DIR/uninstall.sh &&

echo "alias sc='. $MAIN_DIR/directoryShortcut.sh'" | sudo tee -a ~/.bashrc &
echo "alias sc='. $MAIN_DIR/directoryShortcut.sh'" | sudo tee -a ~/.zshrc &

sleep 1

echo -e "\n\n"

echo "Shortcuttr installed successfully!" &&
echo "Use 'sc --help' to view Usage; 'man sc' will bring up full Manual page too!" &&

cd ~ &&

echo -e "\n"

if [ -n "$BASH_VERSION" ]; then
  . ~/.bashrc
elif [ -n "$ZSH_VERSION" ]; then
  . ~/.zshrc
fi
