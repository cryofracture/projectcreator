#!/usr/bin/env bash
#
#
#
# TOOL NAME: projectcreator
# WRITTEN BY: tacree
# DATE: 10/18/2018
# REV:
# First Worked: 10/18/2018
# Purpose: To create a script that will auto-create a project directory with
# template files in the language's file extension and automatically convert the new files to 755 permissions.
#
# REV LIST:
# BY: tacree
# DATE: 10/20/2018
# CHANGES MADE: projectcreator creates the new project directory and prompts the user if they want to
# open a new iTerm2 window (via the ttab tool) and open a new window of Atom text editor in the new directory.
#
#

#set -x

#############################################################
# Section 1: Functions
#############################################################

# Function to get the language provided by the user and create the proper file extension.
function LANGCHECK() {
  if [[ ${PROJLANG} = "python" ]]
  then
    FILETYPE=".py"
  elif [[ ${PROJLANG} = "bash" ]]
  then
    FILETYPE=".sh"
  elif [[ ${PROJLANG} = "ruby" ]]
  then
    FILETYPE=".rb"
  else
    FILETYPE=""
  fi
}

# Function to copy template project folder set up for a new project.
function PROJCREATE() {
  cp -R ~/Scripts/Bash/newproj ~/Scripts/${PROJLANG}/${PROJNAME}
  cd ~/Scripts/${PROJLANG}/${PROJNAME}
  # Loops through any/all files in the project direcotry to manipulate as needed.
  for FILE in *
  do
    # Constructs the new file name with proper file extensions (i.e. moves main to main.sh/.rb/.py)
    NEW_FILE="${FILE}${FILETYPE}"
    mv $FILE ${NEW_FILE}
    # Makes the new file executable.
    chmod 755 ~/Scripts/${PROJLANG}/${PROJNAME}/${NEW_FILE}
    # Update the shebang to #1/usr/bin/env LANGUAGE
    if [[ ${PROJLANG} != "bash" ]]; then
      # sed operation on mac OS requires you to specify the file type after the -i flag.
      # 2 single quotes searches all filetypes.
      sed -i '' 's/bash/'${PROJLANG}'/' ~/Scripts/${PROJLANG}/${PROJNAME}/${NEW_FILE}
    fi

  done
  echo -e "\033[0;32m Created project directory $PROJNAME with ${FILETYPE} file extensions in ~/Scripts/${PROJLANG}/${PROJNAME} \033[0m"
  read -p "Open iTerm2 window of new directory, and open Atom text editor? (y|n)" OPENPROJ
  if [[ ${OPENPROJ} = "y" ]]; then
    ttab cd ~/Scripts/${PROJLANG}/${PROJNAME}/
    atom ~/Scripts/${PROJLANG}/${PROJNAME}/
  elif [[ ${OPENPROJ} = "n" ]]; then
    GIT_INIT
  else
    echo -e "\033[0;31m Error, invalid input. Enter y or n to continue. \033[0m"
    read -p "Open iTerm2 tab of new directory, and open Atom text editor (opens a new Atom window)? (y|n)" OPENPROJ
    if [[ ${OPENPROJ} = "y" ]]; then
      ttab cd ~/Scripts/${PROJLANG}/${PROJNAME}/
      atom ~/Scripts/${PROJLANG}/${PROJNAME}/
      GIT_INIT
    elif [[ ${OPENPROJ} = "n" ]]; then
      GIT_INIT
    else
      echo -e "\033[0;31m Error, invalid input. Enter y or n to continue. \033[0m"
    fi
  GIT_INIT
  fi
}

function USAGE() {
  echo -e "Usage:   newproj -n PROJECTNAME -l PROJECTLANGUAGE"
}

function GIT_INIT() {
  read -p "Project created. Would you like to git INIT this project?" INIT

  if [[ ${INIT} = "y" ]]; then
    cd ~/Scripts/${PROJLANG}/${PROJNAME}/
    git init
  elif [[ ${INIT} = "n" ]]; then
    echo "Not Initializing a repository. Closing tool."
    exit 0
  else
    echo -e "\033[0;31m Error, invalid input. Enter y or n to continue. \033[0m"
  fi

  read -p "Do you have a github repository you would like to add for remote pushes?" REMOTE_REPO

  if [[ ${REMOTE_REPO} = "y" ]]; then
    echo -e "Enter the URL of the github repo. For SSH, ensure your publish SSH key is added for your current machine to your github account!"
    read -p "Please enter the url of the remote repository: " REPO_URL
    echo "Setting git remote origin."
    git remote add origin ${REPO_URL}
    cd ~/Scripts/${PROJLANG}/${PROJNAME}
  elif [[ ${REMOTE_REPO} = "n" ]]; then
    echo "No remote repository added at this time. Have a good day!"
    exit 0
  else
    echo -e "\033[0;31m Error, invalid input. Enter y or n to continue. \033[0m"
  fi
}

#############################################################
# Section 2: Main Body
#############################################################

# Grabs positional parameters and assigns the values for the project name and language, setting up the
# PROJCREATE function to nest the new project directory in the language's parent directory on my macbook.
# Shift before setting the variable to get rid of the flag, and shift after setting the variable to allow
# just 1 while loop, iterating through each positional parameter until finished.
while [ "$1" != "" ]; do
  case $1 in
    -n)
      shift
      PROJNAME=$1
      shift
      ;;
    -l)
      shift
      PROJLANG=$1
      shift
      ;;
    *)
      USAGE
      exit 1
  esac
done

echo "Do you want to create an alias in ~/.bash_profile?"
read NEW_ALIAS

if [[ ${NEW_ALIAS} = "y" ]]; then
  echo "alias newproj=$(pwd)/projsetup/newproj.sh" >> ~/.bash_profile
elif [[ ${NEW_ALIAS} = "n" ]]; then
  LANGCHECK
fi

LANGCHECK
PROJCREATE
