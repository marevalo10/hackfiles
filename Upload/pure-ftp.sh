#!/bin/bash

#Install
sudo apt install pure-ftpd
#Configure
sudo groupadd ftpgroup 
#useradd -g ftpgroup -d /dev/null -s /etc ftpuser 
sudo useradd -g ftpgroup -d /dev/null ftpuser 
echo "Insert the password for the ftptestuser account:"
sudo pure-pw useradd ftptestuser -u ftpuser -d /ftphome   #password is requested
sudo pure-pw mkdb 
cd /etc/pure-ftpd/auth/ 
sudo ln -s ../conf/PureDB 60pdb 
sudo mkdir -p /ftphome 
sudo chown -R ftpuser:ftpgroup /ftphome/ 
systemctl restart pure-ftpd