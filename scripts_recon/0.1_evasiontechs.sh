#!/bin/bash
# SYNTAX: sudo ./1_evasiontechs.sh -f [filename]    by default it takes ipshide.txt as the source 
# This script attempts to bypass network controls to validate if a connection can be established to a non-reachable IP.
# To do so, the script first extract a list of hosts from the received file (ipshide.txt) and tries to check if it is reacheble using some evasion techniques
# Results are left in files evasiontech[x].$file
file=ipshide.txt


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
            echo "Please use a ipshide.txt file with one target per line (host, range or network).";
            echo "The Nmap scan will start from the begining or from the last group of IP's if it was interrupted."
            echo "It use the output $file.0.1_evasiontechs.sh.gnmap to check if it was paused or just need to start from the begining"
            echo "Scan will group by 64 hosts. This value could be change in case more or less space is required"
            echo "";
            echo "SYNTAX: ./1_0.1_evasiontechs.sh [-f filename]"
            echo "          if no -f is specified, it will look for ipshide.txt file";
            exit 0	>&2;;

        *) echo "SYNTAX: ./1_0.1_evasiontechs.sh -f ipshide.txt or ./0.1_evasiontechs.sh -h for help" >&2
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


nmap -f -iL $file -oN evasiontech1.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap --mtu 16 -iL $file -oN evasiontech2.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap --badsum -iL $file -oN evasiontech3.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap -sS -T4 -iL $file --script firewall-bypass -oN evasiontech4.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap -D RND:10 -iL $file -oN evasiontech5.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
# Change these IP's to other known segments in the network to be assessed
nmap -D 10.68.254.1,10.68.100.129,172.30.35.10,10.68.58.101,10.69.25.111 -iL $file -oN evasiontech6.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap --source-port 53 -iL $file -oN evasiontech7.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
nmap -sT -Pn --spoof Dell -iL $file -oN evasiontech8.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv

# Using a Zombie machine:
echo "To run through a zombie machine run: "
echo "sudo nmap -sI [ZOMbie_Machine] [target] -F -oN evasiontech9.txt"


#hping3 -S -c 1 -s 5151 -p 80 192.168.1.12
#hping3 -A -c 1 -s 5151 -p 80 192.168.1.12

# Metasploit:
echo "In Metasploit: use auxiliary/scanner/ip/ipidseq"
echo "set RHOSTS ip1,ip2,..."
echo "run"
echo "To start Metasploit: msfconsole"
#msfconsole

