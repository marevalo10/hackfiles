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

if [[ "$EUID" != 0 ]]; then
        username=$(whoami);
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

echo "***************************************************************"
echo -e " STARTING ${GREEN}enumSMB${NC} SCRIPT"
# Check possible issues on port 135,137,139 and 445 using enum4linux, smbmap with empty credentials, rpcdump, and nbtscan
mkdir enumSMB;
msfile=smb_$file
#Join all the IP's with SMB related open ports
cd results
#cat 135_all_*.ips 137_all_*.ips 139_all_*.ips 445_all_*.ips | sort -n | uniq > $file
cat "135_"$file"_"*".ips" "137_"$file"_"*".ips" "139_"$file"_"*".ips" "445_"$file"_"*".ips" | sort -n | uniq > $msfile
cp $msfile ../enumSMB 
cd ../enumSMB
totalips=$(cat $msfile|wc -l)
echo -e "Total IP's to validate: ${GREEN}$totalips${NC}"
echo "***************************************************************"
for ip in $(cat $msfile); do 
    filename="enum4_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using enum4linux saving into file $filename"; 
    echo "***************************************************************"
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


    filename="smbmap_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using smbmap saving into file $filename"; 
    echo "***************************************************************"
    echo "" | tee -a $filename
    echo "smbmap -u \'\' -H $ip" | tee -a $filename
    smbmap -u "" -H $ip  | tee -a $filename
    echo "" | tee -a $filename
    echo "smbmap -u Guest -p \'\' -H $ip" | tee -a $filename
    smbmap -u Guest -p '' -H $ip | tee -a $filename

    filename="rpcdump_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using rpcdump saving into file $filename"; 
    echo "***************************************************************"
    python3 /usr/share/doc/python3-impacket/examples/rpcdump.py $ip | tee -a $filename;

    filename="nbtscan_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using nbtscan saving into file $filename"; 
    echo "***************************************************************"
    sudo nbtscan -r $ip | tee -a $filename
    echo "Scan Completed for IP: $ip"; 

    filename="smbclient_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using smbclient saving into file $filename"; 
    echo "***************************************************************"
    echo "smbclient -N -L //$ip " | tee -a $filename
    smbclient -N -L //$ip | tee -a $filename
    echo "" | tee -a $filename
    echo "smbclient -N -L smb -I $target" | tee -a $filename
    smbclient -N -L smb -I $target

done


# Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
# It should be normally in the local network
echo "***************************************************************"
echo "Checking vulnerable targets with crackmapexec into file SMBtargets.txt"; 
#sudo crackmapexec smb $file --gen-relay-list SMBtargets.txt
crackmapexec smb $msfile --gen-relay-list SMBtargets_tmp.txt
cat SMBtargets_tmp.txt | sort -n | uniq >  SMBtargets_$msfile
rm  SMBtargets_tmp.txt
crackmapexec smb SMBtargets_$msfile -u '' -p '' |tee -a SMBAttackResults_$msfile
cat SMBAttackResults_$msfile |grep "signing:False"|awk '{print $2}' | sort -n | uniq > SMBVulnerableSystems_$msfile
vulnsystems=$(cat SMBVulnerableSystems_$msfile|wc -l)
echo "***************************************************************"
echo -e " SMB Vulnerable systems: ${RED} $vulnsystems ${NC}"
if [ $vulnsystems > 0 ]; then
    echo -e " ${RED} Check file SMBVulnerableSystems_$msfile ${NC}";
fi


# Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
echo "********************************************************"
echo "Checking SMB vulnerabilities port 445, 139, 137 and 135"; 
#nmap -Pn -n -p445,139,135,137 -vvvv --script=smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -iL $msfile --open --max-hostgroup 16 -oA nmap-SMB_$file
# I tried this but was not working properly. Scans get no progress at some point
#nmap -Pn -n -p445,139,135,137 -vvvv --script="smb-* and not brute" -iL $msfile --open --max-hostgroup 16 -oA nmap-SMB_$file
nmap -Pn -n -p445,139,135,137 -vvvv --script smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -iL $msfile --open --max-hostgroup 16 -oA nmap-SMB_$file

#Check if SMB not signing is enabled  (i.e.  Message signing enabled but not required)
#nmap -Pn -sV -p 139,445 --script=smb-protocols,smb2-security-mode --max-hostgroup 16 -iL SMB_NotSigning.txt -oA SMB_NotSigning_enum

# To check if all in the same nmap is failing or if this needs to be separated:
# nmap -Pn -sV -v --script smb-os-discovery.nse,nbstat.nse -oA nmap-NBT -iL $file --open --max-hostgroup 16
# Port 137 UDP
#sudo nmap -Pn -sU -p 137 --script nbstat.nse -iL ../results/137_all_UDP.ips --max-hostgroup 16 -oA nmap-NBSTAT
filetoscan="137_"$file"_UDP.ips"
nmap -Pn -sU -p 137 --script nbstat.nse -iL ../results/$filetoscan --max-hostgroup 16 -oA nmap-NBSTAT_$file

# Run RDP enumeration using NMAP port hosts in file 3389.ips
#nmap scripts: rdp-enum-encryption,rdp-ntlm-info,rdp-vuln-ms12-020
cd ..; mkdir enumRDP; cd enumRDP
filetoscan="3389_"$file"_TCP.ips" 
echo "********************************************************"
echo "Checking RDP for port 3389 and output to enumRDPALL, enumRDPALL2, enumRDPALL3"; 
#sudo nmap -Pn -p 3389 -Pn -sV -sC -oA enumRDPALL --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
nmap -Pn -p 3389 -Pn -sV -sC --open -vvv -n  -iL ../results/$filetoscan --max-hostgroup 16 -oA enumRDP_$file
#sudo nmap -Pn -p 3389 -Pn -sV -sC --script=rdp-ntlm-info,rdp-vuln-ms12-020 -oA enumRDPALL2 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
# script rdp-enum-encryption lock the nmap command for some specific IP's
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -d -oA enumRDPALL3 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL 3389_all_TCP.ips -oA enumRDPALL3 --max-hostgroup 16
nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL ../results/$filetoscan --max-hostgroup 16 -oA enumRDP2_$file

echo "********************************************************"
echo "Checking for ldap servers ..."
cd ..;mkdir enumLDAP;
# Grep selects only ldap services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/$file"_ipsnports_all.csv" | awk 'BEGIN {FS = ","}; {if ($3=="\"389\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumLDAP/ldap_tmp.txt
cat ./results/$file"_ipsnports_all.csv" | awk 'BEGIN {FS = ","}; {if ($3=="\"636\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq >> ./enumLDAP/ldap_tmp.txt
cat ./enumLDAP/ldap_tmp.txt | sort -n |uniq > ./enumLDAP/ldap_$file
rm ./enumLDAP/ldap_tmp.txt
numservers==$(cat ./enumLDAP/ldap_$file | wc -l)
echo -e "Total servers found: ${RED} $numservers ${NC}"
nmap -p389,636,3268,3269 -Pn -sV --script="ldap* and not brute" -iL ./enumLDAP/ldap_$file -oA ./enumLDAP/ldap_$file

echo "********************************************************"
echo "Checking SMB2 on port 445"; 
echo "This part could take time"; 
cd enumSMB
#sudo nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -oA nmap-vuln -iL $file --open --max-hostgroup 16
nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -iL $msfile --open --max-hostgroup 16 -oA nmap-vuln_$file
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-vuln-conficker.nse,smb-vuln-cve2009-3103.nse,smb-vuln-cve-2017-7494.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-ms17-010.nse,smb-vuln-regsvc-dos.nse -Pn -p445 -oA nmap-SMB2 -iL $file
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-* -Pn -p445 -oA nmap-SMB2 -iL $file
#Not requird. Already included before
#nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse --script="smb-* and not brute" -Pn -p445 -oA nmap-SMB2_$file -iL $file

echo "********************************************************"
echo "Checking MS-SQL port 1433 "; 
cd ..;mkdir enumMSSQL;
cat ./results/$file"_ipsnports_all.csv" | grep "ms-sql" | cut -f 1 -d ","| sed 's/\"//g' | sort -n | uniq > ./enumMSSQL/mssql_$file
# All other scripts require authentication or additional parmameters
nmap -p 1433 -Pn -n -vvvv --script "ms-sql-info" -sV -sC -iL ./enumMSSQL/mssql_$file --max-hostgroup 16 -oA enumSQLALL_$file

# Test certificates used in SQL Servers
echo -e "Checking TLS connections on SQL Servers for ${RED}$numips${NC} IP's using nmap...";
nmap -sV --script=ssl-enum-ciphers -p 1433 -iL ./enumMSSQL/mssql_$file -oA enumMSSQL/nmap_sslenum_1433_$file;


chown -R marevalo:marevalo enumRDP/*
chown -R marevalo:marevalo enumSMB/*
chown -R marevalo:marevalo enumLDAP/*
chown -R marevalo:marevalo enumSQL/*

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




