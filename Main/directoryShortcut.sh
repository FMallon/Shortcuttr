#!/usr/bin/env bash

#SCRIPT_PID="$$"

#-debug 
#echo "Main PID - $SCRIPT_PID"

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
FILE_BACKUP="$CONFIG_DIR/shortcuts.txt.bk"

# ${1:-} is a new thing i'm trying out because bash -u complains about unset variables, and I am unsure if this would fuck up older versions of Bash.  Shouldn't cause any issues! 
Flag="${1:-}"
Alias="${2:-}"
Cwd=$(pwd)


createShortCut(){

  
  #-debug
  #echo "Exit $?" #right now, everything is Exit 0
  
  checkFile_Secondary

  . "$SCRIPT_DIR/duplicateSearch.sh"

  #-debug <--- also a bug.  If this is set, $? will be 0, so dont bother, and remember for future;
  #echo "Exit $?"
  #So this will set $? as a var, and keep it stored 
  local check="$?"

  if [ "$check" -eq 0 ]; then
    
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
    \cd "$Cwd" 2>/dev/null || { printDelayedText "This Directory doesn't exist!"; }
  else
    printDelayedText "This Alias does not exist! You can view your Database with | -fs |"
  fi 


}



checkFile_Secondary(){
  #--Fix this shit!!!!! check for file, and create if doesnt exit
  
  
  if [ ! -e "$FILE" ]; then
    
    \printf "\n" 
    printDelayedText "Database doesn't exist! Creating now...."
    \touch "$FILE" 2>/dev/null || { \printf "\nError: Failed to create Database file!\n"; }

  fi
  

}



checkFile(){


  if [ -e "$FILE" ]; then

    printDelayedText "Database file exists!"

  else
    printDelayedText "Database doesn't exist! Creating now...."
    \touch "$FILE" 2>/dev/null || { \printf "\nError: Failed to create Database file!\n"; }
    
  fi


}



editFile(){


  checkFile_Secondary

  \nano "$FILE" 2>/dev/null || \vi "$FILE" 2>/dev/null || \vim "$FILE" 2>/dev/null || \nvim "$FILE" 2>/dev/null || \emacs "$FILE" 2>/dev/null || { \printf "\nError: No text editor found! Please install Nano, Vi, Neovim, Emacs or Vim to edit the Database file!\n"; return 1; }

  backupFile


}


#readFile(){

 # Read $FILE

#}



flushFile(){


  checkFile_Secondary

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

  \rm "$FILE" 2>/dev/null || { \printf "\nError: Failed to delete Database file!\n"; }

  printDelayedText "File is deleted!"

  \printf "\nA backup was created just in case!\n\n"


}



showFile(){


  checkFile_Secondary

 #Remember: Don't set $LINES for this because in case this environment variable may not exist on Unix;

  local lineCount=$(wc -l < "$FILE")
  local temp_file=$(mktemp)
  trap '\rm -f "$temp_file" 2>/dev/null' EXIT SIGINT SIGTERM


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


  if [ "$lineCount" -eq 0 ]; then

    printDelayedText "The Database is currently empty!"

  elif [ "$lineCount" -gt "$limit" ]; then

    \less "$temp_file 2>/dev/null" || \head "$temp_file 2>/dev/null" || { printf "\nError: Less or Head may not be installed on this system!\n"; }

  else

    \cat "$temp_file" 2>/dev/null || {  printf "\nError: Cat may not be installed on this system!\n"; }

  fi


  \rm -f "$temp_file" 2>/dev/null

  \printf "\n"

  
}



listAliases(){


  checkFile_Secondary

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

    #. "$SCRIPT_DIR/exitScript.sh" "$SCRIPT_PID"
    return 1


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

  \printf "
  Shortcuttr - a lightweight terminal navigation tool for Bash & zShell compatible with Linux, Unix, & MacOS

  \tUsage: sc <Alias> || sc <Flag> || sc <Flag> <Alias>

  \t\t-> sc -l | Lists all saved Shortcuts allowing the User to change directory based-off the corresponding number entered in the terminal via User prompt
  \t\t-> sc -fc | Checks the existence of the Database File
  \t\t-> sc -fe | Edits the Database File using Nano, Vi, Vim, Nvim, or Emacs
  \t\t-> sc -ff | Flushes the Database File - emptying its contents, but leaving the File there
  \t\t-> sc -fd | Deletes the Database File
  \t\t-> sc -fs | Shows the Database File's entries - via Cat or Less depending on the User's Database size
  \t\t-> sc -fr | Restores the Database File's contents from an automatic backup - added safety net in the event of User error or unintended behaviour
  
  \t\t-> sc <Alias> | Will change directory to the corresponding alias in the Database File
  \t\t-> sc -c <Alias> | Creates a Shortcut to the current directory with the given Alias
  \t\t-> sc -d <Alias> | Deletes a Shortcut from the Database with the given Alias
  
  \t\tThese two functions exist for Re-installation and Uninstallation:
  \t\t\t-> sc --reinstall | Reinstalls the script again by calling the install script
  \t\t\t-> sc --uninstall | Uninstalls the program, removing the Alias' set in the .rc files, and removing the Man Page, as well as Deleting the Program Folder

  \tThere are more verbose Flag names that can viewed in the manual page via 'man sc'\n\n
  "

}



backupFile(){


  checkFile_Secondary

# run this before flushFile & deleteFile just as a safety net!
  local fileBackup="${FILE}.bk"

  \cp "$FILE" "$fileBackup" 2>/dev/null || { \printf "\nError: Failed to create backup of Database file!\n\n"; }


}



restoreFile(){


  checkFile_Secondary

  if [ ! -s "$FILE_BACKUP" ]; then

    \printf "\nThe Backup Database is empty!\n\n"
    return 1

  fi

  \printf "\nDo you want to restore backup? Doing so will overwrite your current Database (y/n):"

  read ans
  
  case "$ans" in
    
    "y" | "Y" | "yes" | "Yes" | "yah" | "Yah" | "yeh" | "Yeh" | "yas" | "Yas")     
      
      \cp "$FILE_BACKUP" "$FILE" 2>/dev/null || { \printf "\nError: Failed to restore the Database from backup!\n\n"; }
      printDelayedText "Your backup has been restored!"

    ;;

    "n" | "N" | "no" | "No" | "nah" | "Nah" | "nope" | "Nope")

      printDelayedText "Exiting now...."

    ;;

  esac


}



##################################################################################################################

#This may be more difficult to do than I first thought......
#I think it has to be moreso on the User end as opposed to within the Program itself; We'll see... 

##This is an attempt to do auto-complete for an alias or flag;
  ##-try structure it in a way where alias is first, then if current input is '-' or '--', suggest flags;
  ##-also, remember to test bash completion compatibility!
  ##-will have to also fkn do another one for zsh 

#_sc_completion(){


#  local cur prev

  ##local alias_list=()

#  local alias_list=($(cut -d ';' -f 1 "$FILE"))

#  local flag_list="-c --create-shortcut -l --list -fc --file-check -fe --file-edit -ff --file-flush -fd --file-delete -fs --file-show -fr --file-restore --reinstall --uninstall --help -h"
 
#  COMPREPLY=()

#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"

  ## Populate alias_list from the shortcuts file 
    ##-take the same logic as the while loop in showFile();
    ##-or maybe use cut command, because I think completion stores it in a string like way seperated by spaces, e.g. "aslias1 aslias2 alias3" etc.  Also it may be better for performance too!

  ##if [ -f "$FILE" ]; then
    
   ## while IFS=';' read -r alias directory; do
      
    ##  [ -z "$alias" ] && continue
      
     ## alias_list+=("$alias")
    
    ##done < "$FILE"
  
  ##fi  

  ## So if current input starts with '--' then continue with those flags, else if starts with '-' then continue with those flags, else continue with aliases first!
  #if [[ $cur == --* ]]; then

  #    COMPREPLY=( $(compgen -W "$flag_list" -- "$cur") )

  #elif [[ $cur == -* ]]; then

  #    COMPREPLY=( $(compgen -W "$flag_list" -- "$cur") )

  #else

  #    COMPREPLY=( $(compgen -W "$alias_list" -- "$cur") )

  #fi


  #maybe add if greater than 1 word, return; this script takes no more than 1 argument at a time
#  if [[ $COMP_CWORD -gt 1 ]]; then

#    return

#  fi

#}
##############################################################################################################



deleteShortCut(){


  if \grep -q "^$Alias;" "$FILE" 2>/dev/null; then
  
    \sed -i "\|^$Alias;|d" "$FILE" 2>/dev/null && printDelayedText "Deleting Alias......"
    \printf "\n"

  else
  
    printDelayedText "Alias '$Alias' does not exist in the database!"
  
  fi  

  
  backupFile


}




#cleanupFile(){
  #Clean up the Database from bad Paths - this will run only at the User's behest because I don't want to be messing with other people's DBs.... so do not call it on functions!
  #Under Construction


 
 # backupFile

  #Remove empty lines in the DB!  
#  local temp_file="$(mktemp)"

 # local alias 
  #local directory

  #local i=1

  #trap '\rm -f "$temp_file"' EXIT SIGINT SIGTERM

  #while IFS=';' read -r alias directory; do

    
   # if [ -d "$directory" ]; then
 
    #  \printf "\n%s;%s\n" "$alias" "$directory" >> temp_file
    
    #else

     # \printf "\n%d) Directory %s does not resolve, and will thus be deleted", "$i" "$directory"  
     # i=$(( i + 1 ))

    #fi


  #done < "$FILE"



  #\mv "$temp_file" "$FILE" || \printf "\nAn error occured during the Cleanup Process!\n"
  #\rm -f "$temp_file"

  #\printf "\n\n"


#}



main_sc(){


  #if $2 isnt empty, else run the change dir
  case "$Flag" in
    
    -c | --create-shortcut)

      
      if [ $# -gt 2 ]; then

        printDelayedText "Error! Alias cannot contain a space!"

      
      elif [ -z "$Alias" ]; then

        printDelayedText "Sorry, but no! I'm not letting you set an empty Alias.  My program, my rules!" 

      
      elif \grep -q "?" 2>/dev/null <<< "$Alias"; then

        #Fix to a possible error that could arise due to '?' behaving a certain way in zShell!
        printDelayedText "Error! Alias cannot contain a '?'!"

      
      elif \grep -q "~" 2>/dev/null <<< "$Alias"; then

        #"~" resolves to $HOME; it looks like shit in the db; this will resolve from the sc <$alias> command to "cd ~" 
        printDelayedText "The Alias '~' already exists by default as an invisible Database entry resolving to $HOME!"
      
      
      elif [ "$Alias" = "$HOME" ]; then

        printDelayedText "The Alias '~' already exists by default as an invisible Database entry resolving to $HOME!"

      
      elif [ "$Alias" = "." ]; then

        printDelayedText "The Alias '.' already exists by default showing available directories!"

      
      elif [ "$Alias" = ".." ]; then

        printDelayedText "The Alias '..' already exists by default as an invisible Database entry resolving to the Parent Directory"

      
      elif [ -d "$Alias" ]; then

        printDelayedText "Warning: this is a Directory name that could cause conflicts!"
        createShortCut || return 1

      
      else 

        createShortCut || return 1
      
      fi

    ;;


    -d | --delete-shortcut)

      if [ $# -gt 2 ]; then

        printDelayedText "Error! Alias cannot contain a space!"

      elif [ -z "$Alias" ]; then

        printDelayedText "Error! No Alias provided to delete!"

      else

        deleteShortCut || return 1
      
      fi

    ;;
    

    -l | --list) 
    
      if [ $# -gt 1 ]; then

      printDelayedText "Error! Too many arguments provided!"
    
      else
        
        listAliases || return 1
      
      fi

    ;;

    
    -fc | --file-check) 
    
      if [ $# -gt 1 ]; then

      printDelayedText "Error! Too many arguments provided!"
    
      else

        checkFile || return 1
      
      fi

    ;;


    -fe | --file-edit) 

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
        else

          editFile || return 1
        
        fi

    ;;


    -ff | --file-flush)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        flushFile || return 1
        
      fi

    ;;


    -fd | --file-delete)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        deleteFile || return 1
        
      fi

    ;;


    -fs | --file-show)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        showFile || return 1
        
      fi

    ;;


    -fr | --file-restore)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        restoreFile || return 1
        
      fi

    ;;


    --reinstall)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        . "$INSTALLATION_DIR/install.sh" || return 1
        
      fi

    ;;


    --uninstall)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        . "$INSTALLATION_DIR/uninstall.sh" || return 1

      fi

    ;;


    --help | -h)

      if [ $# -gt 1 ]; then

        printDelayedText "Error! Too many arguments provided!"
      
      else

        helpUser || return 1
      
      fi

    ;;


 #   --clean-file)
      #Still in development!
  #      if [ $# -gt 1 ]; then

   #     printDelayedText "Error! Too many arguments provided!"
      
    #  else

     #   cleanupFile
      
     # fi

    #;;


    -*) 

      printDelayedText "Invalid option"
      helpUser || return 1
    
    ;;


    #when an $Alias, changeDir
    "${1:-}")
      
      if [ "$#" -gt 1 ]; then

        printDelayedText "Error! Alias cannot contain a space!"

      elif [ -z "${1:-}" ]; then

        printDelayedText "Error! No Alias provided!"

      elif [ "${1:-}" = "." ]; then

        \tree -d -L 1 2>/dev/null || \find . -maxdepth 1 -type d 2>/dev/null || \ls -d */ .*/ 2>/dev/null || { \printf "\nError listing directories!\n\n"; }

      elif [ -d "${1:-}" ]; then

        printDelayedText "Changing directory..."
        \cd "${1:-}"

      else

        changeDir "${1:-}" || return 1

      fi

    ;;

  esac


}


main_sc "$@" || return 1 2>/dev/null || exit 1
