#!/bin/bash
# SYNTAX: sudo ./1_evasiontechs.sh [-f filename]    by default it takes ips.txt as the source 
# This script attempts to bypass network controls to validate if a connection can be established to a non-reachable IP.
# To do so, the script first extract a list of hosts from the received file (ips.txt) and tries to check if it is reacheble using some evasion techniques
# Results are left in files evasiontech[x].$file
# More info: https://nmap.org/book/man-bypass-firewalls-ids.html


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
file=ips.txt
#Check if it is through sudo
username=$(whoami)
#Real user
user=$((who am i) | awk '{print $1}');
#Number of hosts to scan at the same time in nmap
maxhosts=16
numports=1000
udpports=200
#Modify this with local IP's in the network (-D decoy option)
SOURCEIPS="10.68.254.1,10.68.100.129,172.30.35.10,10.68.58.101,10.69.25.111"

if [[ "$EUID" != 0 ]]; then
        echo "$username, please run it as sudo $0";
        exit 0;
fi
startpoint=1


# First check input for paramaters
validate_parameters()
{
    while getopts "f:hAVS" opt; do
        case $opt in
        # f to receive the file name to use as input for the ips to scan
        f)  #echo "-f was triggered, Parameter: $OPTARG" >&2
            file=$OPTARG;
            #Target file provided exists AND it's size is > 0?
            if test -s "$file"
            then
                #Read number of lines of target files
                limit=$(cat $file | wc -l);
                echo "OK $file exists and it contains $limit lines to be validated with nmap";
            else
                echo "ERROR: $file does not exist or is empty. "
            exit 1
            fi
            ;;

        # help
        h)  echo "0.1_evasiontechs.sh new version 0.5";
            echo "";
            echo "A tool for resuming and reporting Nmap scans using the --resume feature. Should be executed as root.";
            echo "Please use a ips.txt file with one target per line (host, range or network).";
            echo "The Nmap scan will start from the begining or from the last group of IP's if it was interrupted."
            echo "It use the output $file.0.1_evasiontechs.sh.gnmap to check if it was paused or just need to start from the begining"
            echo "Scan will group by 64 hosts. This value could be change in case more or less space is required"
            echo "";
            echo "SYNTAX: ./1_0.1_evasiontechs.sh [-f filename]"
            echo "          if no -f is specified, it will look for ips.txt file";
            exit 0	>&2;;

        *) echo "SYNTAX: ./1_0.1_evasiontechs.sh -f ips.txt or ./0.1_evasiontechs.sh -h for help" >&2
            exit 1;;

        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;

        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        esac
    done

}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 1 ${NC} - Fragment Packets SCRIPT" | tee -a evasiontechsum_$file
nmap -f -iL $file -oN evasiontech1.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 1 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 2 - MTU ${NC} SCRIPT" | tee -a evasiontechsum_$file
nmap --mtu 16 -iL $file -oN evasiontech2.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 2 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 3 - BADSUM ${NC} SCRIPT" | tee -a evasiontechsum_$file
nmap --badsum -iL $file -oN evasiontech3.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 3 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 4 - FW BYAPSS ${NC} SCRIPT" | tee -a evasiontechsum_$file
nmap -sS -T4 -iL $file --script firewall-bypass -oN evasiontech4.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 4 ${NC} COMPLETED" | tee -a evasiontechsum_$file

#This technique is useful if the attacker wants to hide the real IP when doing the attack by sending many different IPs to make hard to detect the real IP attacker
#So it is not useful in this case
echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " NOT USING ${RED}Evasion Technique 5 - RANDOM DECOY ${NC} SCRIPT. CHECK IF APPLICABLE AND MODIFY THE SCRIPT" | tee -a evasiontechsum_$file
#echo -e " STARTING ${RED}Evasion Technique 5 - RANDOM DECOY ${NC} SCRIPT" | tee -a evasiontechsum_$file
#nmap -D RND:10 -iL $file -oN evasiontech5.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 5 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " NOT USING ${RED}Evasion Technique 6 - SPOOFING INTERNAL IPs ${NC} SCRIPT. CHECK IF APPLICABLE AND MODIFY THE SCRIPT" | tee -a evasiontechsum_$file
#echo -e " STARTING ${RED}Evasion Technique 6 - SPOOFING INTERNAL IPs ${NC} SCRIPT" | tee -a evasiontechsum_$file
# Change these IP's to other known segments in the network to be assessed
#echo -e "Make sure you modified the source IP addresses to use in this technique"
#nmap -D $SOURCEIPS -iL $file -oN evasiontech6.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 6 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 7 - SOURCE PORT 53 ${NC} SCRIPT" | tee -a evasiontechsum_$file
nmap --source-port 53 -iL $file -oN evasiontech7.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 7 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 8 - SPOOF MAC ${NC} SCRIPT" | tee -a evasiontechsum_$file
nmap -sT -Pn --spoof Dell -iL $file -oN evasiontech8.$file --top-ports $numports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 8 ${NC} COMPLETED" | tee -a evasiontechsum_$file

echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo -e " STARTING ${RED}Evasion Technique 9 - UDP TOP $udpports ${NC} SCRIPT. This technique could be very slow." | tee -a evasiontechsum_$file
nmap -iL $file -oN evasiontech9.$file -sU --top-ports $udpports --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup $maxhosts -Pn -vvvv
echo -e " ${RED}Evasion Technique 1 ${NC} COMPLETED" | tee -a evasiontechsum_$file


echo -e "${GREEN}**************************************************************${NC}*" | tee -a evasiontechsum_$file
echo "Results Evasion Techniques scan " | tee -a evasiontechsum_$file
echo "Look for any open port reported in these lines: " | tee -a evasiontechsum_$file
cat evasiontech[0-9].$file |grep "open\|report" | grep -1 "open" | tee -a evasiontechsum_$file
echo "Check summary of the results, including IP's and open ports in file evasiontechsum_$file " | tee -a evasiontechsum_$file
chown -R $user:$user *
echo -e "${GREEN}SCRIPT COMPLETED SUCCESSFULLY${NC}*" | tee -a evasiontechsum_$file
echo -e "${GREEN}RUN ./0.2_analyseresultsevasion.sh $file SCRIPT TO GET THE DETAILS OF IPs AND PORTS FOUND${NC}*" | tee -a evasiontechsum_$file
echo -e "${RED}**************************************************************${NC}*" | tee -a evasiontechsum_$file
# Using a Zombie machine:
echo "If you want to complete additional tests: "
echo "To run through a zombie machine run: "
echo "sudo nmap -sI [ZOMbie_Machine] [target] --top-ports $numports -oN evasiontech9.txt"
#hping3 -S -c 1 -s 5151 -p 80 192.168.1.12
#hping3 -A -c 1 -s 5151 -p 80 192.168.1.12
# Metasploit:
echo "In Metasploit: use auxiliary/scanner/ip/ipidseq"
echo ">  set RHOSTS ip1,ip2,..."
echo ">  run"
echo "To start Metasploit: msfconsole"
#msfconsole
