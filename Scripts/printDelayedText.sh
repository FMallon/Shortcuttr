#!/bin/sh

if [ -n "$BASH_VERSION" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi 

MAIN_DIR="$SCRIPT_DIR/../Main"
CONFIG_DIR="$SCRIPT_DIR/../Config"
IMAGES_DIR="$SCRIPT_DIR/../Images"

INSTALLATION_DIR="$SCRIPT_DIR/../Installation"
DEPENDENCIES_DIR="$SCRIPT_DIR/../Dependencies"
DOCUMENTATION_DIR="$SCRIPT_DIR/../Documentation"


printDelayedText(){

  local delay="0.035"

  # source config.ini through the setConfig.sh script
  #. "$SCRIPT_DIR/setConfig.sh"

  for ((i = 0; i < ${#1}; i++)); do
    printf "%c" "${1:$i:1}"
    sleep "$delay"
  done
  echo


}


