#!/usr/bin/env bash

echo ""
echo "Installing stutterAI. Your AI assistant in the terminal."
echo ""

# Check Python version
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
pip3 list | grep openai > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  pip3 install openai --user
  if [[ $? -ne 0 ]]; then
    echo "Failed to install openai package. Aborting."
    exit 1
  fi
fi

# Create directories if they don't exist
mkdir -p ~/.local/bin/stutterAI
mkdir -p ~/.local/lib/stutterAI

# Step 1: Copy err to ~/.local/bin/stutterAI/
cp ./err ~/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'err' file. Aborting."
  exit 1
fi

# Step 2: Make err executable
chmod +x ~/.local/bin/stutterAI/err
if [ $? -ne 0 ]; then
  echo "Failed to set 'err' as executable. Aborting."
  exit 1
fi

# Step 3: Copy uhm to ~/.local/bin/stutterAI/
cp ./uhm ~/.local/bin/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'uhm' file. Aborting."
  exit 1
fi

# Step 4: Make uhm executable
chmod +x ~/.local/bin/stutterAI/uhm
if [ $? -ne 0 ]; then
  echo "Failed to set 'uhm' as executable. Aborting."
  exit 1
fi

# Step 5: Copy stutterAI.py to ~/.local/lib/stutterAI/
cp ./stutterAI.py ~/.local/lib/stutterAI/
if [ $? -ne 0 ]; then
  echo "Failed to copy 'stutterAI.py' file. Aborting."
  exit 1
fi

# Step 6: Prompt for OpenAI API Key and save to JSON
read -p "Please enter your OpenAI API Key: " api_key
echo "{\"API_KEY\": \"$api_key\"}" > ~/.stutterAI_secrets.json
if [ $? -ne 0 ]; then
  echo "Failed to write API Key to JSON file. Aborting."
  exit 1
fi

# Step 7: Add to .bashrc
echo -e $'\n\n# stutterAI app commands\nfor i in $HOME/.local/bin/stutterAI/*;\n  do source $i\ndone\n' >> ~/.bashrc

# Step 8: Bash history recommendation
echo "To keep your bash history clean, it's recommended to add the following lines to your ~/.bashrc file:"
echo ""
echo "shopt -s histappend"
echo "HISTCONTROL=ignoredups:erasedups"
echo ""
echo "You can add them by running the following command:"
echo "echo -e '\\nshopt -s histappend\\nHISTCONTROL=ignoredups:erasedups' >> ~/.bashrc"

# Step 9: Echo successful installation
echo ""
echo "INSTALLATION SUCCESSFUL!"
echo ""
echo "Changes will take effect after starting a new terminal session."
echo "Your API Key is located here: ~/.stutterAI_secrets.json"
echo ""
