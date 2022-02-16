#!/bin/bash
#Run enumSSH on all hosts in 22*.ips and all other ports identified as SSH services
#requires nse scripts installed. They are in /usr/share/nmap/scripts/*.nse (vulners)
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

mkdir enumSSH;
echo "Selecting ports identified as ssh services in the scan"
# Grep selects only ssh services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep ssh | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumSSH/sshports.txt

echo "####################################################################"
echo "Checking SSH servers on identified ports ..."

for port in $(cat ./enumSSH/sshports.txt); do
    filename=$port"_all_TCP.ips"
    cp ./results/$filename ./enumSSH
    numips=$(cat ./results/$filename | wc -l)
    echo "Running nmap scripts for SSH on port $port"
    sudo nmap -p $port --script ssh2-enum-algos,ssh-auth-methods,sshv1.nse -iL ./results/$filename -oA ./enumSSH/nmap_$port.txt

    echo -e "Running SSH check for each IP ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ipadd in $(cat ./results/$filename); do 
        echo "Testing SSH on $ipadd port $port "; 
        ssh -o "StrictHostKeyChecking no" -vN root@$ipadd 2>&1 | grep "remote software version" | tee enumSSH/enum$ipadd.txt
    done
done
