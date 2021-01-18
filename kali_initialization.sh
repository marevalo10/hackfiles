#!/bin/bash
#Shell:
sudo apt-get update
# These sometimes cause the system to fail…. It is better to download an updated version from Kali
#apt-get upgrade 
#apt-get dist-upgrade


echo "Changing kali default password"
sudo passwd kali
echo "Creating new user and adding it to sudoers (marevalo)" 
sudo useradd marevalo -m
echo "Define a password for new user"
sudo passwd marevalo
sudo usermod -a -G sudo marevalo
sudo chsh -s /bin/bash marevalo
echo "If marevalo has no access to sudoers try doing logout and connecting againg"
# It fails but I didn't know at the end the issuse. maybe because I didn't logout and enter again. Finally, I copy almost the same line in the passwd for kali user to marevalo

#Housekeeping
#Check running services and take note of them
echo "List of running services"
sudo netstat -tulpn

echo "Disabling root login"
echo "By adding this line:  PermitRootLogin no"
echo 'PermitRootLogin no' | sudo tee -a  /etc/ssh/sshd_config
echo "Adding user to let it SSH"
echo "By adding this line:  AllowUsers marevalo,kali"
echo 'AllowUsers marevalo,kali' | sudo tee -a  /etc/ssh/sshd_config

echo 'Cleaning ssh'
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo service ssh restart
echo "#Turning SSH to run after restarts"
sudo systemctl enable ssh

echo "Downloading and Installing important dotfiles"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip
unzip  dotfiles_mod.zip
cd dotfiles
./install.sh
cp -R tmux-logging ~/
cd ..

echo "#Downloading recon scripts"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/scripts_recon.zip
unzip scripts_recon.zip
echo "Copying the tmux logging files to ~/tmux-logging"
