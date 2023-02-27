echo "****************************************************************************"
echo "Old file, mostly included in the initial configuration. Not required to run "
echo "Ctrl - C to cancel"
read temp
echo "Installing the shell and tmux improvements scripts for kali user "
echo "****************************************************************************"

    echo "Including the time in the promp#"
    cp ~/.zshrc ~/.zshrc.bak
    replaceby="└─%{$fg[yellow]%}[%D{%y-%m-%d %T}]"
	sed -i.bak "s/└─/$replaceby/g" ~/.zshrc
    source ~/.zshrc

    echo "Copying the tmux logging files to ~/tmux-logging"
    cp -R tmux-logging ~/
    chmod +x ~/tmux-logging/logging.tmux
    chmod +x ~/tmux-logging/scripts/*.sh
    echo "Cloning tmux plugins"
    git clone https://github.com/tmux-plugins/tpm
    cp -R tpm ~/
    #curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf
    cp .tmux.conf ~/.tmux.conf
