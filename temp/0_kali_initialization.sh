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
    sudo apt-get upgrade 

echo "*********************************************************"
echo "Changing kali default password and creating new user"
echo "*********************************************************"
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
    echo "***********************************************************************"
    echo "If $NEW_USER has no access to sudoers try doing logout and reconnecting"
    echo "***********************************************************************"
    echo "..."
    echo "..."
    echo "..."
    # It fails but I didn't know at the end the issuse. Maybe because I didn't logout and enter again. 
    # Finally, I copy almost the same line in the passwd for kali user to marevalo user

echo "************************************************************************"
echo "#Housekeeping"
echo "*********************************************************"
    echo "List of running services"
    echo "*********************************************************"
    sudo netstat -tulpn > services.txt

    echo "************************************************************************"
    echo "# Setting up RDP with Xfce: https://www.kali.org/docs/general-use/xfce-with-rdp/"
    sudo apt-get install -y kali-desktop-xfce xrdp
    echo "[+] Configuring XRDP to listen to port 3390 (but not starting the service)..."
    sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
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
    curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf

    echo "**********************************************************************"
    echo "Installing the shell and tmux improvements scripts for user "$NEW_USER
    echo "****************************************************************"
    sudo -H -u $NEW_USER bash -c 'echo "I am $USER, with uid $UID"' 
    sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O ~/dotfiles_mod.zip'
    sudo -H -u $NEW_USER bash -c 'cd ~; unzip  ~/dotfiles_mod.zip; chmod +x ~/dotfiles/*.sh; sudo ~/dotfiles/install.sh'
    echo "Copying the tmux logging files to ~/tmux-logging for user "$NEW_USER
    sudo -H -u $NEW_USER bash -c 'cp -R tmux-logging ~/; cd ..'
    sudo -H -u $NEW_USER bash -c 'curl https://raw.githubusercontent.com/marevalo10/hackfiles/main/.tmux.conf -o ~/.tmux.conf'
    echo "****************************************************************"
    echo "..."
    echo "..."
    echo "..."


echo "**********************************************************************"
echo "#Downloading recon scripts to new user "$NEW_USER
echo "****************************************************************"
    sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/run_scripts_tmux.sh -O ~/run_scripts_tmux.sh'
    sudo -H -u $NEW_USER bash -c 'chmod +x ~/run_scripts_tmux.sh'
    sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/scripts_recon.zip -O ~/scripts_recon.zip'
    sudo -H -u $NEW_USER bash -c 'cd ~; unzip scripts_recon.zip; chmod +x ~/scripts_recon/*.sh'
    echo "#Files ready in scripts_recon"
    echo "Please create the ips.txt and ips.udp files and copy them in the scripts_recon directory"
    echo "and then run run_scripts_tmux.sh using the "$NEW_USER" account"
    echo "************************************************************************"
    echo "Granting access to run scripts from tmux"
    sudo sh -c $NEW_USER"   ALL = NOPASSWD: /home/"$NEW_USER"/scripts_recon/*.sh"
    echo "************************************************************************"
    echo "Process completed"
    echo "Machine ready to attack! Nice hacking"
    echo "Run sudo visudo and add this line at the end: "
    echo "marevalo        ALL = NOPASSWD: /home/"$NEW_USER"/scripts_recon/*sh"
    echo "Close the session and start as the new user "$NEW_USER
    echo "Create 2 files with the in-scope ips (ips.txt and ips.udp) and then...."
    echo "You can run ./run_scripts_tmux.sh to start the automated scans"
    echo "****************************************************************"
    echo "..."
    echo "..."
    echo "..."


echo "************************************************************************"
echo "Next step: install the software using the script 1_SoftwareInstall.sh"
echo "Press enter to start the software installation or ctrl-c to cancel"
echo "************************************************************************"
    read
    echo "Getting it by wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/1_software_install.sh -O 1_software_install.sh"
    wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/1_software_install.sh -O 1_software_install.sh
    echo "************************************************************************"
    echo "Running 1_software_install.sh"
    chmod +x 1_software_install.sh
    ./1_software_install.sh