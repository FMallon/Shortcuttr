# Update 26/01/26

As of 26/01/26, I am releasing a more refined version with:
  - new functionality: "sc -l" which will list aliases and allow a user to enter a corresponding number for quicker navigation in the event of a forgotten alias' name
  - refactoring of code and code improvements - I wrote this script a long time ago, and learned a lot since
  - complete re-do of the install & uninstall script files - functions, error-handling, error-output, and readabilty 
  - improved error handling
  - removed sole dependancy of Nano for the "-fs" function by adding vi, vim, nvim, & emacs to Edit the Database - this was because I prefer Nano for editing text files quickly... but it's changed now  
  - incorporating Bash builtins over any possible conflictions between builtins and /usr/bin/commands as to improve portability
  - removal of Awk completely to reduce dependencies
  - Unix compatibility, as per the two fixes noted above - Unix Awk behaves differently to GNU Awk, and echo -e is not possible on Unix

  Not as well tested as I would like, but I haven't much time at the minute.  It works on FreeBSD, so should work on other Unix systems.
  Tested it recently on:
    - Ubuntu VM 
    - FreeBSD VM
    - CentOS Stream VM
    - Arch on WSL - and it works with Windows paths which is the main thing!  
    - Ubuntu on WSL

    Bash and Zshell both seem to be working well and as intended, so hopefully with such a big update, no unknown bugs will be cropping up on your systems.  I have not tested on hardware yet, but.... it's probably fine.

The script has had an increase in clones each week for the past few months now, and I have had some of these fixes in the works for a while, as well as ideas for functionality.  I use this Program everyday, any issues that I do have, I will quickly fix and upload as soon as possible from here-on-out.  No one says anything, so I assume it's working as intended for people anyways, else they would complain - normally ppl will only comment if there is an issue so, as of now, I take the silence as a compliment.

This script was programmed in a way for more Posix compliance, and cross platform/shell compatibilty - works on MacOS, Unix, and many tested Linux distros.  Ultimately, I would like to have Shell compatibility, but idk.  I hate Shell, and I use a "declare -A".... so maybe not.  Will see in the future.

Ok, enjoy, and if any issues, feel free to tell ppl in the Issues section that it's absolute shite and doesn't work!

###########################################################################################################

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
              -l | Lists all saved Shortcuts allowing the User to change directory based-off the corresponding number entered in the terminal\n\n
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

  
Go to your desired directory where you wish to keep the Program Folder and copy paste this line:
  - git clone https://github.com/FMallon/Shortcuttr && sudo chown "$(whoami):$(whoami)" ./Shortcuttr/Installation/install.sh && sudo chmod 755 ./Shortcuttr/Installation/install.sh && . ./Shortcuttr/Installation/install.sh

Keep an eye on the output to make sure everything installed correctly!

If the 'sc' command doesn't work, check your .bashrc/.zshrc files to make sure the alias has been set at the bottom, if not, set manually
  - alias sc='Set/Your/Directory/Main/directoryShortcut.sh' 

Done! If the Manual page hasn't found its correct place and doesn't work, just manually move the /Shortcuttr/Documentation/sc.1 file into your Man-page folder.  The Man directory is in "/usr/local/share/man/man1/".  You may have to make the directory yourself.
