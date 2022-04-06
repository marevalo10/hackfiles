#!/bin/bash
# This script runs different tests related with NMB / Microsoft services (RDP, LDAP) withput credentials
# It uses: enum4linux, smbmap, rpcdump, nbtscan, crackmapexec smb, nmap scripts for smb and rdp 
#       sudo ./4_enumSMB_new.sh
# It takes the consolidated file ./results/445_all_TCP.ips created by 3_preparefiles_new as input
# and runs enum4linux and rpcdump on all hosts identified with port 445 open
# It runs nmap with rdpenum script for all host with port 3389 open
# It requires enum4linux instaled and available in the running path
# TODO:
#   enum SQL
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [[ "$EUID" != 0 ]]; then
        username=$(whoami);
        echo "$username, please run it as sudo $0";
        exit 0;
fi

echo "***************************************************************"
echo -e " STARTING ${GREEN}enumSMB${NC} SCRIPT"
# Check possible issues on port 135,137,139 and 445 using enum4linux, smbmap with empty credentials, rpcdump, and nbtscan
mkdir enumSMB;
file=smb_all_TCP.ips
#Join all the IP's with SMB related open ports
cd results
cat 135_all_*.ips 137_all_*.ips 139_all_*.ips 445_all_*.ips | sort -n | uniq > $file
cp $file ../enumSMB; cd ../enumSMB
totalips=(`cat $file|wc -l`)
echo -e "Total IP's to validate: ${GREEN}$totalips${NC}"
echo "***************************************************************"
for ip in $(cat $file); do 
    filename="enum4_"$ip".txt"
    echo "***************************************************************"
    echo "Checking IP: "$ip" using enum4linux saving into file $filename"; 
    echo "***************************************************************"
    # https://highon.coffee/blog/enum4linux-cheat-sheet/
    # -a includes: -U -S -G -P -r -o -n -I
    enum4linux -a $ip | tee -a $filename 

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
crackmapexec smb $file --gen-relay-list SMBtargets.txt
crackmapexec smb SMBtargets.txt -u '' -p '' |tee -a SMBAttackResults.txt

# Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
echo "********************************************************"
echo "Checking SMB vulnerabilities port 445, 139, 137 and 135"; 
#sudo nmap -Pn -n -p445,139,135,137 -vvvv --script=smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -oA nmap-SMB -iL $file --open --max-hostgroup 16
nmap -Pn -n -p445,139,135,137 -vvvv --script=smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-vuln-ms17-010 -oA nmap-SMB -iL $file --open --max-hostgroup 16

# To check if all in the same or it is needed to separate this part:
# nmap -Pn -sV -v --script smb-os-discovery.nse,nbstat.nse -oA nmap-NBT -iL $file --open --max-hostgroup 16
# Port 137 UDP
#sudo nmap -Pn -sU -p 137 --script nbstat.nse -iL ../results/137_all_UDP.ips --max-hostgroup 16 -oA nmap-NBSTAT
nmap -Pn -sU -p 137 --script nbstat.nse -iL ../results/137_all_UDP.ips --max-hostgroup 16 -oA nmap-NBSTAT

# Run RDP enumeration using NMAP port hosts in file 3389.ips
#nmap scripts: rdp-enum-encryption,rdp-ntlm-info,rdp-vuln-ms12-020
cd ..; mkdir enumRDP;  
cp ./results/3389_all_TCP.ips ./enumRDP/; cd enumRDP
echo "********************************************************"
echo "Checking RDP for port 3389 and output to enumRDPALL, enumRDPALL2, enumRDPALL3"; 
#sudo nmap -Pn -p 3389 -Pn -sV -sC -oA enumRDPALL --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
nmap -Pn -p 3389 -Pn -sV -sC -oA enumRDPALL --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
#sudo nmap -Pn -p 3389 -Pn -sV -sC --script=rdp-ntlm-info,rdp-vuln-ms12-020 -oA enumRDPALL2 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
# script rdp-enum-encryption lock the nmap command for some specific IP's
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -d -oA enumRDPALL3 --open -vvv -n  -iL 3389_all_TCP.ips --max-hostgroup 16
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL 3389_all_TCP.ips -oA enumRDPALL3 --max-hostgroup 16
nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL 3389_all_TCP.ips -oA enumRDPALL3 --max-hostgroup 16

echo "********************************************************"
echo "Checking for ldap servers ..."
cd ..;mkdir enumLDAP;
# Grep selects only ldap services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"389\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumLDAP/ldap.txt
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"636\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq >> ./enumLDAP/ldap.txt
numservers==$(cat ./enumLDAP/ldap.txt | wc -l)
echo -e "Total servers found: ${RED} $numservers ${NC}"
nmap -p389,636,3268,3269 -Pn -sV --script="ldap* and not brute" -iL ./enumLDAP/ldap.txt -oA ./enumLDAP/ldap_all

echo "********************************************************"
echo "Checking SMB2 on port 445"; 
echo "This part could take time"; 
cd enumSMB
#sudo nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -oA nmap-vuln -iL $file --open --max-hostgroup 16
nmap -Pn -n -p445,139,135,137 -vvvv --script vuln -oA nmap-vuln -iL $file --open --max-hostgroup 16
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-vuln-conficker.nse,smb-vuln-cve2009-3103.nse,smb-vuln-cve-2017-7494.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-ms17-010.nse,smb-vuln-regsvc-dos.nse -Pn -p445 -oA nmap-SMB2 -iL $file
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-* -Pn -p445 -oA nmap-SMB2 -iL $file
nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse --script="smb-* and not brute" -Pn -p445 -oA nmap-SMB2 -iL $file
#Previous command adjusted to not run smb-brute
cd ..
#sudo chown -R marevalo:marevalo enumRDP/*
chown -R marevalo:marevalo enumRDP/*
#sudo chown -R marevalo:marevalo enumSMB/*
chown -R marevalo:marevalo enumSMB/*
#sudo chown -R marevalo:marevalo enumLDAP/*
chown -R marevalo:marevalo enumLDAP/*

echo ""; 
echo "********************************************************"
echo "ENUM MS FINISHED"; 
echo "Results at enumRDP/, enumSMB/ and enumLDAP/"; 
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




