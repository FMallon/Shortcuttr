#!/usr/bin/env bash

if [ -n "$BASH_VERSION" ]; then
  
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  current_environment="bash"

elif [ -n "$ZSH_VERSION" ]; then

  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  current_environment="zsh"

fi 

MAIN_DIR="$SCRIPT_DIR/../Main"
CONFIG_DIR="$SCRIPT_DIR/../Config"
IMAGES_DIR="$SCRIPT_DIR/../Images"

INSTALLATION_DIR="$SCRIPT_DIR/../Installation"
DEPENDENCIES_DIR="$SCRIPT_DIR/../Dependencies"
DOCUMENTATION_DIR="$SCRIPT_DIR/../Documentation"

# exits the script gracefully depending on whether it's in a subshell or not
exit_gracefully(){

  local SCRIPT_PID="$1"

  #-debug
  #echo "Secondary PID - $SCRIPT_PID"
  
  case "$current_environment" in 
    
    bash)
      
      if (( BASH_SUBSHELL > 0 )); then

        exit 1

      else
    
        kill -SIGINT "$SCRIPT_PID"

      fi
    
    ;;
    
   
    zsh)

      if (( ZSH_SUBSHELL > 0 )); then

        exit 1

      else
    
        kill -SIGINT "$SCRIPT_PID"

      fi

    ;;


  esac


}

exit_gracefully "$1"