#!/bin/bash
# Usage: 
#       sudo ./8_vulnSCAN-udp_new.sh
# No parameters are required as it will use the results from preparefiles script
# VULNSCAN check for common UDP vulnerabilities on the identified IP and ports
# preparefiles_new.sh must be run first for each file used to run resumenmap-udp
# Script uses file ./results/all_portsbyhosUDP.csv to get IP's and ports
# TODO: Check https://github.com/scipag/vulscan to include this scan?
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
#file=ips.txt
results="results"
focused="focused"
udpfile="$results/all_portsbyhostUDP.csv"  # Info about IP and UDP openports on each line: IP port1,port2,...,portx
#Root if it is through sudo
username=$(whoami)
#Real user
user=$((who am i) | awk '{print $1}');
startpoint=1
logfile="./$focused/_results_scanUDP.log"

# Checks if the user is root (sudo)
if [[ "$EUID" != 0 ]]; then
        echo "$username, please run it as sudo $0";
        exit 0;
fi
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

# It will read $udpfile line by line and start the scan based on $1 (IP) and ports ($2)
echo -e ""
echo -e "############################################################################################################################" | tee -a $logfile
echo -e "                                           NMAP VULNERABILITY FOCUSED SCAN UDP" | tee -a $logfile
echo -e "If the scan stops by any reason, just delete lines already completed from file ${GREEN}$udpfile${NC} and restart the program" | tee -a $logfile
echo -e "File ${GREEN}$logfile${NC} keeps a record of the scanned IP's" | tee -a $logfile
echo -e "Results will be stored in drectory ${GREEN}./$focused${NC} files IP_vulnscan*" | tee -a $logfile
echo -e "############################################################################################################################" | tee -a $logfile
n=` cat $udpfile | wc -l`
for((i=$startpoint;i<=$n;i++)); do 
    line=`awk FNR==$i $udpfile`
    ipadd=`echo $line | awk '{ print $1 }'`
    uports=`echo $line | awk '{ print $2 }'`
    echo -e "Scanning IP ${GREEN}$ipadd${NC}..." | tee -a $logfile
    echo "UDP Ports: $Uports"  | tee -a $logfile
    outfile="./$focused/"$ipadd"_vulnscanUDP"
    echo "Command to be run: nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -sU -O --script=default,auth,vuln,version --open --version-intensity 0 --script-timeout 5m -vvv -oA $outfile --max-rate 700 --privileged -p U:$uports $ipadd"  | tee -a $logfile
    timeout 5m nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -sU -O --script=default,auth,vuln,version --open --version-intensity 0 --script-timeout 1m -vvv -oA $outfile --max-rate 700 --privileged -p "U:"$uports $ipadd; 
    echo -e "${GREEN}############################################################################################################################${NC}"  | tee -a $logfile
    echo -e "IP ${GREEN}$ipadd${NC} scanned!  ($i out of $n)" | tee -a  $logfile 
    echo -e "${GREEN}############################################################################################################################${NC}"  | tee -a $logfile

done
echo ""
echo ""
echo "Checking for SNMP open on systems ..."  | tee -a $logfile
echo -e "${GREEN}############################################################################################################################${NC}"  | tee -a $logfile
mkdir enumSNMP;
# Grep selects only ssh services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"161\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumSNMP/snmp.txt
echo "Running command: nmap -sU -p 161 -Pn-sV -sC --max-hostgroup 16 -iL ./enumSNMP/snmp.txt -oA ./enumSNMP/snmpall" | tee -a $logfile
timeout 15m nmap -sU -p 161 -Pn-sV -sC --max-hostgroup 16 -iL ./enumSNMP/snmp.txt -oA ./enumSNMP/snmpall
#nmap -sU -p 161 --script snmp-brute 127.0.0.1 --script-args snmp-brute.communitiesdb=/home/sam/comstring.txt
echo -e "${GREEN}############################################################################################################################${NC}"| tee -a $logfile
echo "Checking for SNMP using snmp-check on systems ..."| tee -a $logfile
echo -e "${GREEN}############################################################################################################################${NC}"| tee -a $logfile
numips=$(cat ./enumSNMP/snmp.txt|wc -l)
n=1
for ip in $(cat ./enumSNMP/snmp.txt); do 
    filename=$ip"_snmp.txt"
    snmp-check $ip > ./enumSNMP/$filename
    echo -e "SNMP check Completed for IP ${GREEN}$ip${NC}!  ($n out of $numips)" | tee -a  $logfile
    echo -e "${GREEN}############################################################################################################################${NC}" | tee -a  $logfile
    n=$(($n+1))
done

chown -R $user:$user *

echo "Printing out what systems were identified using vulnerable services"  | tee -a  $logfile
#grep --include=\*.{nmap,other} -rnw ./focused -e "CVE" > ./focused/vulnsystemsUDP.txt
grep --include=\*UDP.nmap -rnw './'$focused -e "CVE" |grep -v "avahi"  | tee -a  $logfile | tee ./$focused/vulnsystemsUDP.txt
#lines=`wc -l ./$focused/vulnsystemsUDP.txt`
cat ./$focused/vulnsystemsUDP.txt|awk '{print $1}' |sed 's/\(.\+\/\)\(.\+_\)\(.\+\)/\2/g'|sed 's/_//g' |sort|uniq > ./$focused/vulnsystemsUDP_ips.txt
totalips=$( cat ./$focused/vulnsystemsUDP_ips.txt |wc -l )
echo -e "Vulnerable IPs were saved in file ${GREEN}./$focused/vulnsystemsUDP_ips.txt${NC}" | tee -a  $logfile
echo "Total IPs: $totalips" |tee -a ./$focused/vulnsystemsUDP_ips.txt  | tee -a  $logfile
echo -e "File including summary of vulns is located in ${GREEN}./$focused/vulnsystemsUDP.txt${NC}"  | tee -a  $logfile
echo -e "File with list of IP's found vulnerables in the file: ${GREEN}./$focused/vulnsystemsUDP_ips.txt${NC}" | tee -a  $logfile
echo -e "A total of ${RED}$totalips${NC} where found vulnerable" | tee -a  $logfile
echo -e "Script vulnSCAN-udp finished successfully" | tee -a  $logfile
echo -e "############################################################################################################################" | tee -a  $logfile
