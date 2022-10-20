#!/bin/bash
#echo "Downloading all scripts"
git clone https://github.com/marevalo10/hackfiles.git
echo "****************************************************************"
echo "Installing the shell and tmux improvements scripts for kali user "
echo "****************************************************************"
# Check if vim-addon installed, if not, install it automatically
if hash vim-addon  2>/dev/null; then
    echo "vim-addon (vim-scripts) already installed"
else
    echo "vim-addon (vim-scripts) not installed, installing"
    sudo apt -y install vim-scripts
fi
echo "Vim addons Installed"

cd hackfiles
chmod +x *.sh *.py
echo "Copying the tmux logging files to ~/tmux-logging"
cp -R tmux-logging ~/
cp .tmux.conf ~/.tmux.conf
chmod +x ~/tmux-logging/logging.tmux
chmod +x ~/tmux-logging/scripts/*.sh
echo "Cloning tmux plugins"
cd ~
git clone https://github.com/tmux-plugins/tpm
#curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf

#Add the date to the PROMPT
replaceby="└─%{$fg[yellow]%}[%D{%y-%m-%d %T}]"
sed -i.bak "s/└─/$replaceby/g" ~/.zshrc
source ~/.zshrc