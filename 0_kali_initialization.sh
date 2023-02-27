#!/bin/bash
# This file can be downloaded by wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/0_kali_initialization.sh -O 0_kali_initialization.sh
#Change this user if you want to use a different one
NEW_USER="marevalo"

#Shell:
echo "*********************************************************"
echo "Updating the system..."
echo "*********************************************************"
    sudo apt-get update
    # These sometimes cause the system to fail…. Sometimes it is better to download an updated version from Kali
    #sudo apt-get upgrade 

username=`whoami`
echo "*************************************************************************"
echo "Changing kali default password and creating new user if the user is kali"
echo "*************************************************************************"
if [ $username = kali ]; then
    sudo passwd kali
    echo "*********************************************************"
    echo "Creating new user and adding it to sudoers "$NEW_USER 
    echo "*********************************************************"
    sudo useradd $NEW_USER -m
    echo "Define a password for new user "$NEW_USER
    echo "*********************************************************"
    sudo passwd $NEW_USER
    sudo usermod -a -G sudo $NEW_USER
    sudo chsh -s /usr/bin/zsh $NEW_USER
    echo "Adding user to let it SSH"
    echo "By adding this line:  AllowUsers kali, "$NEW_USER
    echo 'AllowUsers kali, '$NEW_USER | sudo tee -a  /etc/ssh/sshd_config
    echo "***********************************************************************"
    echo "If $NEW_USER has no access to sudoers try doing logout and reconnecting"
    echo "***********************************************************************"
    echo "..."
    echo "..."
    echo "..."
    # It fails but I didn't know at the end the issuse. Maybe because I didn't logout and enter again. 
    # Finally, I copy almost the same line in the passwd for kali user to marevalo user
fi

echo "************************************************************************"
echo "#Housekeeping"
echo "*********************************************************"
    echo "List of running services"
    echo "*********************************************************"
    sudo netstat -tulpn |tee services.txt

    echo "*********************************************************"
    echo "Disabling root login"
    echo "By adding this line:  PermitRootLogin no to /etc/ssh/sshd_config"
    echo 'PermitRootLogin no' | sudo tee -a  /etc/ssh/sshd_config
    echo "Setting time-zone"
    sudo timedatectl set-timezone Australia/Melbourne
    echo "*********************************************************"

    echo 'Cleaning ssh'
    sudo rm /etc/ssh/ssh_host_*
    sudo dpkg-reconfigure openssh-server
    sudo service ssh restart
    echo "# Configuring SSH to run after restarts"
    sudo systemctl enable ssh

    #echo "# Stop eth1 (if it is active)"
    #sudo ifconfig eth1 down

    echo "************************************************************************"
    echo "# Setting up RDP with Xfce: https://www.kali.org/docs/general-use/xfce-with-rdp/"
    #sudo apt-get install -y kali-desktop-xfce xrdp
    sudo apt-get install -y xrdp
    echo "[+] Configuring XRDP to listen to port 3390 (but not starting the service)..."
    sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
    sudo adduser xrdp ssl-cert
    sudo systemctl enable xrdp --now
    sudo systemctl enable xrdp-sesman
    #If you are using WSL, dbus-x11 needs to be installed next for xrdp and xfce to connect.
    #sudo apt install -y dbus-x11
    sudo systemctl start xrdp
    sudo systemctl start xrdp-sesman
    echo "************************************************************************"
    echo "Be sure to not be logged into the Kali GUI interface when connecting to the RDP service"
    echo "************************************************************************"
    echo "..."
    echo "..."
    echo "..."

    echo "Including the time in the promp#"
    cp ~/.zshrc ~/.zshrc.bak
    #Not working, pending to adjust
    #sed -i 's|%B%(#.%F{red}#.%F{blue}$)%b%F{reset}|%{$fg[yellow]%}[%D{%y-%m-%d %T}]%B%(#.%F{red}#.%F{blue}$)%b%F{reset}|g' .zshrc
    #Add the date to the PROMPT
    replaceby="└─%{$fg[yellow]%}[%D{%y-%m-%d %T}]"
	sed -i.bak "s/└─/$replaceby/g" ~/.zshrc
    source ~/.zshrc

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

    #echo "Downloading and Installing dotfiles"
    #git clone https://github.com/marevalo10/hackfiles.git
    #cd hackfiles
    #chmod +x *.sh
    #sudo ./install.sh
    echo "Copying the tmux logging files to ~/tmux-logging"
    cp -R tmux-logging ~/
    chmod +x ~/tmux-logging/logging.tmux
    chmod +x ~/tmux-logging/scripts/*.sh
    echo "Cloning tmux plugins"
    git clone https://github.com/tmux-plugins/tpm
    cp -R tpm ~/
    #curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf
    cp .tmux.conf ~/.tmux.conf


    if [ $username = kali ]; then
        echo "**********************************************************************"
        echo "Installing the shell and tmux improvements scripts for user "$NEW_USER
        echo "****************************************************************"
        sudo -H -u $NEW_USER bash -c 'echo "I am $USER, with uid $UID"' 
        sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O ~/dotfiles_mod.zip'
        sudo -H -u $NEW_USER bash -c 'cd ~; unzip  ~/dotfiles_mod.zip; chmod +x ~/dotfiles/*.sh; sudo ~/dotfiles/install.sh'
        echo "Copying the tmux logging files to ~/tmux-logging for user "$NEW_USER
        sudo -H -u $NEW_USER bash -c 'cp -R ~/dotfiles/tmux-logging ~/; rm dotfiles_mod.zip'
        sudo -H -u $NEW_USER bash -c 'cp -R ~/tpm ~/'
        sudo -H -u $NEW_USER bash -c 'curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf'
        sudo -H -u $NEW_USER bash -c 'replaceby="└─%{$fg[yellow]%}[%D{%y-%m-%d %T}]"'
        sudo -H -u $NEW_USER bash -c 'sed -i.bak "s/└─/$replaceby/g" ~/.zshrc'
        sudo -H -u $NEW_USER bash -c 'source ~/.zshrc'
        echo "****************************************************************"
        echo "..."
        echo "..."
        echo "..."

        echo "**********************************************************************"
        echo "#Downloading recon scripts to new user "$NEW_USER
        echo "**********************************************************************"
        #sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/run_scripts_tmux.sh -O ~/run_scripts_tmux.sh'
        #sudo -H -u $NEW_USER bash -c 'chmod +x ~/run_scripts_tmux.sh'
        #sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/scripts_recon.zip -O ~/scripts_recon.zip'
        #sudo -H -u $NEW_USER bash -c 'cd ~; unzip scripts_recon.zip; chmod +x ~/scripts_recon/*.sh'
        sudo -H -u $NEW_USER bash -c 'cd ~; git clone https://github.com/marevalo10/hackfiles.git; chmod +x ~/hackfiles/*.sh; chmod +x ~/hackfiles/scripts_recon/*.sh;'
        echo "#Files ready in ~/hackfiles/scripts_recon/"
        echo "Please create the ips.txt and ips.udp files and copy them in the scripts_recon directory"
        #echo "and then run run_scripts_tmux.sh using the "$NEW_USER" account"
        echo "************************************************************************"
        echo "Granting access to run scripts from tmux"
        sudo sh -c $NEW_USER"   ALL = NOPASSWD: /home/"$NEW_USER"/hackfiles/scripts_recon/*.sh"
        echo "************************************************************************"
        echo "Process completed"
        echo "Machine ready to attack! Nice hacking"
        echo "Run sudo visudo and add this line at the end: "
        echo "marevalo        ALL = NOPASSWD: /home/"$NEW_USER"/hackfiles//scripts_recon/*sh"
        echo "Close the session and start as the new user "$NEW_USER
        echo "Create 2 files with the in-scope ips (ips.txt and ips.udp) and then...."
        echo "You can run ./run_scripts_tmux.sh to start the automated scans"
        echo "****************************************************************"
        echo "..."
        echo "..."
        echo "..."
    fi


echo "************************************************************************"
echo "Next step: install the software using the script 1_SoftwareInstall.sh"
echo "Getting it by wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/1_software_install.sh -O 1_software_install.sh"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/1_software_install.sh -O 1_software_install.sh
chmod +x 1_software_install.sh
echo "File was downloaded, you can run it by yourself (./1_SoftwareInstall.sh)"
echo "************************************************************************"
