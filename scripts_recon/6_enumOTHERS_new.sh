#!/bin/bash
# The script extracts some popular ports and the IP's gathered in resumenmap scripts
# Run additional tools aginst these ports to identify vulns or to gather additiional information
#       sudo ./6_enumOTHERS_new.sh -f targets.txt
#
######################################################################################
# TODO:
######################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

mkdir enumOTHERS;
echo "####################################################################"
echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for printers ...${NC}"
echo "####################################################################"
mkdir enumPrinters;
# Grep selects only printers services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep '9100\|jetdirect\|printer' | awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumPrinters/printers.txt
numprinters==$(cat ./enumPrinters/printers.txt | wc -l)
echo -e "Total printers found: ${RED} $numprinters${NC}. "
echo "Check printers manually in the file ./enumPrinters/printers.txt"
echo "####################################################################"


echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for email servers ...${NC}"
echo "####################################################################"
mkdir enumEMAIL;
# Grep selects only smtp services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep smtp | awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumEMAIL/smtp.txt
numemailservers=$(cat ./enumEMAIL/smtp.txt | wc -l)
echo -e "Total servers found: ${RED} $numemailservers${NC}"
cat ./enumEMAIL/smtp.txt
#nmap -p25,587 --script=smtp-commands -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_commands
nmap -p25,587 --script=smtp-* -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_all

echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for postgres servers ...${NC}"
mkdir enumDB;
# Grep selects only postgres services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($5=="\"postg\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumDB/postgres.txt
numservers==$(cat ./enumDB/postgres.txt | wc -l)
echo -e "Total Postgres servers found: ${RED} $numservers${NC}"
nmap -p5432 -sV --script=pgsql-*,auth,vuln,version -iL ./enumDB/postgres.txt -oA ./enumDB/postgres_all


echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for mysql servers ...${NC}"
mkdir enumDB;
# Grep selects only postgres services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($5=="\"mysql\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumDB/mysql.txt
ports=$(cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($5=="\"mysql\"") {print $3}}' | sed 's/\"//g' | sort -n | uniq | tr '\r\n' ',')
numservers==$(cat ./enumDB/mysql.txt | wc -l)
echo -e "Total Postgres servers found: ${RED} $numservers${NC}"
nmap -p$ports -sV --script="mysql-* and not ftp-brute and not ftp-bounce" --script=vuln,version -iL ./enumDB/mysql.txt -oA ./enumDB/mysql_all

echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for FTP servers ...${NC}"
mkdir enumOTHERS;
# Grep selects only FTP services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep "ftp" |awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumOTHERS/ftp.txt
ports=$(cat ./results/*_ipsnports_all.csv | grep "ftp" |awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq | tr '\r\n' ',')
numservers=$(cat ./enumOTHERS/ftp.txt | wc -l)
echo -e "Total ftp servers found: ${RED} $numservers${NC}"
if [ $numservers -gt 0 ]; then
    nmap -p$ports -sV --script "ftp-* and not brute" -iL ./enumOTHERS/ftp.txt -oA ./enumOTHERS/ftp_all
fi


echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for TFTP servers ...${NC}"
mkdir enumOTHERS;
# Grep selects only TFTP services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep "tftp" |awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumOTHERS/tftp.txt
ports=$(cat ./results/*_ipsnports_all.csv | grep "tftp" |awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq | tr '\r\n' ',')
numservers=$(cat ./enumOTHERS/tftp.txt | wc -l)
echo -e "Total tftp servers found: ${RED} $numservers${NC}"
if [ $numservers -gt 0 ]; then
    nmap -p$ports -sV --script tftp-enum -iL ./enumOTHERS/tftp.txt -oA ./enumOTHERS/tftp_all
fi

echo "####################################################################"
echo "All checks has being completed"
echo "####################################################################"
