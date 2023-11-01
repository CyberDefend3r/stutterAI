# StutterAI
Your AI assistant in the terminal.  
  
stutterAI solves two huge pain points people have in the terminal using AI:  
* Corrects typos and syntax errors in commands and file paths. *[err](#err)*
* Generates system-aware commands from a prompt. For when you know what you want to do but don't know how to make it happen. *[uhm](#uhm)*
  
Gone are the days of scrolling through man pages, endless Google searching, hunting through stack overflow, etc.  **stutterAI** has your back.  

It uses the openAI gpt-4 model API *(BYOK)* by default; you can change to gpt-3.5-turbo by modifying a few lines in the `stutterAI.py` file, though, in testing it was not reliable.  

stutterAI will not execute any commands it generates; instead, it adds them to your bash history. Additionally, when using it to fix a previously run command, it replaces the broken command with a working one in the bash history. To run a command it makes, just press up on the keyboard and then enter.  
  
The decision to manipulate the bash history was really for convenience. Copy and paste in terminals suck. Added bonus is that you won't have any broken commands in your bash history, either.  
  
## Usage
It is super easy to use. There are only two commands available, and neither have arguments: `err` and `uhm`. Once it completes generating the command, it adds it to your bash history, so to run it, you just press up once, and you're good to go.  

### err
Did you run a command and get an error? Just type `err` and hit enter; the rest is magic.  

![err](https://github.com/CyberDefend3r/stutterAI/assets/22669390/be4d7a18-f03f-4a8b-9df2-7c074c56d652)  
  
### uhm
Know what you want a command to do but don't know how to write it? Just type `uhm` and hit enter. You will get prompted to describe what you want to accomplish, then let the stutterAI do its thing.  
  
![uhm](https://github.com/CyberDefend3r/stutterAI/assets/22669390/01182918-8f38-488a-b958-b8dcb680775e)  
  
## Install and Setup

1. Clone or download this repository.
2. Open the terminal.
3. `cd` to the directory containing stutterAI files downloaded.
4. Type `sh install_stutterAI.sh` and press enter.
5. Enter your openAI API key when prompted.

There is one optional but **recommended** step to add 2 lines to your .bashrc file to keep your bash history updated and clean from duplicates etc. The install script will tell you how and provide a oneliner command to add them if you choose to do so. Details [here.](https://www.geeksforgeeks.org/histcontrol-command-in-linux-with-examples/#)
   
## Disclosures
I do not collect, retain, or disseminate any of your data or information. There is no mechanism or code in this application that can even facilitate that. Any data or information that is shared by this application is sent directly to openAI using your own personal API key from your openAI account.

### Information that is shared with openAI
The following system information is passed to openAI to give the model the necessary context specific to your computer, enabling better, more personalized, and useful responses.  
* Current working Directory
* list of files and folders in the current directory
* last 10 entries in bash history
* contents of the .bashrc file
* When using `err`:
  * the command you ran that didn't work
  * the associated error message
  * if a file/folder path is invalid, file and folder names outside the current directory will also be shared in an attempt to repair the path in the command.

You **shouldn't** have any sensitive information in these locations. However, if you don't want to send some of this information to openAI, [comment out the relevant lines](https://github.com/CyberDefend3r/stutterAI/blob/acfe985baef10af83f53e957ad6b3abb0b2f492d/stutterAI.py#L34) in the `stutterAI.py` file. This will likely result in less reliable responses when using `err`.  
  
**Note:** When using the openAI API, openAI does not use your data to train its models but may retain your inputs/outputs for up to 30 days to identify abuse of their systems. Read openAI's privacy commitments and policies [here.](https://openai.com/enterprise-privacy)  
  
### Risk
Though the app will not execute any of the commands it generated automatically, there is a risk when running commands you don't fully understand, especially when generated by an AI, which may harm you, your computer, your data, or your unborn child.  
  
Risks may include but are not limited to:  
* Data destruction/loss
* Data leakage
* Insecure configurations
* DOXXing 
* Gaslighting
* Disintegration of your computer
* Unintended actions such as:
  * Damage to your mental health
  * Email your nudes to your mom
  * Start a nuclear war
  * Bring Hitler back to life
  * Anything is possible; *you get the point*.

By using this application and making the personal decision to execute the commands it generates, you accept all risk associated with doing so and are solely responsible for any and all intended or unintended consequences of that decision.
  
  
----  
<img src="https://cdn.cdnlogo.com/logos/t/48/twitter.png" width="20px"> [@Cyb3rDefender](https://twitter.com/Cyb3rDefender)
