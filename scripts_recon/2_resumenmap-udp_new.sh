#!/bin/bash
#This script completes an UDP scan suing top 100 udp ports.
# SYNTAX:
#       ./2_resumenmap-udp_new.sh -f targets.txt
#Takes the list of ip's from the provided file (targets.txt in the example) to validate. Groups by 8 IP's.
#The script identifies if there is a previous scan to resumne it or ask to continue from the scatch
######################################################################################
# RESULTS
# This script will produce nmap results in all formats:  target.txt.resumenmap-udp.[gnmap,nmap,xml]
# These files will be used by 3_preparefiles script to produce analysed results 
# IMPORTANT: To easily identify openports (as many could be identified as "open|filtered"):
#   In file supportipsall.txt.resumenmap-udp.xml look for "open" 
#   In file supportipsall.txt.resumenmap-udp.nmap look for open and add a blank space
#
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

declare file
declare limit
#Ports to scan
declare topports
topports=100
echo "#################################################################################"

# When the program start, runs from here
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
        h)  echo "resumenmap-udp new version 0.6";
            echo "";
            echo "A tool for resuming and reporting Nmap scans using the --resume feature. Should be executed as root.";
            echo "Please use a targets file with one target per line (host, range or network).";
            echo "The Nmap scan will start from the begining or from the last group of IP's if it was interrupted."
            echo "It use the output $file.resumenmap-udp.gnmap to check if it was paused or just need to start from the begining"
            echo "Scan will group by 64 hosts. This value could be change in case more or less space is required"
            echo "";
            echo "SYNTAX: ./2_resumenmap-udp_new.sh -f targets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./2_resumenmap-udp_new.sh -f targets.txt or ./resumenmap-udp_new.sh -h for help" >&2
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

    # If no -f file was specified then it is a mistake
    if [[ $@ != *"-f"* ]] ; then
        echo "ERROR: No target file was indicated!"
        echo "SYNTAX: ./resumenmap-udp_new.sh -f targets.txt or ./resumenmap-udp_new.sh -h for help" >&2
        exit 1
    fi
}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

# Check if the output file alredy exists meaning it should continue (resume) the previous scan
if test -s "$file.resumenmap-udp.gnmap"
then
    echo "**************************************************************************************************************************************************"
    echo "Resuming previous scan.... If you dont want to start from the begining, then you need to delete the file $file.resumenmap-udp.gnmap"
    read -n1 -s -r -p $'Press any key to resume ... or Ctrl - C to cancel\n' key
    echo "Resuming the scan ..."
    sudo nmap --resume $file.resumenmap-udp.gnmap
else
    echo "**************************************************************************************************************************************************"
    echo "Starting the scan from the begining! No previous file $file.resumenmap-udp.gnmap was found"
    read -n1 -s -r -p $'Press any key to start or Ctrl - C to cancel\n' key
    echo "Starting the scan top $topports UDP ports..."
    # Take care with --privileged => It assumes the user has privileges and this could cause the scan to fail some detections
    # Adjusted to make it faster when the connection is good. In a good network configuring 64 host at the same time toks around 4 hours, so I put it down to 16
    #sudo nmap  -iL $file -oA $file.resumenmap-udp --top-ports 100 -sU -Pn -T3 -sV --open -vvvv --min-rate 5500 --max-rate 5700 --min-rtt-timeout 100ms --max-hostgroup 8 -n;
    sudo nmap  -iL $file -oA $file.resumenmap-udp --top-ports 100 -sU -Pn -T4 -sV --open -vvvv --min-rate 5500 --max-rate 5700 --min-rtt-timeout 100ms --max-hostgroup 16 -n;
    #Zenmap in Windows system:
    #nmap -sU -sV -top-ports 100 -T3 -A -vvv -n -iL "C:\\Temp\\Client\\zenmap\\cde.txt" -oA "C:\\Temp\\Client\\zenmap\\cde_enumudp" --max-hostgroup 8 --min-rtt-timeout 100ms --min-rate 5500 --max-rate 5700 -Pn --open;
    # Soft Scan 1 by 1
    #nmap -sU -top-ports 100 -T2 -vvv -n -iL "C:\\Temp\\Client\\zenmap\\cde.txt" -oA "C:\\Temp\\Client\\zenmap\\cde_enumudpsoft" --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn --open;

fi


#Report section
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo ""
echo "#####################################################################"
echo ""
echo Results review:
echo ""
echo "#####################################################################"
echo ""
#Review Section
echo "Scan Output for file " $file".resumenmap-udp.gnmap:";
	if grep --quiet "Nmap done" $file.resumenmap-udp.gnmap; then
        echo "Scan Output for file " $file " has been completed succcesfully"
        echo -e "Results in ${GREEN} $file.resumenmap-udp.gnmap ${NC}"
        tail -1 $file.resumenmap-udp.gnmap| GREP_COLOR='01;32'  grep --color "done"
        echo ""
	else
        echo -e "The scan for ${RED} $file ${NC} has ${RED} failed ${NC}"
	fi
echo ""
#done
echo ""



echo "#####################################################################"
echo ""
echo Review of open ports:
echo ""
echo -e "${NC}List of ALL hosts and open ports will be stored in:${GREEN}" $file.resumenmap-udp.openports.csv;
echo ""
echo -e "${NC}List of hosts with open ports will be stored in:${GREEN}" $file.resumenmap-udp.hosts.csv;
echo ""
echo -e "${NC}List of open ports will be stored in:${GREEN}" $file.resumenmap-udp.ports.csv;
echo ""
echo -e "${NC}List of open ports with counts will be stored in:${GREEN}" $file.resumenmap-udp.portscount.csv;
echo ""
echo -e "${NC}#####################################################################"
echo ""
	grep "open/udp"  $file.resumenmap-udp.gnmap --color | tee -a $file.resumenmap-udp.openports.csv
	cat $file.resumenmap-udp.openports.csv | awk '{print $2}' > $file.resumenmap-udp.hosts.csv
	cat $file.resumenmap-udp.openports.csv |  grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g' > $file.resumenmap-udp.ports.csv
	awk -vORS=, '{ print $1 }' $file.resumenmap-udp.ports.csv >  $file.resumenmap-udp.portsoneline.csv
	cat $file.resumenmap-udp.openports.csv | grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq -c | sed 's/\/open//g' | sort -r > $file.resumenmap-udp.portscount.csv
	cat $file.resumenmap-udp.openports.csv | grep -o -n -E "\b[0-9]{1,5}/open" --color | awk -F ":" {'print $1'}  | uniq -c | awk {'print $1'} > $file.udpport.ip
	pr -mts  $file.resumenmap-udp.hosts.csv $file.udpport.ip > $file.resumenmap-udp.hostsportcount.csv  ; rm $file.udpport.ip

sudo chown -R marevalo:marevalo *
