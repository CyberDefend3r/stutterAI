#!/usr/bin/env bash

echo ""
echo "Installing stutterAI. Your AI assistant in the terminal."
echo ""

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
pip3 list | grep openai > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Installing openai with pip"
  pip3 install openai --user
  if [[ $? -ne 0 ]]; then
    echo "Failed to install openai package. Aborting."
    exit 1
  fi
fi

# Create directories if they don't exist
mkdir -p ~/.local/bin/stutterAI
mkdir -p ~/.local/lib/stutterAI

echo "Copying files"
# Copy err to ~/.local/bin/stutterAI/
cp ./err ~/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'err' file. Aborting."
  exit 1
fi

# Copy uhm to ~/.local/bin/stutterAI/
cp ./uhm ~/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'uhm' file. Aborting."
  exit 1
fi

# Copy stutterAI.py to ~/.local/lib/stutterAI/
cp ./stutterAI.py ~/.local/lib/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'stutterAI.py' file. Aborting."
  exit 1
fi

# Prompt for OpenAI API Key and save to JSON
read -s -p "Please paste your OpenAI API Key and press ENTER: " api_key
echo "{\"API_KEY\": \"$api_key\"}" > ~/.stutterAI_secret.json
if [ $? -ne 0 ]; then
  echo "Failed to write API Key to JSON file. Aborting."
  echo $'\nOverwriting API Key in memory with zeros'
  api_key=$(printf '0%.0s' {1..100})
  exit 1
fi

echo $'\nOverwriting API Key in memory with zeros'
api_key=$(printf '0%.0s' {1..100})

# Add to .bashrc
# Check if the line "# stutterAI app commands" is present in ~/.bashrc
grep -q '# stutterAI app commands' ~/.bashrc
# $? is 0 if grep found the line, 1 otherwise
if [ $? -ne 0 ]; then
  # Append the lines to ~/.bashrc
  echo -e $'\n\n# stutterAI app commands\nfor i in $HOME/.local/bin/stutterAI/*;\n  do source $i\ndone\n' >> ~/.bashrc
  if [ $? -ne 0 ]; then
    echo "Failed to update ~/.bashrc. You need to add stutterAI app commands manually to .bashrc by running the following command."
    echo "echo -e $'\\n\\n# stutterAI app commands\\nfor i in $HOME/.local/bin/stutterAI/*;\\n  do source $i\\ndone\\n' >> ~/.bashrc"
  fi
fi

# Bash history recommendation
echo ""
echo "To keep your bash history clean, it's recommended to add the following lines to your ~/.bashrc file:"
echo ""
echo "shopt -s histappend"
echo "HISTCONTROL=ignoredups:erasedups"
echo ""
echo "You can add them by running the following command or with a text editor."
echo "echo -e '\\nshopt -s histappend\\nHISTCONTROL=ignoredups:erasedups' >> ~/.bashrc"

# Echo successful installation
echo ""
echo "INSTALLATION SUCCESSFUL!"
echo ""
echo "Changes will take effect after starting a new terminal session."
echo "Your API Key is located here: ~/.stutterAI_secret.json"
echo ""
