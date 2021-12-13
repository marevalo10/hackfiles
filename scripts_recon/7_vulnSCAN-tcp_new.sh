#!/bin/bash
# Usage: ./7_vulnSCAN-tcp_new.sh
# VULNSCAN check for common TCP vulnerabilities on the identified IP and ports
# No parameters are required as it will use the results from preparefiles script
# preparefiles_new.sh must be run first for each file used to run resumenmap-tcp
# Script uses file ./results/all_portsbyhostTCP.csv to get IP's and ports
# Important results will be left in file:
#   ./foucsed/vulnsystemsTCP.txt
# Each line contains the Filename containing possible vulnerabilites for each IP
# CHECK this file to validate possible vulnerabilities
# TODO: Check https://github.com/scipag/vulscan to include this scan?
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
results="results"
focused="focused"
# This file contains the info about IP and TCP openports on each line: IP port1,port2,...,portx,
# This is an example of a line: 10.99.88.77 80,443,515,9100,65001,65002,65003,65004,
tcpfile="$results/all_portsbyhostTCP.csv"  
echo "#################################################################################"

# Checks if the focused directory exists
if test -d $focused; then
    echo -e "Directory focused already exists.... If files exist there, they will be overwroten"
	read -p "Are you sure? (y|n): " -n 1 -r; echo -e "\n";
	if [[ $REPLY =~ ^[Yy]$ ]]; 	then
		echo -e "Overwriting files..."
	else
		echo -e "Execution cancelled..."
		exit 1
	fi
else 
	mkdir $focused
		echo -e "Results will be stored in ./$focused/"
fi

# This will read $tcpfile line by line and start the scan based on $1 (IP) and ports ($2)
echo -e ""
echo -e "############################################################################################################################"
echo -e "                                           NMAP VULNERABILITY FOCUSED SCAN TCP"
echo -e "If the scan stops by any reason, just delete lines already completed from file ${GREEN}$tcpfile${NC} and restart the program"
echo -e "File ${GREEN}./$focused/scantcp.log${NC} keeps a record of the scanned IP's"
echo -e "Results will be stored in drectory ${GREEN}./$focused${NC}"
echo -e "Files are called [IP]_vulnscanTCP"
echo -e "############################################################################################################################"

# Number of IP's to check
n=` cat $tcpfile | wc -l`
echo -e "Running nmap for ${RED}$n IP's{NC}"
for((i=1;i<=$n;i++)); do 
    # Extract the line $i from the file (ip port1,port2,...)
    line=`awk FNR==$i $tcpfile`
    #Extract the IP from the line and the ports
    ipadd=`echo $line | awk '{ print $1 }'`
    tports=`echo $line | awk '{ print $2 }'`
    echo "IP: $ipadd Ports: $tports \nFile: $tcpfile Line: "$line
    echo -e "Scanning IP ${GREEN}$ipadd${NC}..."; echo "Scanning IP $ipadd AND PORTS: $tports" >> ./$focused/scantcp.log
    outfile="./$focused/"$ipadd"_vulnscanTCP"
    echo "Command to be run: sudo nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -O --script=default,auth,vuln,version --open -vvv -oA $outfile --max-rate 700 --max-hostgroup 64 --privileged -p "T:"$tports $ipadd; "
    sudo nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -O --script=default,auth,vuln,version --open -vvv -oA $outfile --max-rate 700 --max-hostgroup 64 --privileged -p "T:"$tports $ipadd; 
    echo -e "IP ${GREEN}$ipadd${NC} scanned!"; echo "IP $ipadd scanned!" >> ./$focused/scantcp.log
done

#Print out what files identified vulnerable services -r recursive -n print line number -w whole word
#grep --include=\*.{nmap,other} -rnw ./focused -e "CVE" > ./focused/vulnsystemsTCP.txt
grep --include=\*TCP.nmap -rnw './'$focused -e "CVE\|VULNERABLE" > ./$focused/vulnsystemsTCP.txt
lines=`wc -l ./$focused/vulnsystemsTCP.txt`
echo -e "File including summary of vulns is located in ${GREEN}./$focused/vulnsystemsTCP.txt${NC}. Lines in the file: ${RED}$lines${NC}"
echo -e "Script vulnSCAN-tcp finished successfully"
echo -e "############################################################################################################################"
#find . -type f -exec grep -H 'CVE' {} \;
