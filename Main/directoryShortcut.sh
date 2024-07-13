#!/bin/bash

# This should enable flexible use across other Users' distros by creating a set Absolute Path to User's program location;
if [ -n "$BASH_VERSION" ]; then
  MAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
  MAIN_DIR="$(cd "$(dirname "$0")" && pwd)"
fi 

SCRIPT_DIR="$MAIN_DIR/../Scripts"
CONFIG_DIR="$MAIN_DIR/../Config"
IMAGES_DIR="$MAIN_DIR/../Images"

INSTALLATION_DIR="$MAIN_DIR/../Installation"
DEPENDENCIES_DIR="$MAIN_DIR/../Dependencies"
DOCUMENTATION_DIR="$MAIN_DIR/../Documentation"

# Import printDelayedText function;
. "$SCRIPT_DIR/printDelayedText.sh"


FILE="$CONFIG_DIR/shortcuts.txt"

Flag="$1"
Alias="$2"
Cwd=$(pwd)

createShortCut(){

  #-debug
  #echo "Exit $?" #right now, everything is Exit 0
  

  . "$SCRIPT_DIR/duplicateSearch.sh"

  #-debug <--- also a bug.  If this is set, $? will be 0, so dont bother, and remember for future;
  #echo "Exit $?"
  #So this will set $? as a var, and keep it stored 
  check="$?"

  if [ $check -eq 1 ]; then
    printDelayedText "Alias '$Alias' or '$Cwd' already exists in the database!"
  else
    printDelayedText "Adding Alias......"
    echo -e "$Alias;$Cwd" >> $FILE
    printDelayedText "Alias set!"
  fi  

}

changeDir(){
 
  local Alias="$1"

  local Cwd=$(. "$SCRIPT_DIR/searchAlias.sh" $Alias)
  
  if [ ! -z $Cwd ]; then
    printDelayedText "Changing directory...."
    cd $Cwd
  else
    printDelayedText "This Alias does not exist! You can view your Database with | -fs |"
  fi 
}

checkFile_Secondary(){
  #check for file, and create if doesnt exit
  
  
  if [ -e $FILE ]; then
    
    return 1
  
  else
    echo 
    printDelayedText "Database doesn't exist! Creating now...."
    touch "$FILE"
  fi

}

checkFile(){

  if [ -e $FILE ]; then

    printDelayedText "Database file exists!"

  else
    printText "Database doesn't exist! Creating now...."
    touch "$FILE"
    
  fi
}

editFile(){

  nano $FILE

}

readFile(){

  Read $FILE

}

flushFile(){

  backupFile

  printDelayedText "Flushing file now......"

  sleep 1

  echo -n "" > $FILE

  printDelayedText "File has been flushed!" &&  

  echo "A backup was created just in case!"  
}

#-debugpurposes
deleteFile(){

  backupFile

  printDelayedText "The File is being deleted......"

  rm $FILE && echo ""

  printDelayedText "File is deleted!" &&

  echo "A backup was created just in case!"

}


showFile(){

  #Formats the database for a cleaner display for the User
  cat $FILE | awk -F ';' 'BEGIN { printf "\n\033[1m\033[4m%-15s%-10s\033[0m\n", "ALIAS", "DIRECTORY PATH" } { printf "\n%-15s %-10s\n", $1, $2 }' $FILE && echo ""

}

helpUser(){

  echo -e "\n -c | createShortCut\n\n-fc | checkFile\n\n-fe | editFile\n\n-ff | flushFile\n\n-fd | deleteFile\n\n-fs | showFile\n\n-fr | restoreFile\n"

}

backupFile(){
# run this before flushFile & deleteFile just as a safety net!
  local fileBackup="${FILE}.bk"
  cp $FILE $fileBackup
#  return 0

}

restoreFile(){


  echo -e "Do you want to restore backup? Doing so will overwrite your current Database (y/n):\n"

  read ans && 
  case "$ans" in
    "y" | "Y" | "yes" | "Yes" | "yah" | "Yah" | "yeh" | "Yeh" | "yas" | "Yas") local check=1
    ;;
    "n" | "N" | "no" | "No" | "nah" | "Nah" | "nope" | "Nope") local check=0 
    ;;
  esac

  if [ "$check" -eq 1 ]; then
    cat "$CONFIG_DIR"/shortcuts.txt.bk > "$CONFIG_DIR"/shortcuts.txt &&
      printDelayedText "Your backup has been restored!"

  else
    printDelayedText "Exiting now...."
  fi

}

main(){

  checkFile_Secondary &&
  sleep 2

  #if $2 isnt empty, else run the change dir
  case "$1" in
    -c) createShortCut
    ;;
    -fc) checkFile
    ;;
    -fe) editFile
    ;;
    -ff) flushFile
    ;;
    -fd) deleteFile
    ;;
    -fs) showFile
    ;;
    -fr) restoreFile
    ;; 
    #--debug purposes --this will be an automatic function
    #-fb) backupFile
    #;; 
    --install) . $INSTALLATION_DIR/install.sh
    ;;  
    --uninstall) . $INSTALLATION_DIR/uninstall.sh
    ;;
    --help | -h) helpUser
    ;;  
    -*) echo "Invalid option" && helpUser
    ;;
    #when an $Alias, changeDir
    $1) changeDir $1
    ;;
  esac
}

main $@
