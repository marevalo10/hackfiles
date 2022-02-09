#!/bin/bash
# This script must be run after resumetcp or resumeudp scripts have finished. It should be called for each file used for resumenmap (i.e. cde.txt, supportips.txt, ...)
# It receives the filename containing the IPs used to run the nmap  (i.e. cde.txt or support.txt or ips.txt) 
#     ./3_preparefiles_new.sh cdeips.txt
# It creates different files with the open ports TCP/UDP extracted from the nmap results file $file.resumenamep-[tcp|udp].gnmap 
# Files will be stored in Directory ./results
# MAIN FILES:
#   all_portsbyhostTCP.csv and all_portsbyhostUDP.csv  => List each IP and openports IP port1,port2,....
#   This file consolidates the information processed for all the scans completed in different files after each one is called in this script (cde.txt, supportips.txt,...). 
#   all_TCPportscount.csv and all_UDPportscount.csv  => Top ports used (Port# count) in desc order
#   <port#>_TCP.ips and <port#>_UDP.ips  => For each port found open, it includes the IP that has it open in the file
#
# 0. Extracts raw info of the gnmap file, IP and open TCP or UDP ports. File contains only an IP and identified open ports each line ("$file""$raw"TCP.csv or "$file""$raw"UDP.csv)
#       Example of a line: $file.resumenmap-tcp.1.gnmap:Host: 10.135.0.4 ()	Ports: 22/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2001/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2002/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2003/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2004/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2005/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2006/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2007/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2008/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2009/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2011/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2013/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2015/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2016/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2017/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2018/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2019/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2021/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2023/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2024/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2025/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2027/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2029/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2030/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2031/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2032/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/
# 1. Creates a list of all IP's with open TCP ports and one more with all IP's with UDP ports. Files: $file_hostsTCP.csv and $file_hostsUDP.csv
#       Example of a line: 10.11.12.13
# 2. Generates a file with the IP and TCP or UDP ports open. File name: "$file"_portsbyhostTCP.csv or "$file"_portsbyhostUDP.csv
#       Example of a line: 10.11.12.13 80,443,...,portn,
# 3. Generates a file including all ports discovered as open: "$file"_allportsTCP.csv and "$file"_allportsUDP.csv
#       Example of a line: 443
# 4. Generates a file with the number of hosts found by port in desc order (top ports open at the begining). Files: "$file"_TCPportscount.csv and "$file"_UDPportscount.csv
#       Example of a line (count port):  56 443
# 5. Generates the number of ports open by IP. Files: "$file"_portscountbyhostTCP.csv and "$file"_portscountbyhostUDP.csv
#       Example of a line (IP count):  10.11.12.13  8
# 6. For each open port creates a file containing the IP's having that port open. Files: "$portn"_"$file"_TCP.ips and "$portn"_"$file"_UDP.ips
#       Example of a filename: 443_"$file"_TCP.ips. Example of each line in the file (IP with this port 443 open):  10.11.12.13
# 7. Generates the IP and the open ports for that IP in each line. Files: "$file"_ipsnportsTCP.csv and "$file"_ipsnportsUDP.csv
#       Example of a line:  10.11.12.13,80,443,1025,...,portn
# 8. Consolidates all the information: 
#       Files: all"$raw"TCP.csv and all"$raw"UDP.csv. Example of each line in the file:  10.11.12.13, port1/open,port2/open,...
#       File all_hosts.csv contains all IP's with any TCP or UDP port, file all_hostsTCP.csv only TCP and all_hostsTCP.csv only hosts with UDP ports open
#       File all_portsTCP.csv and all_portsTCP.csv contains all ports one by line
#       File all_portsTCP1line.csv and all_portsTCP1line.csv contains all ports in 1 line separated by comma
#       File all_ipsnports.csv consolidates the info of all different networks (files) created
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
declare file
declare limit

# Number of files to be used
f=1
# Name of files, adjust them as required or add more
#file1=cde.txt
#file2=support.txt
echo "#################################################################################"

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
                echo "OK $file exists and it contains $limit lines to extract the results from nmap";
            else
                echo "ERROR: $file does not exist or is empty. "
            exit 1
            fi
            ;;

        # help
        h)  echo "preparefile new version 0.5";
            echo "";
            echo "#This script must be run after resumetcp or resumeudp scripts have finished"
            echo "# Bash to create files with open / vulnerable ports from the gnmap results"
            echo "# Files will be stored in Directory ./results"
            echo "#The base for this script was taken from a previous version provided by Carlos Marquez"
            echo "#Some additions in this version were completed by Miguel Arevalo"
            echo "It use the received file to scan (targets.txt) as input and it will add .resumenmap-tcp.gnmap to get the results"
            echo "";
            echo "SYNTAX: ./3_preparefile_new.sh -f targets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./3_preparefile_new.sh -f targets.txt or ./3_preparefile_new.sh -h for help" >&2
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
        echo "SYNTAX: ./3_preparefile_new.sh -f targets.txt or ./3_preparefile_new.sh -h for help" >&2
        exit 1
    fi
}


validate_parameters $@
echo "Preparing files resulting from TCP and UDP scans through resumetcp and resumeudp scripts"
echo "Script will use $file.resume[tcp|ud].gnmap as the base"
echo "You can run this script after any of the TCP/UDP scripts have finished."
if test -d results; then
    echo -e "Directory ${RED}./results exist....${NC} If files exist there, they will be overwroten"
	read -p "Are you sure? (y|n): " -n 1 -r; echo -e "\n";
	if [[ $REPLY =~ ^[Yy]$ ]]; 	then
		echo -e "Overwriting files..."
	else
		echo -e "Execution cancelled..."
		exit 1
	fi
else 
	mkdir results
	echo -e "Results will be stored in ./results/"
fi

# Loop to extract the information relative to each network segment analized
cp nmaptocsv.py results
cd results
# Make a copy of the files to ./results/
cp ../$file .
cp ../$file.resumenmap-tcp.gnmap .
cp ../$file.resumenmap-udp.gnmap .

    if (( "$(ls $file.resumenmap-tcp.gnmap|wc -l)" < 1 ) && (( "$(ls $file.resumenmap-udp.gnmap|wc -l)" < 1 ))) ; then 
            echo -e "{RED} Error: Required files were not found: "$file".resumenmap-tcp.gnmap or "$file".resumenmap-udp.gnmap){NC}"
            exit 1
    fi

    # Loop to extract the information relative to each network segment analized
    n=` cat $file | wc -l`
    echo -e "Number of networks or IP's in the file: $n"
    # file name to be used to create the raw file with a list of IP's and ports 
    raw="_raw_"
        echo -e ""
        echo -e "##################################################################"
        echo -e "Extracting info from files ${RED} "$file".resumenmap-[tcp|udp]" ${NC}
        echo -e "##################################################################"
        # 0. Extracts raw info of the gnmap file, IP and open TCP or UDP ports. File contains only an IP and identified open ports each line
        # Example of one line content: 
        # $file.resumenmap-tcp.1.gnmap:Host: 10.135.0.4 ()	Ports: 22/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2001/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2002/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2003/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2004/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2005/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2006/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2007/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2008/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2009/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2011/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2013/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2015/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2016/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2017/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2018/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2019/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2021/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2023/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2024/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2025/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2027/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2029/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2030/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2031/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/, 2032/open/tcp//ssh//Cisco SSH 1.25 (protocol 2.0)/
        # Original line was: grep "open/tcp"  $file.resumenmap-tcp.*.gnmap --color | tee $file.resumenmap-tcp.openports.csv
        grep "open/tcp"  $file.resumenmap-tcp.gnmap --color > "$file""$raw"TCP.csv
        grep "open/udp"  $file.resumenmap-udp.gnmap --color > "$file""$raw"UDP.csv
        echo -e "TCP ports (IP Ports: #port/open/...) raw list extracted to file: ${GREEN}"$file""$raw"TCP.csv${NC}"
        echo -e "UDP ports (IP Ports: #port/open/...) raw list extracted to file: ${GREEN}"$file""$raw"UDP.csv${NC}"

        # 1. Creates a list of all IP's with open TCP ports and one more with all IP's with UDP ports.
        # Using the previously generated file (step 0), extracts the IP of each line into $file_hostsTCP.csv
        # Original: cat $file.resumenmap-tcp.openports.csv | awk '{print $2}'> $file.resumenmap-tcp.hosts.csv
        # Line example: 10.135.0.4
        cat "$file""$raw"TCP.csv | awk '{print $2}' > "$file"_hostsTCP.csv
        cat "$file""$raw"UDP.csv | awk '{print $2}' > "$file"_hostsUDP.csv
        # File with all IP's found up (with tcp/udp ports). Only IP in the file. 1 Ip by line.
        cat "$file"_hosts*.csv | sort -n | uniq  > "$file"_hosts_all.csv
        echo -e "Host list with TCP ports identified extracted to file: ${GREEN} "$file"_hostsTCP.csv${NC}"
        echo -e "Host list with UDP ports identified extracted to file: ${GREEN} "$file"_hostsUDP.csv${NC}"

        # 2. Generates a file with the IP and TCP or UDP ports open. File name: "$file"_portsbyhostTCP.csv or "$file"_portsbyhostUDP.csv
        #       Example of a line: 10.11.12.13 port1,port2,...,portn,
        rm -f "$file"_portsbyhostTCP.csv; touch "$file"_portsbyhostTCP.csv;
        line=1
        for ipadd in $(cat "$file"_hostsTCP.csv); do
            tcpports=`awk FNR==$line "$file""$raw"TCP.csv| grep -o  -E "\b[0-9]{1,5}/open"  | sed 's/\/open//g' | awk -vORS=, '{ print  }'`; 
            echo $ipadd $tcpports >> "$file"_portsbyhostTCP.csv
            line=$(($line+1));
        done
        # Generates a file with the IP and UDP ports open: IP port1,port2,...,portn,
        rm -f "$file"_portsbyhostUDP.csv; touch "$file"_portsbyhostUDP.csv;
        line=1
        for ipadd in $(cat "$file"_hostsUDP.csv); do 
            udpports=`awk FNR==$line "$file""$raw"UDP.csv| grep -o  -E "\b[0-9]{1,5}/open"  | sed 's/\/open//g' | awk -vORS=, '{ print  }'`;
            echo $ipadd $udpports >> "$file"_portsbyhostUDP.csv
            line=$(($line+1));
        done

        # 3. Generates a file including all ports discovered as open: "$file"_allportsTCP.csv and "$file"_allportsUDP.csv
        #       Example of a line: port1
        # Magic part: grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g
        # grep -o -E "\b[0-9]{1,5}/open" -> select all #port/open from the file. If a line contains more than one pattern, it put each one in a different line
        # Original: cat $file.resumenmap-tcp.openports.csv |  grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g' > $file.resumenmap-tcp.ports.csv
        cat "$file""$raw"TCP.csv | grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g' > "$file"_allportsTCP.csv
        cat "$file""$raw"UDP.csv | grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq | sed 's/\/open//g' > "$file"_allportsUDP.csv
        # Creates a file with only one line including all ports`. ORS -> Output record separator
        # Original: awk -vORS=, '{ print $1 }' $file.resumenmap-tcp.ports.csv >  $file.resumenmap-tcp.portsoneline.csv
        awk -vORS=, '{ print $1 }' "$file"_allportsTCP.csv >  "$file"_allportsTCP1line.csv
        awk -vORS=, '{ print $1 }' "$file"_allportsUDP.csv >  "$file"_allportsUDP1line.csv
        echo -e "All TCP/UDP ports identified were extracted to: ${GREEN} "$file"_allports[TCP|UDP].csv   "$file"_all[TCP|UDP]ports1line.csv${NC}"

        # 4. Generates a file with the number of hosts found by port in desc order (top ports open at the begining). Files: "$file"_TCPportscount.csv and "$file"_UDPportscount.csv
        #       Example of a line (port count):  443 56
        # Original: cat $file.resumenmap-tcp.openports.csv | grep -o -E "\b[0-9]{1,5}/open" --color |sort -n | uniq -c | sed 's/\/open//g' | sort -r > $file.resumenmap-tcp.portscount.csv
        cat "$file""$raw"TCP.csv | grep -o -E "\b[0-9]{1,5}/open" --color | sort -n | uniq -c | sed 's/\/open//g' | sort -nr | awk '{print $2 "\t" $1}' > "$file"_TCPportscount.csv
        cat "$file""$raw"UDP.csv | grep -o -E "\b[0-9]{1,5}/open" --color | sort -n | uniq -c | sed 's/\/open//g' | sort -nr | awk '{print $2 "\t" $1}' > "$file"_UDPportscount.csv
        echo -e "Top TCP/UDP ports ordered in file ${GREEN}"$file"_[TCP|UDP]portscount.csv${NC}"

        # 5. Generates the number of ports open by IP. Files: "$file"_portscountbyhostTCP.csv and "$file"_portscountbyhostUDP.csv
        #       Example of a line (port count):  10.11.12.13  8
        # Original: cat $file.resumenmap-tcp.openports.csv | grep -o -n -E "\b[0-9]{1,5}/open" --color | awk -F ":" '{print $1'}  | uniq -c | awk {'print $1'} > $file.port.ip
        #pr -mts  $file.resumenmap-tcp.hosts.csv $file.port.ip > $file.resumenmap-tcp.hostsportcount.csv  ; rm $file.port.ip
        cat "$file""$raw"TCP.csv | grep -o -n -E "\b[0-9]{1,5}/open" --color | awk -F ":" '{print $1}'  | uniq -c | awk {'print $1'} > temp.portTCP.ip
        cat "$file""$raw"UDP.csv | grep -o -n -E "\b[0-9]{1,5}/open" --color | awk -F ":" '{print $1}'  | uniq -c | awk {'print $1'} > temp.portUDP.ip
        # pr merge 2 or more files (-m) separated by a character (-s tab by defauult) and omit header (-t)
        pr -mts  "$file"_hostsTCP.csv temp.portTCP.ip > "$file"_portscountbyhostTCP.csv  ; rm temp.portTCP.ip
        pr -mts  "$file"_hostsUDP.csv temp.portUDP.ip > "$file"_portscountbyhostUDP.csv  ; rm temp.portUDP.ip
        echo -e "A file named with the IP and number of open ports ${GREEN}"$file"_portscountbyhost[TCP|UDP].csv "${NC}


        #Part extracted from ports.sh
        # 6. For each open port creates a file containing the IP's having that port open. Files: "$portn"_"$file"_TCP.ips and "$portn"_"$file"_UDP.ips
        #       Example of a filename: 443_"$file"_TCP.ips. Example of each line in the file (IP with this port 443 open):  10.11.12.13
        # Original: for i in $(cat ips.txt.resumenmap-tcp.ports.csv); do echo -e "Extracting hosts list for TCP port $i in $i.PTV.ips file"; cat ips.txt.resumenmap-tcp.openportsPTV.csv | grep "$i/open" | awk {'print $2'} >$i.PTV.ips; done;
        # Example line read first file (network_allportsTCP): 21
        # Example line read second file (raw) 10.135.0.17:21/open/tcp//ftp//APC AOS ftpd 6.5.0 (on APC AP9631 network management card)/, 23/open/tcp//telnet//APC AP9630 network management telnetd/, 80/open/tcp//tcpwrapped///
        # j is the port found up in each network
        for portn in $(cat "$file"_allportsTCP.csv); do 
            #echo -e "Extracting hosts list for TCP port $portn in "$portn"_"$file"_TCP.ips file"; 
            cat "$file""$raw"TCP.csv | grep "[ ,]$portn/open" | awk {'print $2'} >"$portn"_"$file"_TCP.ips; 
        done;
        for portn in $(cat "$file"_allportsUDP.csv); do 
            #echo -e "Extracting hosts list for UDP port $portn in "$i"_"$file"_UDP.ips file"; 
            cat "$file""$raw"UDP.csv | grep "$portn/open" | awk {'print $2'} >"$portn"_"$file"_UDP.ips; 
        done;
        echo -e "A file named with the port# contains all the IP's found with that port open: ${GREEN}port#_network_[TCP|UDP].csv${NC}"

        # 7. Generates the IP and the open ports for that IP in each line. Files: "$file"_ipsnportsTCP.csv and "$file"_ipsnportsUDP.csv
        #       Example of a line:  10.11.12.13,80,443,1025,...,portn
        python ./nmaptocsv.py -i $file.resumenmap-tcp.gnmap -f ip-fqdn-port-protocol-service-version-os -o "$file"_ipsnportsTCP.csv -d ","
        python ./nmaptocsv.py -i $file.resumenmap-udp.gnmap -f ip-fqdn-port-protocol-service-version-os -o "$file"_ipsnportsUDP.csv -d ","
        # Deletes all lines without information (no port # on field 3)
        cat "$file"_ipsnportsTCP.csv | awk 'BEGIN {FS = ","}; {if($3!=""){print}}' > "$file"_ipsnports.tmp; mv -f "$file"_ipsnports.tmp "$file"_ipsnportsTCP.csv
        cat "$file"_ipsnportsUDP.csv | awk 'BEGIN {FS = ","}; {if($3!=""){print}}' > "$file"_ipsnports.tmp; mv -f "$file"_ipsnports.tmp "$file"_ipsnportsUDP.csv
        
        # Joins TCP and UDP info,  a file with the IP and port info (1 port per line). Format: "IP", "", "port#", "udp", ...
        cat "$file"_ipsnports*.csv > "$file"_ipsnports_all.csv
        echo -e "CSV with IPs and ports were created with nmaptocsv.py: ${GREEN}"$file"_ipsnports[TCP|UDP|all].csv${NC}"

    echo -e "######################################"
    echo -e "Consolidating ${RED} ALL the information" ${NC}
    echo -e "######################################"

    # Delete existing files (if any)
    rm -f all_*.csv
    rm -f all_*.ips

    echo -e "INFORMATION CREATED IN DIRECTORY ${GREEN}./results${NC}";

    # 8. Consolidates all the raw the information in a TCP and UDP file. Files: all"$raw"TCP.csv and all"$raw"UDP.csv
    #       Example of each line in the file:  10.11.12.13, port1/open,port2/open,...
    # All raw TCP/UDP info -> IP, ..., port1/open/...
    cat *"$raw"TCP.csv > all"$raw"TCP.csv
    cat *"$raw"UDP.csv > all"$raw"UDP.csv
    cat all"$raw"TCP.csv all"$raw"UDP.csv > all"$raw"All.csv

    # Consolidate information of all IP address with open TCP/UDP ports -> 1 IP per line
    cat *_hostsTCP.csv > all_hostsTCP.csv
    cat *_hostsUDP.csv > all_hostsUDP.csv
    cat *_portsbyhostTCP.csv > all_portsbyhostTCP.csv
    cat *_portsbyhostUDP.csv > all_portsbyhostUDP.csv
    echo -e "${RED}IMPORTANT File including IP port1,port2,..., IN: ${GREEN}all_portsbyhost[TCP|UDP].csv and $file_portsbyhost[TCP|UDP].csv${NC}"

    # Join all hosts TCP and UDP and unify the list to elminate any duplicated IPs (IPs with TCP and UDP ports)
    cat all_hostsTCP.csv all_hostsUDP.csv | sort -n | uniq > all_hosts.csv
    totaltcp=`cat all_hostsTCP.csv |wc -l`; 
    totaludp=`cat all_hostsUDP.csv |wc -l`; 
    totalips=`cat all_hosts.csv |wc -l`; 
    echo -e "Number of hosts with TCP open ports: ${GREEN}"$totaltcp"${NC}"
    echo -e "Number of hosts with UDP open ports: ${GREEN}"$totaludp"${NC}"
    echo -e "Number of hosts with open ports: ${GREEN}"$totalips"${NC}"
    
    # Consolidate information about all TCP/UDP ports found open on each network (*) 
    # File 1 format: port# (each line). 
    cat *_allportsTCP.csv | sort -n | uniq > all_portsTCP.csv
    cat *_allportsUDP.csv | sort -n | uniq > all_portsUDP.csv
    # File 2 format: por1, port2, port3, ..., port x,
    awk -vORS=, '{ print $1 }' all_portsTCP.csv >  all_portsTCP1line.csv
    awk -vORS=, '{ print $1 }' all_portsUDP.csv >  all_portsUDP1line.csv
    totaltcp=`cat all_portsTCP.csv |wc -l`; 
    totaludp=`cat all_portsUDP.csv |wc -l`; 
    echo -e "Number of TCP open ports: ${GREEN}"$totaltcp"${NC}"
    echo -e "Number of UDP open ports: ${GREEN}"$totaludp"${NC}"

    # Consolidate the number of hosts per port found up -> port#  count (#IPs with the port# open) organized from greater to less count
    # File format (Top of ports open): port#  #hosts (ordered desc) 
    cat all"$raw"TCP.csv | grep -o -E "\b[0-9]{1,5}/open" --color | sort -n | uniq -c | sed 's/\/open//g' | sort -nr | awk '{print $2 "\t" $1}' > all_TCPportscount.csv
    cat all"$raw"UDP.csv | grep -o -E "\b[0-9]{1,5}/open" --color | sort -n | uniq -c | sed 's/\/open//g' | sort -nr | awk '{print $2 "\t" $1}' > all_UDPportscount.csv
    # Top of hosts with ports open: IP  #ports (ordered by IP) 
    cat *_portscountbyhostTCP.csv > all_portscountbyhostTCP.csv
    cat *_portscountbyhostUDP.csv > all_portscountbyhostUDP.csv

    # Joins all networks info with the IP and port info from the file created by nmaptocsv.py (1 port per line). 
    # Format: "IP", "", "port#", ...
    cat *_ipsnports_all.csv > all_ipsnports.csv

    # Consolidates the information of the IPs by port in all the networks.
    # File name port#_all_tcp.ips. Format: IP  (1 IP per line)
    rm -f *_all_*.ips
    for portn in $(cat all_portsTCP.csv); do 
        cat "$portn"_*TCP.ips > "$portn"_all_TCP.ips; 
    done;
    for portn in $(cat all_portsUDP.csv); do 
        cat "$portn"_*UDP.ips > "$portn"_all_UDP.ips; 
    done;
    cd ..
    echo -e "Hosts list for each port was consolidated in ${GREEN}./results/<port#>_[TCP|UDP].ips${NC} for all networks";
    echo -e "${GREEN}Most IMPORTANT files to check: ${NC}"
    echo -e "IP and details open port by line CVS: ${GREEN}cat "$file"_ipsnports_all.csv |more${NC}"
    echo -e "IP and open ports list: ${GREEN}cat "$file"_portsbyhostTCP.csv |more${NC}"
    echo -e "Top open ports: ${GREEN}head -10 all_TCPportscount.csv${NC}"
    echo -e "All information of the processed files with this script are consolidated in files ${RED}all_*${NC}";
    echo -e "#####################################################################"

cd ..;

