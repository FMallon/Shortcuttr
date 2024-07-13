Old script I made, making it public today.  Essentially a Database of aliases linked to directory paths to allow for quick navigation of the terminal. A user can set their desired directory path, e.g. "/home/username/Documents/MyProjects" to a name such as "proj".  In entering "sc proj", they will be directed there.


To achieve this, go to desired directory path: "/home/name/Documents/MyProjects"

  sc -c proj #This will create the alias "proj" and set to the current user directory path

From a different directory:

  sc proj #User will be sent to the linked directory without having to do the whole "cd /home/name/Documents/MyProjects"


This was made in Bash/zShell for server/terminal, and works to not rely on other scripting languages that may be unavailable on certain servers due to space etc.


##################################################################################################################################################################

Tested environments include: 
              WSL: Fedora, Kali, Ubuntu, Debian, Arch, AthenaOS, Alpine, Alma
  Virtual Machine: Ubuntu, Arch
              AWS: Amazon Linux
           Docker: Ubuntu, Alpine
               OS: Arch

Couldn't get it working on MacOS - also didn't have the time to try, don't have a MacOS etc.  Issues were related to path-finding to the folder, from what I remember.  

It is also has built-in functionality to allow users to manually change the Aliases from nano ("sc -fe") so that they can fix a mistake without having to flush everything.  User can delete DB to start fresh with "sc -ff", as well as other functionalities.  User can enter "sc -h/sc --help", or the Man-page for more details.

To use: download, then run the install.sh file in the Installation directory.  This should set up everything, except for the the Man-page, which sometimes doesn't work correctly.  So you may have to put that manually into wherever your Man-page directory is.  Man-page is Documentation/sc.1.

Note: place the download and run installer from the folder you wish to store the Program!

######################################################################################################################################################################

############ Install Instructions ##############

# Download to where you want to keep the install
  - git clone https://github.com/FMallon/Shortcuttr

# Navigate to the Installation folder

  - . ./install.sh

# Done! If the Manual page hasn't found it's correct place and doesn't work, just manually move the /Shortcuttr/Documentation/sc.1 file into your Man-page folder.
