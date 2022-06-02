#!/bin/bash
# The script capture screens from each website (http / https) identified
#   Takes the files for each of the ports identified as using http or https in the scan. example:
#   ./results/80_all_TCP.ips
#   ./results/443_all_TCP.ips
#   ./results/ANYPORTHTTP-HTTPS_all_TCP.ips
#
# This script creates these important files:
#   ./enumWEB/eyewitness*.png => screenshots for all http/https servers
#   eyewitness -f /root/urls.txt -d screens
#####################################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if test -d enumWEB; then
        echo -e "Directory enumWEB exists and will be used to store the files. Some of the existing files could be replaced"
        read -p "Are you sure? (y|n): " -n 1 -r; echo -e "\n";
        if [[ $REPLY =~ ^[Yy]$ ]]; 	then
            echo "Starting the script"
        else
            echo -e "Execution cancelled..."
            exit 1
        fi
    else
        echo "Creating directory enumWEB"
        mkdir enumWEB;
    fi

# Creates a file with the servers IP having HTTP and another for HTTPS
echo "####################################################################"
echo "                      WEB SCREENSHOTS CAPTURE "
echo "####################################################################"
echo "Selecting ports identified as http and https services in the scan"
# Grep selects only http services and not https (-v). awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep http | grep -v ssl | grep -v https | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpports.txt
totalports=$( cat ./enumWEB/httpports.txt |wc -l )
echo -e "HTTP Ports stored in file ${GREEN} ./enumWEB/httpports.txt: ${NC} ${RED}($totalports)${NC} "
# Selects https ports observed in the result of enumTCP 
cat ./results/*_ipsnports_all.csv | grep 'https\|ssl' | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpsports.txt
totalports2=$(cat ./enumWEB/httpsports.txt |wc -l)
echo -e "HTTPS Ports stored in file ${GREEN} ./enumWEB/httpsports.txt: ${NC} ${RED}($totalports2)${NC} "

filescreens="./enumWEB/http_urls.ips";
tempfilescreens="./enumWEB/http_urls_temp.ips";
filescreens2="./enumWEB/https_urls.ips";
tempfilescreens2="./enumWEB/https_urls_temp.ips";
# This file is used to register the list of IP and port using http/https
if test -e $filescreens2; then
    rm $filescreens2; 
    rm $tempfilescreens2
fi
touch $filescreens2
touch $tempfilescreens2

#order the file and keep unique URLs
echo -e "${GREEN}####################################################################"
echo -e "###          HTTP validation completed           ###"
echo -e "####################################################################${NC}"

echo ""
echo "####################################################################"
echo "                  Checking HTTPS servers "
echo "####################################################################"
indexport2=1
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips";
    cp ./results/$filename ./enumWEB/;
    numips=$(cat ./enumWEB/$filename | wc -l);
    indexport=$(($indexport+1))
    sed 's/^/https:\/\//' ./enumWEB/$filename | sed 's/$/:'$port'\//' >> $tempfilescreens2;
done

#order the file and keep unique URLs
cat $tempfilescreens2 | sort -d |uniq > $filescreens2
rm $tempfilescreens2
numips=$(cat $filescreens2 | wc -l);
echo "####################################################################"
echo -e "        ${GREEN}TAKING SCREENSHOTS TO HTTPS SERVERS ${NC}"
echo -e "        A total of ${RED} $numips ${NC} will be taken"
eyewitness -f $filescreens2 -d enumWEB/screenshots --no-prompt --timeout 3

echo -e "${GREEN}####################################################################"
echo -e "###          HTTPS validation completed           ###"
echo -e "####################################################################${NC}"




echo "####################################################################"
echo "All ScreenShots has being completed"
echo "####################################################################"

