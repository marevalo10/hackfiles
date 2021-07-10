#!/bin/bash

#REQUIRED FOR INTERNAL / EXTERNAL PENTEST
echo "In case of problems with the display, run:"
echo "xrandr -s 1280x960 or xrandr -s 1680x1050"
echo "***********************************************************"
echo "Installing required software for INTERNAL / EXTERNAL tests"
echo "***********************************************************"
    # List all services listening and stop unnecesary:
    sudo netstat -tulpn > services.txt
    #sudo openvas-stop
    #sudo service postgresql stop
# Updating
echo "******************************************************"
    sudo apt-get update
# Installing seclists:
echo "******************************************************"
    sudo apt-get install seclists
# Download and install Teamviewer to complete any graphical part:
echo "******************************************************"
echo "Installing and configuring TeamViewer"
    #wget https://download.teamviewer.com/download/linux/teamviewer_i386.deb or _amd64
    #sudo apt install ./teamviewer_XXXX.deb
    sudo apt-get install teamviewer
    sudo systemctl status teamviewerd.service
    sudo teamviewer passwd r3m0t3@2021
    # Enabling it permanently
    sudo systemctl status teamviewerd.service
    sudo systemctl enable teamviewerd.service 
    # Starting the deamon (start / stop / status)
    sudo systemctl stop teamviewerd.service
    sudo systemctl start teamviewerd.service
    sudo teamviewer --info > teamviewer.info
    # Configure TeamViewer Account
    echo "Include the details of the TeamViewer Account (@1st D) / If required"
    # Remove this line if it will a installation in a remote not-owned server
    #sudo teamviewer setup
    # Include this line  if it will a installation in a remote not-owned server
    #
    sudo systemctl restart teamviewerd.service
    sudo systemctl status teamviewerd.service
    #sudo teamviewer --daemon restart
    sudo teamviewer --info
        #sudo vi /opt/teamviewer/config/global.conf
            #Add these lines at the end:
            #[int32] EulaAccepted = 1
            #[int32] EulaAcceptedRevision = 6
        #export DISPLAY=:0; nohup iceweasel &>/dev/null &
    #Permissions: https://community.teamviewer.com/t5/Knowledge-Base/Which-ports-are-used-by-TeamViewer/ta-p/4139
    # TCP and UDP port 5938 output  to any IP (teamviewer has many IP’s segments or if possible *.teamviewer.com)
    # TCP output to 443 to any IP
echo "If no 1st account configured, take note of the TV ID" 

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

# Sn1per:
echo "******************************************************"
echo "Installing Sn1per"
    mkdir ~/Downloads
    cd ~/Downloads
    git clone https://github.com/1N3/Sn1per.git
    cd Sn1per
    # To investigate: why it install metasploit if it is alrady installed! It could cause problems
    sudo bash install.sh
    cd ~/Downloads
    sudo rm -R Sn1per

# Update Metasploit:
echo "******************************************************"
echo "Updating Metasploit"
sudo apt update; sudo apt install metasploit-framework


#REQUIRED FOR INTERNAL PENTEST
echo "******************************************************"
echo "Installing required software for internal tests"
echo "******************************************************"
echo "By default, responder is in /usr/share/Responder.py"
    FILE=/usr/share/Responder.py
    if test -f "$FILE"; then
        echo "$FILE exists!! :)"
    elif
        wget https://github.com/lgandx/Responder/archive/refs/heads/master.zip --no-check-certificate -O responder.zip
    fi
echo "******************************************************"
echo "Downloading PCredz"
    wget https://github.com/lgandx/PCredz/archive/refs/heads/master.zip --no-check-certificate -O pcredz.zip
	unzip pcredz.zip
	sudo rm pcredz.zip
	#Transfer the python-libpcap to the system and install it
    wget http://mirrors.kernel.org/ubuntu/pool/universe/p/python-libpcap/python-libpcap_0.6.4-1_amd64.deb -O python-libpcap_0.6.4-1_amd64.deb
	sudo apt-get install ./python-libpcap_0.6.4-1_amd64.deb
	#If this didn't work then:
	#sudo dpkg -i ./python-libpcap_0.6.4-1_amd64.deb
    echo "To run PCredz: cd PCredz-master; sudo ./Pcredz -i eth0 -v"

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
echo "To run the ftp server: python3 -m pyftpdlib -w"
	#python3 -m pyftpdlib -w
    #Or it can be used Metasploit ftp: auxiliary/server/ftp
	#set FTPROOT /home/marevalo

echo "******************************************************"
echo "Install VNC "
    # Just in case
	sudo apt-get install x11vnc
	

echo "******************************************************"
echo "Install / Update and setup openvas => now called gvm (If required to run Vuln Scans. Require 6 to 10GB):"
    #Pending to update
    sudo apt-get install python3-tornado
	sudo apt-get install gvm*
    echo "Configuring GVM.... Could take TIME and requieres internet connection"
    sudo gvm-setup
    echo "******************************************************"'
    echo "If this process fails, follow instructions to change postgresqlv12 and postgresqlv13 ports: https://community.greenbone.net/t/gvm-install-setting-on-kali-linux-2020-3/7298/6"
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    echo "              TAKE NOTE OF THE PASSWORD!"
	echo "To start GVM run: gvm-start"
    echo "******************************************************"
    #gvm-start

echo "******************************************************"
echo "Download and install impacket: (if not is installed yet)"
	git clone https://github.com/SecureAuthCorp/impacket.git
    cd impacket
	pip3 install .
	pip3 install tox 
    #This programs are installed in /home/marevalo/.local/bin that are not in the path

echo "******************************************************"
echo "Install / run armitage: (if not is installed yet)"
	sudo apt-get install armitage
	sudo msfdb init
	# Armintage ready to tun
    echo "To run armintage use the graphical interface or run sudo -E armitage"

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
	
	
echo "**************************************************************************************"
echo "Download and install CrackMapExec (if not is installed yet - Post-exploitation tool ):"
	sudo apt-get install crackmapexec
	
	# Another way if this is not working:
	#	sudo apt-get install -y libssl-dev libffi-dev python-dev build-essential
	#	pip install --user pipenv
	#	git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec
	#	cd CrackMapExec 
	#	pipenv install     #-> Virtualenv location: /home/miguel/.local/share/virtualenvs/CrackMapExec-rvnRT-5V
	#	pipenv shell
	#	python setup.py install

echo "****************************************************************************************"
echo "Download and install Portia: (Useful when you capture / get access to users credentials)"
    #Details in https://github.com/SpiderLabs/portia however it is not working properly, so run in this order:
	### ./install is not working properly so these are the steps to configure it:
	sudo apt-get install -y autoconf automake autopoint libtool pkg-config freetds-dev 
	pip install pysmb tabulate termcolor xmltodict pyasn1 pycrypto pyOpenSSL dnspython netaddr python-nmap
	cd ~/Downloads
	git clone https://github.com/libyal/libesedb.git
	cd libesedb/
	./synclibs.sh
	./autogen.sh
	./configure 
	make
	sudo make install
	sudo ldconfig
	cd ..
	git clone https://github.com/csababarta/ntdsxtract && cd ntdsxtract
	sudo python setup.py install
	pip install "pymssql<3.0"   
    pip3 install "pymssql<3.0"
	#pip install git+https://github.com/pymssql/pymssql.git -> no funcionó
	cd ..
	git clone https://github.com/volatilityfoundation/volatility && cd volatility
	sudo python setup.py install
	cd ..

	#Now install portia
    cd /opt
	sudo git clone https://github.com/SpiderLabs/portia.git && cd portia
	sudo git submodule init && sudo git submodule update --recursive
    echo "****************************************************************************************"
	echo "#### Edit file deps/goldenPac.py and modify lines 46 and 47 to this:"
	echo "	from impacket.dcerpc.v5.lsad import hLsarQueryInformationPolicy2, hLsarOpenPolicy2, POLICY_INFORMATION_CLASS"
	echo "	from impacket.dcerpc.v5.lsat import MSRPC_UUID_LSAT, POLICY_LOOKUP_NAMES"
    echo "****************************************************************************************"
	sudo ln -s /opt/portia/portia.py /usr/bin/
	#Link it to /user/bin or any other global path
	#USAGE:
	#	Create a file with the IPS target (ips.txt)
	#	portia.py -d DOMAIN -u USER -p PASS IP 

echo "****************************************************************************************"
echo "Download and Install Free RDP (if not is installed yet). This is used to some pth attacks to rdp"
	sudo apt-get install freerdp2-x11
	#Use it to Pass the hash if any is available:
	#	xfreerdp /u:admin /d:[domain] /pth:[hash:hash] /v:192.168.1.101
	#	xfreerdp /u:admin /pth:aad3b435b51404eeaad3b435b51404ee:aedcbf154ddab484bc8b96d02d433d5f /v:10.4.32.36

	
		
echo "****************************************************************************************"
echo "Download and Install Empire -> Use it in combination with Responder to get credentials (NTLM / SMB / …) and automatically try PTH to get some sessions: -> Check now Empire 3.0 https://github.com/BC-SECURITY/Empire and how to evade: https://www.mike-gualtieri.com/posts/modifying-empire-to-evade-windows-defender"
	sudo apt install powershell-empire
	echo "Note: Run ./setup/reset.sh before starting Empire 3.1 for the first time."
	# Empire (To validate in the clear machine)
    ~/Downloads
	git clone https://github.com/EmpireProject/Empire
	cd Empire/setup
	sudo pip install -r requirements.txt
	echo "Edit install.sh and replace libssl….8u7_amd64…. To 8u8"
	sudo ./install.sh 
	#Pass: 3mp1r3_2021
    #Move empire to /usr/bin and create a batch to run it
	sudo mv ~/Downloads/Empire /usr/bin
	cd /usr/bin
	#Creates a script to run empire)
	echo '#!/bin/bash' | sudo tee -a empire
	echo 'cd /usr/bin/Empire; sudo ./empire' | sudo tee -a empire
	sudo chmod +x /usr/bin/empire

	echo "To run empire server:" 
	echo "/usr/bin/empire"
    echo "To connecto to the server:"
	echo "sudo python empire --rest --username empireadmin --password 'XXXXXXX'"
	echo "If it didn't work, then:"
	echo "cd setup;	sudo ./reset.sh  (I run it because it was not working ant it start working automatically)"
	echo "#Install additional required libraries if it is still not working
		sudo pip install pefile
		sudo pip install empire
		sudo pip install helpers"
	
	
			
echo "****************************************************************************************"
echo "Download and Install DeathStar (When you have credentials to try to get lateral movement):"
echo "It could be dangerous as it will try automatically to inject code and AV could detect it" 
	# DeathStar
    #cd ~/Downloads; git clone https://github.com/byt3bl33d3r/DeathStar
	# Death Star is written in Python3
    #cd DeathStar; pip3 install -r requirements.txt

echo "****************************************************************************************"
echo "If required a SMB server use impacket SMB:
	python smbserver.py ROPNOP /mydir/mysubdir
	To connect from other linux: smbclient -L IP --no-pass
	Or net view \\IP     -> from windows
	dir \\IP\ROPNOP
	copy \\IP\ROPNOP\file.exe"
	
#IMPORTANT! Have a vulnerability scanner installed and updated (OpenVAS, Nessus, NMAP)

sudo apt autoremove

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
