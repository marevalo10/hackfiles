#!/bin/bash
# VULNSCAN
# preparefiles.sh must be run first
# Original:
# for((i=1;i<=` cat ips.txt.resumenmap-tcp.openports.csv | wc -l` ;i++)); do awk FNR==$i ips.txt.resumenmap-tcp.openportsPTV.csv| grep -o  -E "\b[0-9]{1,5}/open"  | sed 's/\/open//g' | awk -vORS=, '{ print  }'  > focused/portsPTV.line.$i    ;  done
# Review each line of the raw file to extract the ports to scan for each IP
#create a file with identified open ports by line
#for((i=1;i<=` cat ips.txt.resumenmap-tcp.openports.csv | wc -l` ;i++)); do awk FNR==$i ips.txt.resumenmap-tcp.openports.csv| grep -o  -E "\b[0-9]{1,5}/open"  | sed 's/\/open//g' | awk -vORS=, '{ print  }'  > focused/ports.line.$i    ;  done
#Runing a focused VULNERABILITY SCAN (nmap scripts) to all hosts with specific identified open ports by resumenmap.sh
#j=0; for i in $(cat ips.txt.resumenmap-tcp.hosts.csv); do echo "Scaning $i in line $j"; echo "incrementing $((j++))"; nmap $i -p `cat focused/ports.line.$((j++))` -R  -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -O --script=default,auth,vuln,version --open -vvv -oA focused/.$j.vuln-scan.$i --min-rate 500 --max-rate 700 --privileged ; done

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
#file=ips.txt
results="results"
focused="focused"
udpfile="$results/all_portsbyhostUDP.csv"  # Info about IP and UDP openports on each line: IP port1,port2,...,portx
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
echo -e "############################################################################################################################"
echo -e "                                           NMAP VULNERABILITY FOCUSED SCAN UDP"
echo -e "If the scan stops by any reason, just delete lines already completed from file ${GREEN}$udpfile${NC}and restart the program"
echo -e "File ${GREEN}./$focused/scanudp.log${NC} keeps a record of the scanned IP's"
echo -e "Results will be stored in drectory ${GREEN}./$focused${NC} files IP_vulnscan*"
echo -e "############################################################################################################################"
n=` cat $udpfile | wc -l`
for((i=1;i<=$n;i++)); do 
    line=`awk FNR==$i $udpfile`
    ipadd=`echo $line | awk '{ print $1 }'`
    uports=`echo $line | awk '{ print $2 }'`
    echo "IP: "$ipadd" Ports: $uports \nFile: $udpfile Line: "$line"  "
    echo -e "Scanning IP ${GREEN}$ipadd${NC}..."; echo "Scanning IP $ipadd AND PORTS: $Uports" >> ./$focused/scanudp.log
    outfile="./$focused/"$ipadd"_vulnscanUDP"
    echo "Command to be run: sudo nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -O --script=default,auth,vuln,version --open -vvv -oA $outfile --max-rate 700 --max-hostgroup 64 --privileged -p "U:"$uports $ipadd"
    sudo nmap -R -PE -PP -Pn --source-port 53 --traceroute --reason -sV -A -sC -sU -O --script=default,auth,vuln,version --open -vvv -oA $outfile --max-rate 700 --max-hostgroup 64 --privileged -p "U:"$uports $ipadd ; 
    echo -e "IP ${GREEN}$ipadd${NC} scanned!"; echo "IP $ipadd scanned!" >> ./$focused/scanudp.log
done

echo "####################################################################"
echo "Checking for snmp open systems ..."
mkdir enumSNMP;
# Grep selects only ssh services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"161\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumSNMP/snmp.txt
sudo nmap -sU -p 161 -Pn-sV -sC -iL ./enumSNMP/snmp.txt -oA ./enumSNMP/snmpall
#nmap -sU -p 161 --script snmp-brute 127.0.0.1 --script-args snmp-brute.communitiesdb=/home/sam/comstring.txt
for ip in $(cat ./enumSNMP/snmp.txt); do 
    filename=$ip"_snmp.txt"
    snmp-check $ip > ./enumSNMP/$filename
    echo "SNMP check Completed for IP: $ip"; 
done

#Print out what files identified vulnerable services -r recursive -n print line number -w whole word
#grep --include=\*.{nmap,other} -rnw ./focused -e "CVE" > ./focused/vulnsystemsUDP.txt
grep --include=\*UDP.nmap -rnw './'$focused -e "CVE" > ./$focused/vulnsystemsUDP.txt
lines=`wc -l ./$focused/vulnsystemsUDP.txt`
echo -e "File including summary of vulns is located in ${GREEN}./$focused/vulnsystemsUDP.txt${NC}. Lines in the file: ${RED}$lines! ${NC}"
echo -e "Script vulnSCAN-udp finished successfully"
echo -e "############################################################################################################################"
