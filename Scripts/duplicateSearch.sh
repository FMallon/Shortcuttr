#!/bin/sh
#
# This is for directoryShortcut.sh, but can be configured to suit other needs
#
# Make local
#Alias="$1"
#Cwd="$2"
#FILE="$3"

searchDuplicate(){

  local Alias="$1"
  local Cwd="$2"
  local FILE="$3"
  
  if grep -q "^$Alias;" "$FILE" || grep -q ";$Cwd$" $FILE; then
    return 1 
  else
    return 2
  fi

}

searchDuplicate "$Alias" "$Cwd" "$FILE" 
