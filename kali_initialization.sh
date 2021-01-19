#!/bin/bash
#Shell:
echo "*********************************************************"
echo "Updating the system..."
echo "*********************************************************"
sudo apt-get update
# These sometimes cause the system to fail…. It is better to download an updated version from Kali
#apt-get upgrade 
#apt-get dist-upgrade

NEW_USER="marevalo"
echo "*********************************************************"
echo "Changing kali default password"
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
echo "If marevalo has no access to sudoers try doing logout and reconnecting"
echo "***********************************************************************"
# It fails but I didn't know at the end the issuse. maybe because I didn't logout and enter again. Finally, I copy almost the same line in the passwd for kali user to marevalo

#Housekeeping
#Check running services and take note of them
echo "*********************************************************"
echo "List of running services"
echo "*********************************************************"
sudo netstat -tulpn > services.txt

echo "*********************************************************"
echo "Disabling root login"
echo "By adding this line:  PermitRootLogin no"
echo 'PermitRootLogin no' | sudo tee -a  /etc/ssh/sshd_config
echo "Adding user to let it SSH"
echo "By adding this line:  AllowUsers marevalo,kali"
echo 'AllowUsers kali,'$NEW_USER | sudo tee -a  /etc/ssh/sshd_config
echo "*********************************************************"

echo 'Cleaning ssh'
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo service ssh restart
echo "#Turning SSH to run after restarts"
sudo systemctl enable ssh

echo "#Stop eth1"
sudo ifconfig eth1 down

echo "****************************************************************"
echo "Installing the shell and tmux improvements scripts for kali user "
echo "Downloading and Installing dotfiles"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O dotfiles_mod.zip
unzip  dotfiles_mod.zip
cd dotfiles
chmod +x *.sh
sudo ./install.sh
echo "Copying the tmux logging files to ~/tmux-logging"
cp -R tmux-logging ~/
cd ..

echo "**********************************************************************"
echo "Installing the shell and tmux improvements scripts for user "$NEW_USER
sudo -H -u $NEW_USER bash -c 'echo "I am $USER, with uid $UID"' 
sudo -H -u $NEW_USER bash -c 'wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip -O ~/dotfiles_mod.zip'
sudo -H -u $NEW_USER bash -c 'cd ~; unzip  ~/dotfiles_mod.zip; chmod +x ~/dotfiles/*.sh; sudo ~/dotfiles/install.sh'
echo "Copying the tmux logging files to ~/tmux-logging for user "$NEW_USER
sudo -H -u $NEW_USER bash -c 'cp -R ~/dotfiles/tmux-logging ~/; rm dotfiles_mod.zip'

echo "**********************************************************************"
echo "#Downloading recon scripts to new user "$NEW_USER
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
echo "Process completed"
echo "Machine ready to attack! Nice hacking"
echo "Run sudo visudo and add this line at the end: "
echo "marevalo        ALL = NOPASSWD: /home/"$NEW_USER"/scripts_recon/*sh"
echo "Close the session and start as the new user "$NEW_USER
echo "Create 2 files with the in-scope ips (ips.txt and ips.udp) and then...."
echo "You can run ./run_scripts_tmux.sh to start the automated scans"
echo "************************************************************************"

