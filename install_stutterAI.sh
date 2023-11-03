#!/usr/bin/env bash

echo ""
echo "Installing stutterAI. Your AI assistant in the terminal."
echo ""

if [[ $(echo $PATH | grep "/.local/bin") == $'' ]]; then
  echo "WARNING: \$HOME/.local/bin is not in PATH. Please add it or stutterAI may not work properly."
  exit 1
fi

# Check Python version
echo "Checking Python version"
python_version=$(python3 --version 2>&1)
if [[ $? -ne 0 ]]; then
  echo "Python 3 is not installed. Aborting."
  exit 1
fi
parsed_version=$(echo $python_version | awk '{print $2}')
if [[ $(echo -e "3.10.0\n$parsed_version" | sort -V | head -n1) != "3.10.0" ]]; then
  echo "Python 3.10 or higher is required. You have $parsed_version. Aborting."
  exit 1
fi

# Check if OpenAI package is installed
echo "Checking if openai python package is installed"
openai_version=$(pip3 list | grep openai 2>&1 | awk '{print $2}')
if [ $openai_version == $'' ]; then
  echo "Installing openai with the command: pip3 install openai --user"
  pip3 install openai --user
  if [[ $? -ne 0 ]]; then
    echo "Failed to install openai package. Aborting."
    exit 1
  fi
fi

# Check if OpenAI package needs upgrading
if [[ $(echo -e "0.28.0\n$openai_version" | sort -V | head -n1) != "0.28.0" ]]; then
  echo "openai 0.28.0 or higher is required. You have $openai_version."
  read -n1 -p "Would you like to upgrade the openai package? (y/n)"
  if [[ $REPLY == $'y' ]]; then
    echo "Upgrading openai with the command: pip3 install openai --upgrade --user"
    pip3 install openai --upgrade --user
    if [[ $? -ne 0 ]]; then
      echo "Failed to upgrade openai package. Aborting."
      exit 1
    fi
  else
    echo "Please upgrade openai yourself then run this installer again: pip3 install openai --upgrade --user"
    exit 1
  fi
fi

# Create directories if they don't exist
mkdir -p $HOME/.local/bin/stutterAI/commands

echo "Copying files"
# Copy err to $HOME/.local/bin/stutterAI/commands
cp ./commands/err $HOME/.local/bin/stutterAI/commands
if [ $? -ne 0 ]; then
  echo "Failed to copy 'err' file. Aborting."
  exit 1
fi

# Copy uhm to $HOME/.local/bin/stutterAI/commands
cp ./commands/uhm $HOME/.local/bin/stutterAI/commands
if [ $? -ne 0 ]; then
  echo "Failed to copy 'uhm' file. Aborting."
  exit 1
fi

# Copy stutterAI.py to $HOME/.local/bin/stutterAI/
cp ./stutterAI.py $HOME/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'stutterAI.py' file. Aborting."
  exit 1
fi

# Prompt for OpenAI API Key and save to JSON
read -s -p "Please paste your OpenAI API Key and press ENTER: " api_key
echo "{\"API_KEY\": \"$api_key\"}" > $HOME/.stutterAI_secret.json
if [ $? -ne 0 ]; then
  echo "Failed to write API Key to JSON file. Aborting."
  echo $'\nOverwriting API Key in memory with zeros'
  api_key=$(printf '0%.0s' {1..100})
  exit 1
fi

echo $'\nOverwriting API Key in memory with zeros'
api_key=$(printf '0%.0s' {1..100})
echo "Your API Key is located here: $HOME/.stutterAI_secret.json"

# Add to .bashrc
# Check if the line "# stutterAI app commands" is present in $HOME/.bashrc
grep -q '# stutterAI app commands' $HOME/.bashrc
# $? is 0 if grep found the line, 1 otherwise
if [ $? -ne 0 ]; then
  # Append the lines to $HOME/.bashrc
  echo -e $'\n\n# stutterAI app commands\nfor i in $HOME/.local/bin/stutterAI/commands/*;\n  do source $i\ndone\n' >> $HOME/.bashrc
  if [ $? -ne 0 ]; then
    echo "Failed to update .bashrc file. You need to add stutterAI app commands manually to .bashrc by running the following command."
    echo "echo -e \$'\\n\\n# stutterAI app commands\\nfor i in \$HOME/.local/bin/stutterAI/commands*;\\n  do source \$i\\ndone\\n' >> \$HOME/.bashrc"
  fi
else
  sed -i '/# stutterAI app commands/,/done/{s|\.local/bin/stutterAI/\*|\.local/bin/stutterAI/commands/\*|}' $HOME/.bashrc
fi

# Bash history recommendation
echo ""
echo "NOTE: To keep your bash history clean, we recommended adding the following line to your .bashrc file:"
echo ""
echo "HISTCONTROL=ignoredups:erasedups"
echo ""
echo "You can add it by running the following command or with a text editor."
echo "echo -e $'\\nHISTCONTROL=ignoredups:erasedups\\n' >> \$HOME/.bashrc"

# Echo successful installation
echo ""
echo "INSTALLATION SUCCESSFUL!"
echo "stutterAI will be available the next time you open your terminal. To use it immediately run the command: source $HOME/.bashrc"
