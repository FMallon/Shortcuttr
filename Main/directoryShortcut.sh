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
  elif [ ! -n "$Alias" ]; then 
    printDelayedText "Sorry, but no! I'm not letting you set an empty Alias.  My program, my rules!"
  else
    printDelayedText "Adding Alias......"
    echo -e "$Alias;$Cwd" >> $FILE
    printDelayedText "Alias set!"
  fi  

  backupFile

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

  nano $FILE &&

  backupFile

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

#-debug purposes
deleteFile(){

  backupFile

  printDelayedText "The File is being deleted......"

  rm $FILE && echo ""

  printDelayedText "File is deleted!" &&

  echo "A backup was created just in case!"

}


showFile(){

  #-debug purposes
  #--local temp_file="$SCRIPT_DIR/../Config/tempdb.txt"
  #--touch "$temp_file"

  # gets the number of DB entries
  local lineCount=$(wc -l < $FILE)
  local temp_file=$(mktemp)
  # this will be the number that decides when to use less || cat to display the DB 
  local limit=14

  #-debug-purposes
  #echo "LINE COUNT is $lineCount"

  # might need to carry on with the normal function to cleanly display the data, put it into a temp file, then cat || less the temp file 

  # formatted database command
  db_formatted=$(cat $FILE | awk -F ';' 'BEGIN { printf "\n\033[1m\033[4m%-15s%-10s\033[0m\n", "ALIAS", "DIRECTORY PATH" } { printf "\n%-15s %-10s\n", $1, $2 }' $FILE && echo "")


  # if numbers of DB entries are too big, then output with cat/less depending
  if [ $lineCount -le $limit ]; then
    # Formats the database for a cleaner display for the User
    echo "$db_formatted"
     
  elif [ $lineCount -gt $limit ]; then
    # for use with less, this formats specific to the temporary text file that less will take from
    echo -e "\n\nALIAS\t\tDIRECTORY PATH\n______________________________\n" > $temp_file 
    echo "$db_formatted" | awk 'NR > 2' >> $temp_file # skip the first 2 lines cuz it's unreadable shite!
    less $temp_file
  fi

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
    --reinstall) . $INSTALLATION_DIR/install.sh
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
