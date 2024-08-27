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

CONFIG_FILE="$CONFIG_DIR/config.ini"

sourceConfig(){

  if [[ -f "$CONFIG_FILE" ]]; then
    . "$CONFIG_FILE"
  fi

}


checkConfigFile(){

  if [[ -f "$CONFIG_FILE" ]]; then

     # set the variables from the Config.ini by seperating key-value, this is done by setting a 'IFS read key value', and should work with zShell and Bash 
     # skip comments and headers 

    while IFS='=' read -r key value; do
     
      if [[ "$key" =~ ^[[:space:]]*# ]] || [[ "$key" =~ ^[[:space:]]*\[ ]]; then
  
        continue
      # get rid of whitespace 
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        eval "$key=\"$value\""
      fi

    done < $CONFIG_FILE

    echo "$key & $value"
     
  fi

}

setVariables(){

  sourceConfig

  checkConfigFile

  echo "$delay"

  if ! [[ "$delay" =~ ^[0-9+([.][0-9]+)?$ ]]; then

    echo "Invalid - delay set to: $delay"

    delay=0.05
  fi

}

main(){

  setVariables

}

main
