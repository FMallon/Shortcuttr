#!/bin/sh

searchAlias(){

  local Alias="$1"
  local Cwd="$2"
  local FILE="$3"


  grep "^$Alias;" "$FILE" | cut -d ";" -f2


}

searchAlias "$Alias" "$Cwd" "$FILE"
