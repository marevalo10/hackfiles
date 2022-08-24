echo "****************************************************************"
echo "Installing the shell and tmux improvements scripts for kali user "
echo "****************************************************************"
    echo "Downloading and Installing dotfiles"
    cd ~/
    wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O dotfiles_mod.zip
    unzip  dotfiles_mod.zip
    cd dotfiles
    chmod +x *.sh
    sudo ./install.sh
    echo "Copying the tmux logging files to ~/tmux-logging"
    git clone https://github.com/tmux-plugins/tpm
    cp -R tmux-logging ~/
    cd ..
    chmod +x ~/tmux-logging/logging.tmux
    chmod +x ~/tmux-logging/scripts/*.sh
    curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf
    rm dotfiles_mod.zip
    echo "tmux configured to support mouse and logs. It is also configured to save history using Ctrl+b Shift+p ..."