echo "****************************************************************"
echo "Installing the shell and tmux improvements scripts for kali user "
echo "****************************************************************"
    echo "Downloading and Installing dotfiles"
    wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O dotfiles_mod.zip
    unzip  dotfiles_mod.zip
    cd dotfiles
    chmod +x *.sh
    sudo ./install.sh
    echo "Copying the tmux logging files to ~/tmux-logging"
    cp -R tmux-logging ~/
    cd ..
    curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o .tmux.conf 
    rm dotfiles_mod.zip
    echo "tmux configured to support mouse and logs..."