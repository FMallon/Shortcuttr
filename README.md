# General Overview

Old script I made, making it public today.  Essentially a Database of aliases linked to directory paths to allow for quick navigation of the terminal. A user can set their desired directory path, e.g. "/home/username/Documents/MyProjects" to a name such as "proj".  In entering "sc proj", they will be directed there.


To achieve this, go to desired directory path: "/home/name/Documents/MyProjects"

  -  sc -c proj #This will create the alias "proj" and set to the current user directory path

From a different directory:

  -  sc proj #User will be sent to the linked directory without having to do the whole "cd /home/name/Documents/MyProjects"


This was made in Bash/zShell for quick server/terminal navigation, and works to not rely on other scripting languages that may be unavailable on certain servers due to space etc.  I essentially just made it out of necessity in a server that I was messing around in - as going back and forth with 'CD' was annoying me, and adding Aliases to my .bashrc was getting ridiculous.  It was also a good way to begin learning Bash, then it evolved into zShell.  It definitely works between the two for me, but I opened a Discussion thread so any User can warn ppl that it isn't working, or isn't good.  Would also appreciate if anyone can let me know if it works, and in what environment they are using specifically so that I can update this file and let ppl know.      


###########################################################################################################


Tested environments include:
  - WSL: Fedora, Kali, Ubuntu, Debian, Arch, AthenaOS, Alpine, Alma
  - Virtual Machine: 

                    - Linux: Ubuntu, Arch
    
                    -  Unix: Solaris, FreeBSD
    
                    - MacOS: Catalina, Sonora
  - AWS: Amazon Linux
  - Docker: Ubuntu, Alpine
  - OS: Arch, Gentoo, MacOS-Ventura

OK, so it works in all the tested environments, minus the following issues:
    
    1) In MacOS, the installer does not correctly set the alias 'sc' in the .bashrc & .zshrc file.  This must be manually set by the User.  This issue is directly related with MacOS not allowing the 'echo "xxxxx" >> ~/.zshrc' command to be run.  I'm sure I could fix this by using something like 'echo <alias> | sudo tee -a ~/.zshrc'.  But I deleted the VM to make room on my laptop for a third OS, and have no way to test this in the near future.
    
    2) In Solaris, the 'sc -fs' flag doesn't work correctly due to Solaris using an older version of 'awk'.  I'm sure there is probably some way to get an up-to-date version of 'awk' on Solaris, but from my experience, the Solaris package manager doesn't allow for it.

It also has built-in functionality to allow users to manually change the Aliases from nano ("sc -fe") so that they can fix a mistake without having to flush everything.
An automatic backup will be created on flushing the DB, and can be restore via "sc -fr", too.  So there is flexibility in the event of user-error.
User can flush the DB to start fresh with "sc -ff".  User can enter "sc -h/sc --help", or the Man-page ("man sc") for more details. 
Also, I made an uninstaller that will get rid of it, remove the aliases, delete everything, should you not want it anymore. 

To use: download, then run the install.sh file in the Installation directory.  This should set up everything, except for the the Man-page, which sometimes doesn't work correctly.  So you may have to put that manually into wherever your Man-page directory is.  Man-page is Documentation/sc.1.

Note: place the download and run installer from the folder you wish to store the Program!

###########################################################################################################


## Flags

"f" means "File", and the "File" is the Database! The following letter should become apparent, and after use, should hopefully become easy to remember.  This was the best way for me at the time.  

              -c | Creates the Alias to the current Directory of the User
             -fc | Checks database's existence, to verify for the User.  Creates database if non-existent
             -fd | Deletes the whole database file
             -fe | Edits the database, via Nano  
             -ff | Flushes the database, keeping the file, but emptying its contents
             -fr | Restores the database from a backup, in case user accidentally deletes or flushes it.
             -fs | Shows the database in the terminal for the User to quickly view their Aliases
    -h || --help | Help menu to show the User the flags
     --reinstall | Runs the installer again, in case of partial install (alias in .bashrc/zshrc must be set)  
     --uninstall | Uninstalls Shortcuttr in a quicker way for the User


###########################################################################################################




# Installation

  
Download to where you want to keep the Program
  - git clone https://github.com/FMallon/Shortcuttr

Navigate to the Installation folder
  - . ./install.sh

If the 'sc' command doesn't work, check your .bashrc/.zshrc files to make sure the alias has been set at the bottom, if not, set manually
  - alias sc='Set/Your/Directory/Main/directoryShortcut.sh' 

Done! If the Manual page hasn't found it's correct place and doesn't work, just manually move the /Shortcuttr/Documentation/sc.1 file into your Man-page folder.  The Man directory is in "/usr/local/share/man/man1/".  You may have to make the directory yourself.
