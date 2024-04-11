#!/bin/bash
# This script runs different tests related with SMB / Microsoft services (RDP, LDAP) withput credentials
# It uses: enum4linux, smbmap, rpcdump, nbtscan, crackmapexec smb, nmap scripts for smb and rdp 
#       sudo ./4_enumSMB_new.sh -f targets.txt
# It takes the consolidated file ./results/445_all_TCP.ips created by 3_preparefiles_new as input
# and runs enum4linux and rpcdump on all hosts identified with port 445 open
# It runs nmap with rdpenum script for all host with port 3389 open
# It requires enum4linux instaled and available in the running path
# TODO:
#   enum SQL => Included 31/08/2022
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################
declare file
declare msfile
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
#Root if it is through sudo
username=$(whoami)
#Real user
user=$((who am i) | awk '{print $1}');
startpoint=1


if [[ "$EUID" != 0 ]]; then
        echo "$username, please run it as sudo $0";
        exit 0;
fi

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
        h)  echo "enumMS new version 0.5";
            echo "";
            echo "A tool to gather information related to Microsoft services / ports.";
            echo "";
            echo "SYNTAX: $0 -f targets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: $0 -f targets.txt or ./$0 -h for help" >&2
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
        echo "SYNTAX: ./$0 -f targets.txt or ./$0 -h for help" >&2
        exit 1
    fi
}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

mkdir enumSMB;
logfile="_results_scanSMB_$file.log"
msfile=smb_$file
echo -e "${GREEN}**************************************************************${NC}*" | tee -a ./enumSMB/$logfile
echo -e " STARTING ${GREEN}enumSMB${NC} SCRIPT" | tee -a ./enumSMB/$logfile
# Check possible issues on port 135,137,139 and 445 using enum4linux, smbmap with empty credentials, rpcdump, and nbtscan
#Join all the IP's with SMB related open ports
cd results
#cat 135_all_*.ips 137_all_*.ips 139_all_*.ips 445_all_*.ips | sort -n | uniq > $file
cat "135_"$file"_"*".ips" "137_"$file"_"*".ips" "139_"$file"_"*".ips" "445_"$file"_"*".ips" | sort -n | uniq > ../enumSMB/$msfile
cd ../enumSMB
totalips=$(cat $msfile|wc -l)
echo -e "Total IP's to validate: ${GREEN}$totalips${NC}" | tee -a $logfile
echo -e "${GREEN}**************************************************************${NC}*" | tee -a $logfile
indexip=1
for ip in $(cat $msfile); do 
    if [ $startpoint -gt $indexip ]; then
        echo "Skipping IP $ip"| tee -a $logfile
    else
        filename="enum4_"$ip".txt"
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "Checking position ${GREEN}$indexip${NC} out of $totalips" | tee -a $logfile
        echo -e "Checking IP: "$ip" using enum4linux saving into file $filename" | tee -a $logfile
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        # https://highon.coffee/blog/enum4linux-cheat-sheet/
        # -a includes: -U -S -G -P -r -o -n -I
        enum4linux -a $ip | tee -a $filename 
        #If required specific at any time:
        #Gets the OS
        #enum4linux -o $ip
        #Gets the password policies
        #enum4linux -P $ip
        #Gets the group policies
        #enum4linux -G $ip
        #Gets the share policies
        #enum4linux -S $ip
        #Attempt to enumerate the users:
        #enum4linux -U $ip
        #enum4linux -r $ip


        filename2="smbmap_"$ip".txt"
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "Checking IP: ${GREEN}"$ip"${NC} using smbmap saving into file $filename2" | tee -a $logfile
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "" | tee -a $filename2
        echo -e "smbmap -u \'\' -H $ip" | tee -a $filename2| tee -a $logfile
        smbmap -u "" -H $ip  | tee -a $filename2
        echo "" | tee -a $filename2| tee -a $logfile
        echo -e "smbmap -u Guest -p \'\' -H $ip" | tee -a $filename2| tee -a $logfile
        smbmap -u Guest -p '' -H $ip | tee -a $filename2

        filename3="rpcdump_"$ip".txt"
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "Checking IP: ${GREEN}"$ip"${NC} using rpcdump saving into file $filename3" | tee -a $logfile
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        #python3 /usr/share/doc/python3-impacket/examples/rpcdump.py $ip | tee -a $filename3;
        impacket-rpcdump $ip | tee -a $filename3;

        filename4="nbtscan_"$ip".txt"
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "Checking IP: ${GREEN}"$ip"${NC} using nbtscan saving into file $filename4" | tee -a $logfile
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        sudo nbtscan -r $ip | tee -a $filename4
        echo -e "Scan Completed for IP: $ip" | tee -a $logfile

        filename5="smbclient_"$ip".txt"
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo -e "Checking IP: ${GREEN}"$ip"${NC} using smbclient saving into file $filename5" | tee -a $logfile
        echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
        echo "smbclient -N -L //$ip " | tee -a $filename5| tee -a $logfile
        smbclient -N -L //$ip | tee -a $filename5
        echo "" | tee -a $filename5
        echo "smbclient -N -L smb -I $target" | tee -a $filename5
        smbclient -N -L smb -I $target
    fi
    indexip=$(($indexip+1))
done
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
echo -e "COMPLETED! A total of $totalips were checked!" | tee -a $logfile
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile


# Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
# It should be normally in the local network
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
echo "Checking vulnerable targets with crackmapexec into file SMBtargets.txt" | tee -a $logfile
#sudo crackmapexec smb $file --gen-relay-list SMBtargets.txt
crackmapexec smb $msfile --gen-relay-list SMBtargets_tmp.txt
cat SMBtargets_tmp.txt | sort -n | uniq >  SMBtargets_$msfile
rm  SMBtargets_tmp.txt
crackmapexec smb SMBtargets_$msfile -u '' -p '' |tee -a SMBAttackResults_$msfile
cat SMBAttackResults_$msfile |grep "signing:False"|awk '{print $2}' | sort -n | uniq > SMBVulnerableSystems_$msfile
vulnsystems=$(cat SMBVulnerableSystems_$msfile|wc -l)
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
echo -e " SMB Vulnerable systems: ${RED} $vulnsystems ${NC}"| tee -a $logfile
if [ $vulnsystems > 0 ]; then
    echo -e " ${RED} Check file SMBVulnerableSystems_$msfile ${NC}"| tee -a $logfile
fi
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile
echo -e "CrackMapExec COMPLETED!" | tee -a $logfile
echo -e "${GREEN}***************************************************************${NC}"| tee -a $logfile

# Run RDP enumeration using NMAP port hosts in file 3389.ips
#nmap scripts: rdp-enum-encryption,rdp-ntlm-info,rdp-vuln-ms12-020
cd ..; mkdir enumRDP; cd enumRDP
filetoscan="3389_"$file"_TCP.ips" 
echo -e "${GREEN}***************************************************************${NC}"| tee -a ../enumSMB/$logfile
echo -e "Checking RDP for port 3389 " | tee -a ../enumSMB/$logfile
echo -e "Command: nmap -Pn -p 3389 -Pn -sV -sC --open -vvv -n  -iL ../results/$filetoscan --max-hostgroup 16 -oA enumRDP_$file" | tee -a ../enumSMB/$logfile
#sudo nmap -Pn -p 3389 -Pn -sV -sC -oA enumRDPALL --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
nmap -Pn -p 3389 -Pn -sV -sC --open -vvv -n  -iL ../results/$filetoscan --max-hostgroup 16 -oA enumRDP_$file
#sudo nmap -Pn -p 3389 -Pn -sV -sC --script=rdp-ntlm-info,rdp-vuln-ms12-020 -oA enumRDPALL2 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
# script rdp-enum-encryption lock the nmap command for some specific IP's
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -d -oA enumRDPALL3 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL 3389_all_TCP.ips -oA enumRDPALL3 --max-hostgroup 16
echo -e "Nmap completed! " | tee -a ../enumSMB/$logfile
echo -e "${GREEN}***************************************************************${NC}"| tee -a ../enumSMB/$logfile
echo -e "Checking RDP using script rdp-enum-encryption and ssl-enum-ciphers" | tee -a ../enumSMB/$logfile
nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption,ssl-enum-ciphers -iL ../results/$filetoscan --max-hostgroup 16 -oA enumRDP2_$file

echo -e "${GREEN}***************************************************************${NC}"| tee -a ../enumSMB/$logfile
echo "Checking for LDAP servers ..."| tee -a ../enumSMB/$logfile
cd ..;mkdir enumLDAP;
# Grep selects only ldap services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/$file"_ipsnports_all.csv" | awk 'BEGIN {FS = ","}; {if ($3=="\"389\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumLDAP/ldap_tmp.txt
cat ./results/$file"_ipsnports_all.csv" | awk 'BEGIN {FS = ","}; {if ($3=="\"636\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq >> ./enumLDAP/ldap_tmp.txt
cat ./enumLDAP/ldap_tmp.txt | sort -n |uniq > ./enumLDAP/ldap_$file
rm ./enumLDAP/ldap_tmp.txt
numservers==$(cat ./enumLDAP/ldap_$file | wc -l)
echo -e "Total servers found: ${RED} $numservers ${NC}"| tee -a ./enumSMB/$logfile
echo "Command: nmap -p389,636,3268,3269 -Pn -sV --script="ldap* and not brute" --max-hostgroup 16 -iL ./enumLDAP/ldap_$file -oA ./enumLDAP/ldap_$file" | tee -a ./enumSMB/$logfile
nmap -p389,636,3268,3269 -Pn -sV --script="ldap* and not brute" --max-hostgroup 16 -iL ./enumLDAP/ldap_$file -oA ./enumLDAP/ldap_$file

echo -e "${GREEN}***************************************************************${NC}"| tee -a ./enumSMB/$logfile
echo -e "Checking SMB2 on port 445" | tee -a ./enumSMB/$logfile
echo -e "This part could take time" | tee -a ./enumSMB/$logfile
cd enumSMB
#sudo nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -oA nmap-vuln -iL $file --open --max-hostgroup 16 --script-timeout 60m
echo -e "Command: nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -iL $msfile --open --max-hostgroup 16 -oA nmap-vuln_$file" | tee -a ../enumSMB/$logfile
nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -iL $msfile --open --max-hostgroup 16 -oA nmap-vuln_$file
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-vuln-conficker.nse,smb-vuln-cve2009-3103.nse,smb-vuln-cve-2017-7494.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-ms17-010.nse,smb-vuln-regsvc-dos.nse -Pn -p445 -oA nmap-SMB2 -iL $file
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-* -Pn -p445 -oA nmap-SMB2 -iL $file
#Not requird. Already included before
#nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse --script="smb-* and not brute" -Pn -p445 -oA nmap-SMB2_$file -iL $file

cd ..;mkdir enumMSSQL;
echo "${GREEN}***************************************************************${NC}"| tee -a ./enumSMB/$logfile
echo "Checking MS-SQL port 1433 " | tee -a ../enumSMB/$logfile
cat ./results/$file"_ipsnports_all.csv" | grep "ms-sql" | cut -f 1 -d ","| sed 's/\"//g' | sort -n | uniq > ./enumMSSQL/mssql_$file
# All other scripts require authentication or additional parmameters
echo "Command: nmap -p 1433 -Pn -n -vvvv --script "ms-sql-info" -sV -sC -iL ./enumMSSQL/mssql_$file --max-hostgroup 16 -oA ./enumMSSQL/enumSQLALL_$file" | tee -a ./enumSMB/$logfile
nmap -p 1433 -Pn -n -vvvv --script "ms-sql-info" -sV -sC -iL ./enumMSSQL/mssql_$file --max-hostgroup 16 -oA ./enumMSSQL/enumSQLALL_$file

# Test certificates used in SQL Servers
echo -e "Checking TLS connections on SQL Servers for ${RED}$numips${NC} IP's using nmap..." | tee -a ../enumSMB/$logfile
echo "Command: nmap -sV --script=ssl-enum-ciphers -p 1433 --max-hostgroup 16 -iL ./enumMSSQL/mssql_$file -oA enumMSSQL/nmap_sslenum_1433_$file" | tee -a ./enumSMB/$logfile
nmap -sV --script=ssl-enum-ciphers -p 1433 --max-hostgroup 16 -iL ./enumMSSQL/mssql_$file -oA ./enumMSSQL/nmap_sslenum_1433_$file;


# Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
# I moved this to the end as it was taking too long all time (last part)
echo -e "${GREEN}**************************************************************${NC}*"| tee -a ./enumSMB/$logfile
echo "Checking SMB vulnerabilities using script nbsat.nse port 137" | tee -a ./enumSMB/$logfile
# Port 137 UDP
#sudo nmap -Pn -sU -p 137 --script nbstat.nse -iL ./results/137_all_UDP.ips --max-hostgroup 16 -oA nmap-NBSTAT
filetoscan="137_"$file"_UDP.ips"
echo "Command: nmap -Pn -sU -p 137 --script nbstat.nse -iL ./results/$filetoscan --max-hostgroup 16 -oA ./enumSMB/nmap-NBSTAT_$file" | tee -a ./enumSMB/$logfile
nmap -Pn -sU -p 137 --script nbstat.nse -iL ./results/$filetoscan --max-hostgroup 16 -oA ./enumSMB/nmap-NBSTAT_$file

# I tried this but was not working properly. Scans get no progress at some point
echo -e "${GREEN}**************************************************************${NC}*"| tee -a ./enumSMB/$logfile
echo "Checking SMB vulnerabilities using many scripts smb-* ports 445,139,135,137" | tee -a ./enumSMB/$logfile
#nmap -Pn -n -p445,139,135,137 -vvvv --script="smb-* and not brute" -iL $msfile --open --max-hostgroup 16 -oA nmap-SMB_$file
echo "Command: nmap -Pn -n -p445,139,135,137 -vvvv --script smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -iL ./enumSMB/$msfile --open --max-hostgroup 16 -oA ./enumSMB/nmap-SMB_$file" | tee -a ./enumSMB/$logfile
timeout 300m nmap -Pn -n -p445,139,135,137 -vvvv --script smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -iL ./enumSMB/$msfile --open --max-hostgroup 16 -oA ./enumSMB/nmap-SMB_$file

#Check if SMB not signing is enabled  (i.e.  Message signing enabled but not required)
#nmap -Pn -sV -p 139,445 --script=smb-protocols,smb2-security-mode --max-hostgroup 16 -iL SMB_NotSigning.txt -oA SMB_NotSigning_enum

# To check if all in the same nmap is failing or if this needs to be separated:
# nmap -Pn -sV -v --script smb-os-discovery.nse,nbstat.nse -oA nmap-NBT -iL $file --open --max-hostgroup 16

echo -e "${GREEN}**************************************************************${NC}*"| tee -a ./enumSMB/$logfile
echo -e "Extracting interesting information from enum4linux. Check files ${GREEN}./enumSMB/_Enum4Linux_*${NC} to validate findings"| tee -a ./enumSMB/$logfile
echo -e "${GREEN}**************************************************************${NC}*"| tee -a ./enumSMB/$logfile
grep -n -B 3 "<ACTIVE>\|Found new" enum4* | tee ./enumSMB/_Enum4Linux_2check.txt 
cat ./enumSMB/_Enum4Linux_2check.txt | awk '{print $1}' |grep -v "\-\-" | sed 's/enum4_//g' | sed 's/\.txt.*//g' | sort -u > ./enumSMB/_Enum4Linux_$file

chown -R $user:$user enumRDP/*
chown -R $user:$user enumSMB/*
chown -R $user:$user enumLDAP/*
chown -R $user:$user enumSQL/*

echo ""; 
echo "********************************************************"
echo "ENUM MS FINISHED"; 
echo "Results at enumRDP/, enumSMB/, enumSQL and enumLDAP/"; 
echo "********************************************************"



# ADDITIONAL IDEAS BASED ON THE RESULTS OR USING CREDENTIALS:
# smbclient \\\\$target\\<sharedirectory>
# When it is a workgroup
# smbclient \\\\$target\\IPC$ -u [username] [-W machinename] 
# smbclient //$IP/ipc$ -U john
# List all shares in target  (-L host, -N no password)
# smbclient -N -L //$target   => already in enum4linux
# List shares with the specified user
# smbclient -U <username> -L $target   =>same info

# CONNECT TO THE SHARED FOLDER:
# mount -t cifs //x.x.x.x/share /mnt/share

# Get the information in the share recursively
# smbget -R smb://$target/<share>

# Attack to the password based in a username
# hydra -l milesdyson -P passwordlist.txt $target smb


# python3 /usr/share/doc/python3-impacket/examples/rpcdump.py [domain/]<username>[:password]@$target
# rpcclient.py -U <username> [-p port] [-W workgroup] $target  
# If access is obtained then: https://mucomplex.medium.com/remote-procedure-call-and-active-directory-enumeration-616b234468e5
# querydispinfo
# querydominfo
# enumprivs
# netshareenumall
# netshareenum

# Tries to get the shares info based on user credentials
# python3 /usr/share/doc/python3-impacket/examples/psexec.py <user>@$target


# METASPLOIT:
# use auxiliary/scanner/smb/smb_enumshares
# use auxiliary/scanner/smb/pipe_auditor
# use auxiliary/scanner/smb/pipe_dcerpc_auditor




