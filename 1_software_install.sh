#!/bin/bash

#TODO
# ADD THE TIME TO THE PROMPT AGAIN
# ADD /home/$username/go/bin TO THE PATH

#Install GO / Golang
sudo apt -y install gccgo-go

#REQUIRED FOR INTERNAL / EXTERNAL PENTEST
echo "In case of problems with the display, run:"
echo "xrandr -s 1280x960 or xrandr -s 1680x1050"
echo "***********************************************************"
echo "Installing required software for INTERNAL / EXTERNAL tests"
echo "******************************************************"
echo "Installing python-pip 3 (2 is no longer supported)"
	#sudo apt install python-pip
	sudo apt -y install python3-pip 
echo "Install pipenv: (some programs require it)"
	sudo apt-get -y install pipenv    
echo "Install virtualenv:"
	sudo apt-get -y install python3-virtualenv
echo "Install python FTP to facilitate files exchange when required:"
	pip3 install pyftpdlib
echo "To run the ftp server: python3 -m pyftpdlib -w
    Or it can be used Metasploit ftp: auxiliary/server/ftp
	set FTPROOT /home/marevalo"

echo "***********************************************************"
    # List all services listening and stop unnecesary:
    sudo netstat -tulpn > ~/services.txt
# Updating
echo "******************************************************"
    sudo apt-get update
# Installing seclists:
echo "******************************************************"
    sudo apt-get -y install seclists
#REQUIRED FOR EXTERNAL PENTEST
echo "******************************************************"
echo "Installing required software for external tests"
echo "******************************************************"
# thc-ipv6 (not installed by default): to run IPv6 tests: 
echo "******************************************************"
echo "Installing thc-ipv6"
sudo apt-get install -y libpcap-dev libssl-dev libnetfilter-queue-dev
cd ~/Downloads
git clone https://github.com/vanhauser-thc/thc-ipv6.git
cd thc-ipv6; sudo make all; sudo make install
cd ..; sudo rm -R thc-ipv6

# Metagoofil -> to look for documents in the website. 
echo "******************************************************"
echo "Installing metagoofil"
sudo apt-get -y install metagoofil

# Update Metasploit:
echo "******************************************************"
echo "Updating Metasploit"
sudo apt -y install metasploit-framework

#Install wayback machine
echo "******************************************************"
echo "Installing WayBack Machine"
echo "******************************************************"
    go install github.com/tomnomnom/waybackurls@latest
    export PATH=$PATH:~/go/bin/
    source ~/.zshrc

echo "******************************************************"
echo "Installing Webtools"
echo "******************************************************"
    sudo apt install -y feroxbuster
    sudo apt install -y eyewitness

#Subdomain takeover tools
echo "******************************************************"
echo "Installing Subdomain takeover tools"
echo "******************************************************"
    #Nuclei:
    sudo apt-get -y install nuclei 
    #Get the templates (installed in ~/.local/nuclei-templates
    nuclei update-templates
    #Subzy
    go install -v github.com/LukaSikic/subzy@latest
    # Install httprobe amd httpx
    sudo apt -y install httprobe
    GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    #Install dnsprobe:https://github.com/projectdiscovery/dnsprobe
    GO111MODULE=on go install -v github.com/projectdiscovery/dnsprobe@latest
    #It is installed in ~/go/bin/dnsprobe
    #Install subjack:
    sudo apt -y install subjack
    sudo apt -y install assetfinder
    sudo apt -y install sublist3r

# Sn1per:   => It installs and configure a lot of python packages and a different version of metasploit
# This could affect other programs! => it is better to use it in Docker
echo "******************************************************"
echo "Installing Sn1per"
#   mkdir ~/Downloads
#    cd ~/Downloads
#    git clone https://github.com/1N3/Sn1per.git
#    cd Sn1per
    # To investigate: why it install metasploit if it is alrady installed! It could cause problems
#    sudo bash install.sh
#    cd ~/Downloads
#    sudo rm -R Sn1per
    #temporarily disable as it is installig many things and causing machines to crash in some times afer installation.....
    cd ~/Downloads
    git clone https://github.com/1N3/Sn1per
    cd Sn1per; sudo ./install.sh


#REQUIRED FOR INTERNAL PENTEST
echo "******************************************************"
echo "Installing required software for internal tests"
echo "******************************************************"

echo "Installing Impacket. All programs should be run as impacket-xxx. i.e. impacket-psexec"
sudo apt install -y python3-impacket
echo "Run commands by using impacket-xxnamexx"
echo "Installing remmina"
sudo apt install -y remmina

echo "****************************************************************************************"
echo "Installing Active Directory Tools"
echo "****************************************************************************************"
sudo apt -y install curl gnupg apt-transport-https
#Powershell
sudo "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/powershell.list
sudo apt -y install powershell
echo "Run powershell using pwsh command"
# Install AD tools
#This is the graph tool. It includes neo4j in case it is not installed.
sudo apt install -y bloodhound neo4j
#This install the collector to extract the AD information from a domain controller
# To run it: bloodhound-python -u <domainuser> -p <domianpwd> -ns <dc ip or name> -d <domainname.local> -c All
pip3 install bloodhound
# Bruteforcing with Kerberos is stealthier since pre-authentication failures do not trigger An account failed to log on event 4625
go install github.com/ropnop/kerbrute@latest 
sudo apt install -y kerberoast
sudo apt install -y krb5-user
sudo apt -y install kerberoast
sudo apt install -y evil-winrm
#sudo gem install evil-winrm
#Download Kekeo zip
wget https://github.com/gentilkiwi/kekeo/releases/download/2.2.0-20211214/kekeo.zip
mkdir kekeo; 
unzip kekeo.zip -d kekeo
#To create rogue LDAP servers. Start it by sudo systemctl enable slapd. Ask for a password
#Reconfigure it by sudo dpkg-reconfigure -p low slapd
echo "Installing a rogue LDAP tool. Should configure a password (Abcd1234)"
sudo apt-get -y install slapd ldap-utils

#Install CIFS
sudo apt install -y cifs-utils

echo "******************************************************"
echo "Downloading PCredz"
    sudo apt-get -y install libpcap-dev && pip3 install Cython && pip3 install python-libpcap
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
	sudo apt-get -y install armitage
	sudo msfdb init
	# Armintage ready to tun
    echo "To run armintage use the graphical interface or run sudo -E armitage"

echo "******************************************************"
echo "Installing webtools "
sudo apt install -y feroxbuster



#echo "****************************************************************************************"
echo "Download and Install Free RDP (if not is installed yet). This is used to some pth attacks to rdp"
	sudo apt-get -y install freerdp2-x11
	#Use it to Pass the hash if any is available:
	#	xfreerdp /u:admin /d:[domain] /pth:[hash:hash] /v:192.168.1.101
	#	xfreerdp /u:admin /pth:aad3b435b51404eeaad3b435b51404ee:aedcbf154ddab484bc8b96d02d433d5f /v:10.4.32.36

echo "****************************************************************************************"
echo "Download and Install Empire -> Use it in combination with Responder to get credentials (NTLM / SMB / …) and automatically try PTH to get some sessions: -> Check now Empire 3.0 https://github.com/BC-SECURITY/Empire and how to evade: https://www.mike-gualtieri.com/posts/modifying-empire-to-evade-windows-defender"
    sudo apt -y install powershell-empire
	
			
echo "****************************************************************************************"
echo "Download and Install DeathStar (When you have credentials to try to get lateral movement):"
echo "It could be dangerous as it will try automatically to inject code and AV could detect it" 
	# DeathStar
    #cd ~/Downloads; git clone https://github.com/byt3bl33d3r/DeathStar
    #python3 -m pip install --user pipx
    sudo apt install pipx
    pipx install deathstar-empire

echo "****************************************************************************************"
echo "If required a SMB server use impacket SMB:
	python smbserver.py ROPNOP /mydir/mysubdir
	To connect from other linux: smbclient -L IP --no-pass
	Or net view \\IP     -> from windows
	dir \\IP\ROPNOP
	copy \\IP\ROPNOP\file.exe"

echo "******************************************************"
    echo "Install MINGW AND WIN EMULATOR WINE"
    sudo apt -y install mingw-w64
    echo "Use: i686-w64-mingw32-gcc 42341.c -o syncbreeze_exploit.exe"
    sudo apt-get -y install wine
    

echo "Installing  rust"
	wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb
    sudo dpkg -i  rustscan_2.0.1_amd64.deb
    rm rustscan_2.0.1_amd64.deb
    sudo rustscan -a 127.0.0.1
    sudo apt-get -y install amass


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

#Update searchsploit. The bad think is it install all documents that are so big
#searchsploit -u

#To analyse webpages
sudo apt -y install html2text

#Recon Framework https://github.com/six2dez/reconftw recommended by Jhaddix https://www.jhaddix.com/post/the-anti-recon-recon-club-using-reconftw
git clone https://github.com/six2dez/reconftw
cd reconftw/
./install.sh

#Usage: ./reconftw.sh -d target.com -r

#Clean packages
sudo apt -y autoremove

#########################################################################################
# END OF SCRIPTS
#########################################################################################
##（Optional） Download and install Cisco Anyconnect (when needed to connect to a VPN)
#	sudo apt install network-manager-openconnect
#	sudo systemctl daemon-reload
#	I downloaded vpnsetup.sh 
#	sudo ./vpnsetup.sh
#	alias vpn='/opt/cisco/anyconnect/bin/vpn'
#	alias vpnui='/opt/cisco/anyconnect/bin/vpnui'
#	cat >> ~/.bash_aliases
#		alias vpn='/opt/cisco/anyconnect/bin/vpn'
#		alias vpnui='/opt/cisco/anyconnect/bin/vpnui'
#	sudo apt install libpangox-1.0-0


#ALREADY COMES: IN KALI 2021.2
# Installing masscan: 
#echo "******************************************************"
#    sudo apt-get install masscan


#echo "******************************************************"
#echo "Download and install nessus (Require license -> If you don’t have, only 10 IP's are permitted when you are registered. Requires 6 to 10GB):"
	#Download the package from nessus page or transfer it to the kali
    #cd  ~/Downloads
    #Download the latest amd64.deb file from https://www.tenable.com/downloads/nessus?loginAttempted=true
	#sudo dpkg -i  Nessus-8.XX.Y-debian6_amd64.deb
        ## Ejecutas los siguientes comandos en el Kali
        #sudo /etc/init.d/nessusd stop
        #sudo /opt/nessus/sbin/nessuscli fix --reset
        #
        ## Aqui pones la licencia que tengas del Nessus Pro, debes asegurarte que lo tengas detenido en cualquier otra instalacion que tengas. De otro modo detectaran que la licencia ya esta en uso.
        ## El Kali debe tener acceso a Internet para descargar los plugins y registrar la licencia.
        #sudo /opt/nessus/sbin/nessuscli fetch --register XXXX-XXXX-XXXX-XXXX
        ## Recuerda al final del pentest borrar este comando del historial de comandos para que no quede tu licencia ahí jejeje.
        ## Ojo con el espacio en disco del Kali, porque se descargaran los plugins del Nessus que pesan aproximagamente 6.5 Gb, este comando es el mas tardado.
        #sudo /opt/nessus/sbin/nessusd -R
        ## Inicias el Nessus
        # sudo systemctl start nessusd
        #
        ## Ya que esta instalado, creas un usuario.
        #sudo /opt/nessus/sbin/nessuscli adduser
        # marevalo igual al OS
        #sudo /opt/nessus/sbin/nessuscli lsuser
        #
        ## Listo ya debes tener el servicio escuchando en el puerto 8834
        #netstat -tapn | grep LISTEN
        #
        ## Si tu Kali es remoto y solo tienes acceso por SSH ...
        ## Esto lo ejecutas desde tu equipo local ...
        ## Para obtener acceso web a traves de SSH debes aplicar un forward del puerto, como sigue ...
        #ssh -L 0.0.0.0:8835:IPdelKALI:8834 user@IPdelKALI
        #
        ## Una vez que ya te conectaste por ssh, se debe haber creado un socket en tu equipo local escuchando en el puerto 8835, que en realidad apunta al 8834 del Kali.
        ## Asi que puedes abrir tu navegador y con la url https://localhost:8835 te debe dar acceso al Nessus instalado en el Kali.
        #
        ## ... Recuerda descargar reportes en todos los formatos, incluso los de formato nessus, para que puedas explorar los resultados en el otro Nessus importando esos reportes.
        #
        ## Cuando hayas terminado de usar el Nessus, en el Kali ejecuta lo siguiente para limpiar la instalacion y liberar la licencia ...
        #/etc/init.d/nessusd stop
        #/opt/nessus/sbin/nessuscli fix --reset
        #
        ## Respalda tus escaneos del nessus actual, no vaya a ser que pierdas tu historico de escaneos, ya me paso una vez jejeje.


	#sudo /etc/init.d/nessusd start
	#sudo service nessusd start
	# The scanner (host we are sending) requires (https://community.tenable.com/s/article/What-ports-are-required-for-Tenable-products):
	#		§ Port TCP/443 in / out to communicate with Tenable. We can use IP ranges specified in this link: https://docs.tenable.com/tenableio/vulnerabilitymanagement/Content/Settings/Sensors.htm. 
	#		§ Port TCP/8834 in / out to communicate  with Tenable
	#		§ An internal DNS to resolve names or access to an external DNS. UDP 53 out to 4.2.2.2, 4.3.3.3
	
#echo "******************************************************"
#echo "Install impacket: (if not is installed yet)" => already installed in Kali 2021.2
	#git clone https://github.com/SecureAuthCorp/impacket.git
    #cd impacket
	#pip3 install .
	#pip3 install tox 
    ##This programs are installed in /home/marevalo/.local/bin that are not in the path
    #pip install impacket

#echo "By default, responder is in /usr/share/Responder.py"
#    FILE=/usr/share/Responder.py
#    if test -f "$FILE"; then
#        echo "$FILE exists!! :)"
#    elif
#        wget https://github.com/lgandx/Responder/archive/refs/heads/master.zip --no-check-certificate -O responder.zip
#    fi
#echo "****************************************************************************************"
#echo "Download and install Portia: (Useful when you capture / get access to users credentials)"
#    #Details in https://github.com/SpiderLabs/portia however it is not working properly, so run in this order:
#	### ./install is not working properly so these are the steps to configure it:
#	sudo apt-get install -y autoconf automake autopoint libtool pkg-config freetds-dev 
#	pip install pysmb tabulate termcolor xmltodict pyasn1 pycrypto pyOpenSSL dnspython netaddr python-nmap
#	cd ~/Downloads
#	git clone https://github.com/libyal/libesedb.git
#	cd libesedb/
#	./synclibs.sh
#	./autogen.sh
#	./configure 
#	make
#	sudo make install
#	sudo ldconfig
#	cd ..
#	git clone https://github.com/csababarta/ntdsxtract && cd ntdsxtract
#	sudo python setup.py install
#	pip install "pymssql<3.0"   
#    pip3 install "pymssql<3.0"
#	#pip install git+https://github.com/pymssql/pymssql.git -> no funcionó
#	cd ..
#	git clone https://github.com/volatilityfoundation/volatility && cd volatility
#	sudo python setup.py install
#	cd ..
#
#	#Now install portia
#    cd /opt
#	sudo git clone https://github.com/SpiderLabs/portia.git && cd portia
#	sudo git submodule init && sudo git submodule update --recursive
#    echo "****************************************************************************************"
#	echo "#### Edit file deps/goldenPac.py and modify lines 46 and 47 to this:"
#	echo "	from impacket.dcerpc.v5.lsad import hLsarQueryInformationPolicy2, hLsarOpenPolicy2, POLICY_INFORMATION_CLASS"
#	echo "	from impacket.dcerpc.v5.lsat import MSRPC_UUID_LSAT, POLICY_LOOKUP_NAMES"
#    echo "****************************************************************************************"
#	sudo ln -s /opt/portia/portia.py /usr/bin/
#	#Link it to /user/bin or any other global path
#	#USAGE:
#	#	Create a file with the IPS target (ips.txt)
#	#	portia.py -d DOMAIN -u USER -p PASS IP 
#


#echo "**************************************************************************************"
#echo "Download and install CrackMapExec (if not is installed yet - Post-exploitation tool ):"
#	python3 -m pip install pipx
#    pipx ensurepath
#    pipx install crackmapexec

