#!/bin/bash

BOLD_UNDERLINE='\e[1;4;1m'
COLOR_RED='\e[1;31m'
COLOR_YELLOW='\e[1;33m'
COLOR_GREEN='\e[0;32m'
COLOR_RST='\e[0m'
NL='\n'


echo ""
echo "stutterAI"
echo "Your AI assistant in the terminal."
echo -e "${BOLD_UNDERLINE}                                  ${COLOR_RST}"
echo ""
# Check Python version
echo "[ INFO ] Checking Python version"
python_version=$(python3 --version 2>&1)
if [[ $? -ne 0 ]]; then
  echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Python 3 is not installed. Aborting Installation!"
  exit 1
fi
parsed_version=$(echo $python_version | awk '{print $2}')
if [[ $(echo -e "3.10.0\n$parsed_version" | sort -V | head -n1) != "3.10.0" ]]; then
  echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Python 3.10 or higher is required. You have $parsed_version. Aborting Installation!"
  exit 1
else
  echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] Python version $parsed_version found."
fi

# Check if OpenAI package is installed
echo "[ INFO ] Checking if openai python package is installed"
openai_version=$(pip3 list 2>&1 | grep openai 2>&1 | awk '{print $2}')
if [ $openai_version == $'' ]; then
  echo -e "[${COLOR_YELLOW} WARN ${COLOR_RST}] Installing openai with the command: pip3 install openai --user"
  pip3 install openai --user
  if [[ $? -ne 0 ]]; then
    echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to install openai package. Aborting Installation!"
    exit 1
  else
    echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] openai package installed."
  fi
fi

# Check if OpenAI package needs upgrading
if [[ $(echo -e "1.0.0\n$openai_version" | sort -V | head -n1) != "1.0.0" ]]; then
  echo -e "[${COLOR_YELLOW} WARN ${COLOR_RST}] openai 1.0.0 or higher is required. You have $openai_version."
  read -n1 -p "Would you like to upgrade the openai package? (y/n)"
  if [[ $REPLY == $'y' ]]; then
    echo "[ INFO ] Upgrading openai with the command: pip3 install openai --upgrade --user"
    pip3 install openai --upgrade --user
    if [[ $? -ne 0 ]]; then
      echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to upgrade openai package. Aborting Installation!"
      exit 1
    else
      echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] openai package upgraded."
    fi
  else
    echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Please upgrade openai yourself then run this installer again: pip3 install openai --upgrade --user"
    exit 1
  fi
else
  echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] openai package version $openai_version found."
fi

# Create directories if they don't exist
mkdir -p $HOME/.local/bin/stutterAI/commands

echo "[ INFO ] Copying files"
# Copy err to $HOME/.local/bin/stutterAI/commands
cp ./commands/err $HOME/.local/bin/stutterAI/commands
if [ $? -ne 0 ]; then
  echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to copy 'err' file. Aborting Installation!"
  exit 1
fi

# Copy uhm to $HOME/.local/bin/stutterAI/commands
cp ./commands/uhm $HOME/.local/bin/stutterAI/commands
if [ $? -ne 0 ]; then
  echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to copy 'uhm' file. Aborting Installation!"
  exit 1
fi

# Copy stutterAI.py to $HOME/.local/bin/stutterAI/
cp ./stutterAI.py $HOME/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to copy 'stutterAI.py' file. Aborting Installation!"
  exit 1
fi
echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] Files copied to $HOME/.local/bin/stutterAI"

# Prompt for OpenAI API Key and save to JSON
read -s -p "Please paste your OpenAI API Key and press ENTER: " api_key
if ! [[ $(echo -e "$api_key" | grep '^[a-zA-Z0-9].*$') == "" ]]; then
  echo "{\"API_KEY\": \"$api_key\"}" > $HOME/.stutterAI_secret.json
  if [ $? -ne 0 ]; then
    echo -e "${NL}[${COLOR_RED} FAIL ${COLOR_RST}] Failed to write API Key to JSON file. Aborting Installation!"
    echo $'\n[ INFO ] Overwriting API Key in memory with zeros'
    api_key=$(printf '0%.0s' {1..100})
    exit 1
  fi
  echo -e "${NL}[${COLOR_GREEN} PASS ${COLOR_RST}] Your API Key is located here: $HOME/.stutterAI_secret.json"
  echo $'[ INFO ] Overwriting API Key in memory with zeros'
  api_key=$(printf '0%.0s' {1..100})
else
  echo -e "${NL}[${COLOR_RED} FAIL ${COLOR_RST}] No API Key provided. Aborting Installation!"
  exit 1
fi

# Add to .bashrc
# Check if the line "# stutterAI app commands" is present in $HOME/.bashrc
grep -q '# stutterAI app commands' $HOME/.bashrc
# $? is 0 if grep found the line, 1 otherwise
if [ $? -ne 0 ]; then
  # Append the lines to $HOME/.bashrc
  echo -e $'\n\n# stutterAI app commands\nfor i in $HOME/.local/bin/stutterAI/commands/*;\n  do source $i\ndone\n' >> $HOME/.bashrc
  if [ $? -ne 0 ]; then
    echo -e "[${COLOR_RED} FAIL ${COLOR_RST}] Failed to update .bashrc file. You need to add stutterAI app commands manually to .bashrc by running the following command."
    echo "echo -e \$'\\n\\n# stutterAI app commands\\nfor i in \$HOME/.local/bin/stutterAI/commands*;\\n  do source \$i\\ndone\\n' >> \$HOME/.bashrc"
  fi
else
  sed -i '/# stutterAI app commands/,/done/{s|\.local/bin/stutterAI/\*|\.local/bin/stutterAI/commands/\*|}' $HOME/.bashrc
fi

# Check $PATH
if [[ $(echo $PATH | grep '^.*\/\.local\/bin.*$') == "" ]]; then
  echo -e "[${COLOR_YELLOW} WARN ${COLOR_RST}] \"\$HOME/.local/bin\" is not in PATH. Please add it or stutterAI may not work properly."
fi
# Echo successful installation
echo -e "[${COLOR_GREEN} PASS ${COLOR_RST}] INSTALLATION SUCCESSFUL!"
echo -e "${BOLD_UNDERLINE}                                  ${COLOR_RST}"
# Bash history recommendation
echo "NOTE:"
echo "To keep your bash history clean, we recommended adding the following line to your .bashrc file:"
echo ""
echo "HISTCONTROL=ignoredups:erasedups"
echo ""
echo "You can add it by running the following command or with a text editor."
echo "echo -e $'\\nHISTCONTROL=ignoredups:erasedups\\n' >> \$HOME/.bashrc"
echo -e "${BOLD_UNDERLINE}                                  ${COLOR_RST}"
echo "NOTE:"
echo "stutterAI will be available the next time you open your terminal."
echo "To use it immediately run the command: source $HOME/.bashrc"
echo -e "${BOLD_UNDERLINE}                                  ${COLOR_RST}"
echo ""


