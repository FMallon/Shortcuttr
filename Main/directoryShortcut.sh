#!/usr/bin/env bash

SCRIPT_PID="$$"

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

  if [ "$check" -eq 1 ]; then
    
    printDelayedText "Alias '$Alias' or '$Cwd' already exists in the database!"

  else
    printDelayedText "Adding Alias......"
    \printf "\n%s;%s\n" "$Alias" "$Cwd" >> "$FILE"
    printDelayedText "Alias set!"
  
  fi  

  
  backupFile

}


changeDir(){
 
  local Alias="$1"

  local Cwd=$(. "$SCRIPT_DIR/searchAlias.sh" $Alias)
  
  if [ ! -z "$Cwd" ]; then
    printDelayedText "Changing directory...."
    \cd "$Cwd"
  else
    printDelayedText "This Alias does not exist! You can view your Database with | -fs |"
  fi 
}


checkFile_Secondary(){
  #check for file, and create if doesnt exit
  
  
  if [ -e "$FILE" ]; then
    
    return 1
  
  else

    \printf "\n" 
    printDelayedText "Database doesn't exist! Creating now...."
    \touch "$FILE" || { \printf "Error: Failed to create Database file!\n"; }

  fi

}


checkFile(){

  if [ -e "$FILE" ]; then

    printDelayedText "Database file exists!"

  else
    printDelayedText "Database doesn't exist! Creating now...."
    \touch "$FILE" || { \printf "Error: Failed to create Database file!\n"; }
    
  fi
}


editFile(){

  nano "$FILE" || vi "$FILE" || vim "$FILE" || nvim "$FILE" || emacs "$FILE" || { \printf "Error: No text editor found! Please install Nano, Vi or Vim to edit the Database file!\n"; . "$SCRIPT_DIR/exitScript.sh" "$$"; }

  backupFile

}


#readFile(){

 # Read $FILE

#}


flushFile(){

  backupFile

  printDelayedText "Flushing file now......"

  \sleep 1

  \printf "\n" > "$FILE"

  printDelayedText "File has been flushed!"

  \printf "\nA backup was created just in case!\n\n"

}


#-debug purposes
deleteFile(){

  backupFile

  printDelayedText "The File is being deleted......"

  \rm "$FILE" || { \printf "Error: Failed to delete Database file!\n"; }

  printDelayedText "File is deleted!"

  \printf "\nA backup was created just in case!\n\n"

}


showFile(){

 #Remember: Don't set $LINES for this because in case this environment variable may not exist on Unix;

  local lineCount=$(wc -l < "$FILE")
  local temp_file=$(mktemp)

  #the limit that will decide whether to use Cat or Less based on the size of the DB;
  local limit=25


  \printf '\n\n\tALIAS      |      DIRECTORY\n\t_______________________________\n\n' > "$temp_file"


  #Dont call the fkn variable 'path' in the 'while read -r' loop because it fucks up zshell $PATH environment variable completely 
  #and fkn breaks everything and makes me so fkn mad and wasting so much time wondering wtf is going on.... Good to know for the future though!
  #Maybe making local would fix, but wtf did I not just call it directory in the first place?!
  #Remember this in case any future issues arise!

  local alias 
  local directory

  while IFS=';' read -r alias directory; do

    [ -z "$alias" ] && continue

    \printf '\t%-10s |      %s\n' "$alias" "$directory" >> "$temp_file"

  done < "$FILE"


  if [ "$lineCount" -gt "$limit" ]; then

    \less "$temp_file"

  else

    \cat "$temp_file"

  fi


  \rm -f "$temp_file"

  \printf "\n\n"

  
}


listAliases(){

  #List all shortcuts and allow user to enter directory by selecting number from list

  local alias_index=1

  declare -A aliases

#Read in file and store aliases in array!
  printf "\n"
  while IFS=';' read -r alias directory; do

    [ -z "$alias" ] && continue

    aliases[$alias_index]="$alias;$directory"
    \printf "%d) %s -> %s\n" "$alias_index" "$alias" "$directory"
    ((alias_index++))

  done < "$FILE"


  local dirListLength="${#aliases[@]}"


  if [[ "$dirListLength" -eq 0 ]]; then

    printDelayedText "No aliases found in the database!"

    . "$SCRIPT_DIR/exitScript.sh" "$$"

  fi


  \printf "\nEnter the number of the alias you want to navigate to: "  
  read choice
  \printf "\n"


  if [[ "$choice" -ge 1 && "$choice" -lt "$alias_index" ]]; then

    local selected_entry="${aliases[$choice]}"
    local selected_alias="${selected_entry%%;*}"
    changeDir "$selected_alias"

  else

    printDelayedText "Invalid selection!"
  
  fi

}


helpUser(){

  \printf "\n
  -c | Creates a ShortCut - e.g. sc -c <Alias>\n\n
  -l | Lists all saved Shortcuts allowing the User to change directory based-off the corresponding number entered in the terminal\n\n
  -fc | Checks the existence of the Database File\n\n
  -fe | Edits the Database File using Nano, Vi, Vim, Nvim, or Emacs\n\n
  -ff | Flushes the Database File - emptying its contents, but leaving the File there\n\n
  -fd | Deletes the Database File\n\n
  -fs | Shows the Database File's entries - via Cat or Less depending on the User's Database size\n\n
  -fr | Restores the Database File's contents from an automatic backup - added safety net in the event of User error or unintended behaviour\n\n\n
  These two functions exist for Re-installation and Uninstallation:\n
  \t--reinstall | Reinstalls the script again by calling the install script\n\n
  \t--uninstall | Uninstalls the program, removing the Alias' set in the .rc files, and removing the Man Page, as well as Deleting the Program Folder\n
  "

}


backupFile(){

# run this before flushFile & deleteFile just as a safety net!
  local fileBackup="${FILE}.bk"

  \cp "$FILE" "$fileBackup" || { \printf "Error: Failed to create backup of Database file!\n"; }

}


restoreFile(){

  \printf "\nDo you want to restore backup? Doing so will overwrite your current Database (y/n):"

  read ans
  
  case "$ans" in
    
    "y" | "Y" | "yes" | "Yes" | "yah" | "Yah" | "yeh" | "Yeh" | "yas" | "Yas")     
      
      \cat "$CONFIG_DIR"/shortcuts.txt.bk > "$CONFIG_DIR"/shortcuts.txt
      printDelayedText "Your backup has been restored!"

    ;;

    "n" | "N" | "no" | "No" | "nah" | "Nah" | "nope" | "Nope")

      printDelayedText "Exiting now...."

    ;;

  esac

}


main_sc(){

  
  checkFile_Secondary

  #if $2 isnt empty, else run the change dir
  case "$1" in
    
    -c | create-shortcut)

      if [ $# -gt 2 ]; then

        printDelayedText "Error! Alias cannot contain a space!"

      elif [ -z "$Alias" ]; then

        printDelayedText "Sorry, but no! I'm not letting you set an empty Alias.  My program, my rules!"

      elif \grep -q "?" <<< "$Alias"; then

        #Fix to a possible error that could arise due to '?' behaving a certain way in zShell!
        printDelayedText "Error! Alias cannot contain a '?'!"
      
      else 

        createShortCut
      
      fi

    ;;

    
    -l | --list) 
    
      if [ $# -gt 1 ]; then

      printDelayedText "Error! Too many arguments provided!"
    
      else
        
        listAliases
      
      fi

    ;;

    
    -fc | --file-check) 
    
      if [ $# -gt 1 ]; then

      printDelayedText "Error! Too many arguments provided!"
    
      else

        checkFile
      
      fi

    ;;


    -fe | --file-edit) 

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
        else

          editFile
        
        fi

    ;;


    -ff | --file-flush)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        flushFile
        
      fi

    ;;


    -fd | --file-delete)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        deleteFile
        
      fi

    ;;


    -fs | --file-show)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        showFile
        
      fi

    ;;


    -fr | --file-restore)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        restoreFile
        
      fi

    ;;


    --reinstall)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        . "$INSTALLATION_DIR/install.sh"
        
      fi

    ;;


    --uninstall)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        . "$INSTALLATION_DIR/uninstall.sh" 

      fi

    ;;


    --help | -h)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        helpUser
      
      fi

    ;;


    -*) 

      printDelayedText "Invalid option"
      helpUser
    
    ;;


    #when an $Alias, changeDir
    "$1")
      
      if [ "$#" -gt 1 ]; then

        printDelayedText "Error! Alias cannot contain a space!"

      elif [ -z "$1" ]; then

        printDelayedText "Error! No Alias provided!"

      else

        changeDir "$1"

      fi

    ;;

  esac

}


main_sc "$@"
