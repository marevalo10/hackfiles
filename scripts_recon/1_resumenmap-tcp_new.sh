#!/bin/bash
#################################################################################
# SYNTAX: ./1_resumenmap-tcp_new.sh -f targets.txt
# I improved the nmap call using a file targets.txt containing the IP's or subnets to scan on it 
# and grouping by 64 hosts in case of any issue to resume from there. 
# Nmap has the ability to resume automaticaly. 
# It could be grouped by 64 IPs for example just in case stop, it resume (--resume and the filename) from the last 64 IP group
# By doing so, this script will be very simple! Just check if the .gnmap file already exist. If so, the run --resume instead of the full command
# In this way, it could be called using independent files by each group. Example: CDE.txt, DMZ.txt, ...
# And all the findings will be associated in the same group of files (cde.txt.resume-tcp...)
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################
#Identify file with targets and if is a new scan or an already started scan
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) to segregate TCP and UDP in different scripts and 
# to create the csv files once the script finishes
declare file
declare limit
#Ports to scan
declare topports
topports=10000
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
        h)  echo "resumenmap-tcp new version 0.5";
            echo "";
            echo "A tool for resuming and reporting Nmap scans using the --resume feature. Should be executed as root.";
            echo "Please use a targets file with one target per line (host, range or network).";
            echo "The Nmap scan will start from the begining or from the last group of IP's if it was interrupted."
            echo "It use the output $file.resumenmap-tcp.gnmap to check if it was paused or just need to start from the begining"
            echo "Scan will group by 64 hosts. This value could be change in case more or less space is required"
            echo "";
            echo "SYNTAX: ./1_resumenmap-tcp_new.sh -f targets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./1_resumenmap-tcp_new.sh -f targets.txt or ./resumenmap-tcp_new.sh -h for help" >&2
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
        echo "SYNTAX: ./resumenmap-tcp_new.sh -f targets.txt or ./resumenmap-tcp_new.sh -h for help" >&2
        exit 1
    fi
}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

# Check if the output file alredy exists meaning it should continue (resume) the previous scan
if test -s "$file.resumenmap-tcp.gnmap"
then
    echo "**************************************************************************************************************************************************"
    echo "Resuming previous scan.... If you dont want to start from the begining, then you need to delete the file $file.resumenmap-tcp.gnmap"
    read -n1 -s -r -p $'Press any key to resume ... or Ctrl - C to cancel\n' key
    echo "Resuming the scan ..."
    sudo nmap --resume $file.resumenmap-tcp.gnmap
else
    echo "**************************************************************************************************************************************************"
    echo "Starting the scan from the begining! No previous file $file.resumenmap-tcp.gnmap was found"
    read -n1 -s -r -p $'Press any key to start or Ctrl - C to cancel\n' key
    #echo "Starting the scan top $topports TCP ports..."
    echo "Starting the scan for all TCP ports..."
    # Take care with --privileged => It assumes the user has privileges and this could cause the scan to fail some detections
    #sudo nmap --top-ports $topports -A -Pn -T4 -sV -sT --open -vvvv --min-rate 5500 --max-rate 5700 --min-rtt-timeout 100ms --max-hostgroup 64 -n -iL $file -oA $file.resumenmap-tcp;
    # Scan all ports by groups of 8
    sudo nmap -p- -A -Pn -T4 -sV -sT --open -vvvv --max-rate 5700 --min-rtt-timeout 100ms --max-hostgroup 8 -n -iL $file -oA $file.resumenmap-tcp;
    #Zenmap in Windows system:
    #nmap -sT -sV -p- -T3 -A -vvv -n -iL "C:\\Users\\GMST\\Desktop\\Bupa\\zenmap\\cde.txt" -oA "C:\\Users\\GMST\\Desktop\\Bupa\\zenmap\\cde_enumtcp" --max-hostgroup 64 --min-rtt-timeout 100ms --min-rate 5500 --max-rate 5700 -Pn --open;
    # Soft Scan 1 by 1
    #nmap -sT -top-ports 100 -T2 -vvv -n -iL "C:\\Users\\GMST\\Desktop\\Bupa\\zenmap\\cde.txt" -oA "C:\\Users\\GMST\\Desktop\\Bupa\\zenmap\\cde_enumtcpsoft" --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn --open;
    # masscan:
    #masscan -e tun0 -p 1-65535 --rate 2000 10.10.10.90

fi

#Report section
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo ""
echo "#####################################################################"
echo "#"
echo "# Results review:"
echo "# "
echo "######################################################################"
echo ""
# Check if the scan was completed:
echo "Output of scan " $file.resumenmap-tcp.gnmap:;
if grep --quiet "Nmap done" $file.resumenmap-tcp.gnmap; then
    echo "The scan has been compelted succcesfully:"
    tail -1 $file.resumenmap-tcp.gnmap| GREP_COLOR='01;32'  grep --color "done"
    echo ""
else
    echo -e "The scan ${RED} $file.resumenmap-tcp.gnmap ${NC} has ${RED} not been completed successfully ${NC}"
    echo "Please run it again to continue from the last run state"
    exit 1
fi


echo "#####################################################################"
echo "Reviewing of TCP open ports:"
echo ""
echo -e "${NC}List of ALL hosts and TCP open ports will be stored in:${GREEN}" $file.resumenmap-tcp.openports.csv;
    grep "open/tcp"  $file.resumenmap-tcp.gnmap --color > $file.resumenmap-tcp.openports.csv
    echo ""
echo -e "${NC}List of hosts with TCP open ports will be stored in:${GREEN}" $file.resumenmap-tcp.hosts.csv;
    cat $file.resumenmap-tcp.openports.csv | awk '{print $2}' > $file.resumenmap-tcp.hosts.csv
    echo ""
echo -e "${NC}List of TCP open ports in all the systems ordered ascendly and line by line will be stored in:${GREEN}" $file.resumenmap-tcp.ports.csv;
    cat $file.resumenmap-tcp.openports.csv |  grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g' > $file.resumenmap-tcp.ports.csv
    echo ""
    echo  -e "${NC}List of TCP open ports in all the systems in one line separated by commas by line will be stored in:${GREEN}" $file.resumenmap-tcp.portsonline.csv 
    awk -vORS=, '{ print $1 }' $file.resumenmap-tcp.ports.csv >  $file.resumenmap-tcp.portsoneline.csv
    echo ""
echo -e "${NC}List of TCP open ports with counts in desc order (number_of_hosts port_number) will be stored in:${GREEN}" $file.resumenmap-tcp.portscount.csv;
    cat $file.resumenmap-tcp.openports.csv | grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq -c | sed 's/\/open//g' | sort -r > $file.resumenmap-tcp.portscount.csv
    echo  -e "${NC}List of TCP open ports by host (ip number_of_ports) by line will be stored in:${GREEN}" $file.resumenmap-tcp.hostsportscount.csv 
    cat $file.resumenmap-tcp.openports.csv | grep -o -n -E "\b[0-9]{1,5}/open" --color | awk -F ":" '{print $1 }'  | uniq -c | awk {'print $1'} > $file.port.ip
    pr -mts  $file.resumenmap-tcp.hosts.csv $file.port.ip > $file.resumenmap-tcp.hostsportcount.csv  ; rm $file.port.ip
    echo ""
echo -e "${NC}#####################################################################"
echo ""
