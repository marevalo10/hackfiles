#!/bin/bash

#REQUIRED FOR INTERNAL / EXTERNAL PENTEST
echo "In case of problems with the display, run:"
echo "xrandr -s 1280x960 or xrandr -s 1680x1050"
echo "***********************************************************"
echo "Installing required software for INTERNAL / EXTERNAL tests"
echo "******************************************************"
echo "Installing python-pip 3 (2 is no longer supported)"
	#sudo apt install python-pip
	sudo apt install python3-pip 
echo "Install pipenv: (some programs require it)"
	sudo apt-get install pipenv    
echo "Install virtualenv:"
	sudo apt-get install python3-virtualenv
echo "Install python FTP to facilitate files exchange when required:"
	pip3 install pyftpdlib
echo "To run the ftp server: python3 -m pyftpdlib -w
    Or it can be used Metasploit ftp: auxiliary/server/ftp
	set FTPROOT /home/marevalo"

echo "***********************************************************"
    # List all services listening and stop unnecesary:
    sudo netstat -tulpn > services.txt
# Updating
echo "******************************************************"
    sudo apt-get update
# Installing seclists:
echo "******************************************************"
    sudo apt-get install seclists
#REQUIRED FOR EXTERNAL PENTEST
echo "******************************************************"
echo "Installing required software for external tests"
echo "******************************************************"
# thc-ipv6 (not installed by default): to run IPv6 tests: 
echo "******************************************************"
echo "Installing thc-ipv6"
sudo apt-get install libpcap-dev libssl-dev libnetfilter-queue-dev
cd ~/Downloads
git clone https://github.com/vanhauser-thc/thc-ipv6.git
cd thc-ipv6; sudo make all; sudo make install
cd ..; sudo rm -R thc-ipv6

# Metagoofil -> to look for documents in the website. 
echo "******************************************************"
echo "Installing metagoofil"
sudo apt-get install metagoofil

# Sn1per:   => It installs and configure a lot of python packages and a different version of metasploit
# This could affect other programs! => it is better to use it in Docker
#echo "******************************************************"
#echo "Installing Sn1per"
    #mkdir ~/Downloads
#    cd ~/Downloads
#    git clone https://github.com/1N3/Sn1per.git
#    cd Sn1per
    # To investigate: why it install metasploit if it is alrady installed! It could cause problems
#    sudo bash install.sh
#    cd ~/Downloads
#    sudo rm -R Sn1per

# Update Metasploit:
echo "******************************************************"
echo "Updating Metasploit"
sudo apt install metasploit-framework


#REQUIRED FOR INTERNAL PENTEST
echo "******************************************************"
echo "Installing required software for internal tests"
echo "******************************************************"
echo "******************************************************"
echo "Downloading PCredz"
    sudo apt-get install libpcap-dev && pip3 install Cython && pip3 install python-libpcap
    wget https://raw.githubusercontent.com/lgandx/PCredz/master/Pcredz
    chmod +x Pcredz
    sudo mv Pcredz /usr/bin
	#Transfer the python-libpcap to the system and install it
    #wget http://mirrors.kernel.org/ubuntu/pool/universe/p/python-libpcap/python-libpcap_0.6.4-1_amd64.deb -O python-libpcap_0.6.4-1_amd64.deb
	#sudo apt-get install ./python-libpcap_0.6.4-1_amd64.deb
	#If this didn't work then:
	#sudo dpkg -i ./python-libpcap_0.6.4-1_amd64.deb
    echo "To run PCredz: cd PCredz-master; sudo ./Pcredz -i eth0 -v"

#echo "******************************************************"
#echo "Install VNC " => Not required. I'll use xrdp
    # Just in case
	#sudo apt-get install x11vnc
	


echo "******************************************************"
echo "Install / run armitage: (if not is installed yet)"
	sudo apt-get install armitage
	sudo msfdb init
	# Armintage ready to tun
    echo "To run armintage use the graphical interface or run sudo -E armitage"

	



#echo "****************************************************************************************"
echo "Download and Install Free RDP (if not is installed yet). This is used to some pth attacks to rdp"
	sudo apt-get install freerdp2-x11
	#Use it to Pass the hash if any is available:
	#	xfreerdp /u:admin /d:[domain] /pth:[hash:hash] /v:192.168.1.101
	#	xfreerdp /u:admin /pth:aad3b435b51404eeaad3b435b51404ee:aedcbf154ddab484bc8b96d02d433d5f /v:10.4.32.36

echo "****************************************************************************************"
echo "Powershell"
    sudo apt -y install curl gnupg apt-transport-https
    sudo "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/powershell.list
    apt -y install powershell
    echo "Run powershell using pwsh command"
		
echo "****************************************************************************************"
echo "Download and Install Empire -> Use it in combination with Responder to get credentials (NTLM / SMB / …) and automatically try PTH to get some sessions: -> Check now Empire 3.0 https://github.com/BC-SECURITY/Empire and how to evade: https://www.mike-gualtieri.com/posts/modifying-empire-to-evade-windows-defender"
    sudo apt install powershell-empire
	
			
echo "****************************************************************************************"
echo "Download and Install DeathStar (When you have credentials to try to get lateral movement):"
echo "It could be dangerous as it will try automatically to inject code and AV could detect it" 
	# DeathStar
    #cd ~/Downloads; git clone https://github.com/byt3bl33d3r/DeathStar
    #python3 -m pip install --user pipx
    #pipx install deathstar-empire

echo "****************************************************************************************"
echo "If required a SMB server use impacket SMB:
	python smbserver.py ROPNOP /mydir/mysubdir
	To connect from other linux: smbclient -L IP --no-pass
	Or net view \\IP     -> from windows
	dir \\IP\ROPNOP
	copy \\IP\ROPNOP\file.exe"

echo "******************************************************"
    echo "Install MINGW AND WIN EMULATOR WINE"
    sudo apt install mingw-w64
    echo "Use: i686-w64-mingw32-gcc 42341.c -o syncbreeze_exploit.exe"
    sudo apt-get install wine
    

#IMPORTANT! Have a vulnerability scanner installed and updated (OpenVAS, Nessus, NMAP)
# UNCOMMENT THIS SECTION IF REQUIRED
#echo "******************************************************"
#echo "Install / Update and setup openvas => now called gvm (If required to run Vuln Scans. Require 6 to 10GB):"
#    #Pending to update
#    sudo apt-get install python3-tornado
#	sudo apt-get install gvm*
#    echo "Configuring GVM.... Could take TIME and requieres internet connection"
#    sudo gvm-setup
#    echo "******************************************************"'
#    echo "If this process fails, follow instructions to change postgresqlv12 and postgresqlv13 ports: https://community.greenbone.net/t/gvm-install-setting-on-kali-linux-2020-3/7298/6"
#    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
#    echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#    echo "              TAKE NOTE OF THE PASSWORD!"
#	echo "To start GVM run: gvm-start"
#    echo "******************************************************"
#    #gvm-start

searchsploit -u

sudo apt autoremove
