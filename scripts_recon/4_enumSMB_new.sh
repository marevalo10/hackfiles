#!/bin/bash
#Run enum4linux and rpcdump on all hosts identified with port 445 open
#Takes the file ./results/445_all_TCP.ips created by 3_preparefiles_new as input
#Run nmap with rdpenum script for all host with port 3389 open
#requires enum4linux instaled and available in the running path
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

mkdir enumSMB;
file=445_all_TCP.ips

for ip in $(cat ./results/$file); do 
    echo "********************************************************"
    filename=$ip"_enum4.txt"
    echo "Checking IP: "$ip" using enum4linux saving into file $filename"; 
    enum4linux $ip | tee enumSMB/$filename 
    echo "***************************************************************"
    echo "Checking IP: "$ip" using rpcdump saving into file $filename"; 
    echo "***************************************************************"
    filename=$ip"_rpcdump.txt"
    python3 /usr/share/doc/python3-impacket/examples/rpcdump.py $ip | tee enumSMB/$filename;
    echo "Scan Completed for IP: $ip"; 
done


#Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
#It should be normally in the local network
echo "********************************************************"
echo "Checking vulnerable targets with crackmapexec into file ./enumSMB/SMBtargets.tx"; 
sudo crackmapexec smb ./results/445_all_TCP.ips --gen-relay-list ./enumSMB/SMBtargets.txt
crackmapexec smb ./enumSMB/SMBtargets.txt -u '' -p '' |tee ./enumSMB/SMBAttackResults.txt

#Run SMB enumeration (nmap scripts) using NMAP port hosts in file $file
echo "********************************************************"
echo "Checking SMB vulnerabilities port 445, 139 and 135"; 
sudo nmap -Pn -n -p445,139,135 -vvvv --script=smb-os-discovery,smb-enum-shares,smb-enum-users,smb-enum-sessions,smb-system-info,smb-brute,smb-vuln-ms17-010 -oA enumSMB/nmap-SMB -iL ./results/$file --open 

echo "********************************************************"
echo "Checking SMB2 on port 445"; 
#sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-vuln-conficker.nse,smb-vuln-cve2009-3103.nse,smb-vuln-cve-2017-7494.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-ms17-010.nse,smb-vuln-regsvc-dos.nse -Pn -p445 -oA enumSMB/nmap-SMB2 -iL ./results/$file
sudo nmap -Pn -n -vvvv --script=smb-double-pulsar-backdoor.nse,smb-* -Pn -p445 -oA enumSMB/nmap-SMB2 -iL ./results/$file

#Run RDP enumeration using NMAP port hosts in file 3389.ips
#nmap scripts: rdp-enum-encryption,rdp-ntlm-info,rdp-vuln-ms12-020
mkdir enumRDP;  
echo "********************************************************"
echo "Checking RDP for port 3389"; 
sudo nmap -Pn -p 3389 -Pn -sV -sC -oA enumRDP/enumRDPALL --open -vvv -n  -iL ./results/3389_all_TCP.ips
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-ntlm-info,rdp-vuln-ms12-020 -oA enumRDP/enumRDPALL2 --open -vvv -n  -iL ./results/3389_all_TCP.ips
# script rdp-enum-encryption lock the nmap command for some specific IP's
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -d --max-hostgroup 4 -oA enumRDP/enumRDPALL3 --open -vvv -n  -iL ./results/3389_all_TCP.ips
sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption -iL ./results/3389_all_TCP.ips -oA enumRDP/enumRDPALL2
#sudo nmap -Pn -p 3389 -Pn -sC --script=rdp-enum-encryption 10.70.234.47 10.70.234.149 10.70.234.157 10.70.234.161 10.70.128.68 10.70.128.79 10.64.1.174 10.64.160.238

echo "********************************************************"
echo "Checking for ldap servers ..."
mkdir enumLDAP;
# Grep selects only ldap services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"389\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumLDAP/ldap.txt
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"636\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq >> ./enumLDAP/ldap.txt
numservers==$(cat ./enumLDAP/ldap.txt | wc -l)
echo -e "Total servers found: ${RED} $numservers)${NC}"
nmap -p389,636,3268,3269 -sV --script="ldap* and not brute" -iL ./enumLDAP/ldap.txt -oA ./enumLDAP/ldap_all


echo ""; 
echo "********************************************************"
echo "FINISHED"; 
echo "********************************************************"

sudo chown -R marevalo:marevalo enumRDP/*
sudo chown -R marevalo:marevalo enumSMB/*
sudo chown -R marevalo:marevalo enumLDAP/*