#!/bin/bash
#Run nikto, whatweb and nmap to all hosts and ports identified as http
#The script extract all ports from the results created by 3_preparefiles_new.sh
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

mkdir enumWEB;
echo "Selecting ports identified as http and https services in the scan"
# Grep selects only http services and not https (-v). awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep http | grep -v ssl | grep -v https | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpports.txt
# Selects https ports observed in the result of enumTCP 
cat ./results/*_ipsnports_all.csv | grep 'https\|ssl' | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpsports.txt

echo "####################################################################"
echo "Checking HTTP servers on identified ports using Whatweb and Nikto..."
# This file is used to register the list of IP and port using http (without encryption)
rm ./enumWEB/http_ips.txt; touch ./enumWEB/http_ips.txt
for port in $(cat ./enumWEB/httpports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    echo "Running Whatweb and Nikto for all IP's ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ip in $(cat ./results/$filename); do 
        echo "Testing $ip port $port with WhatWeb"; 
        #Add the IP and port to the file
        echo "$ip $port" >> ./enumWEB/http_ips.txt;
        cutycapt --url=http://$ip:$port --out=./enumWEB/Screenshot_$ip-$port.png
        whatweb -a 3 $ip | tee enumWEB/whatweb_http_$ip-$port.txt;
        nikto -host $ip -p $port -o enumWEB/nikto_http_$ip-$port.csv -maxtime 300
    done
done

echo "####################################################################"
echo "Checking HTTPS servers on identified ports using Whatweb and Nikto..."
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    echo -e "Running Whatweb and Nikto for all IP's ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ip in $(cat ./results/$filename); do 
        echo "Testing $ip port $port with WhatWeb"; 
        cutycapt --url=https://$ip:$port --out=./enumWEB/Screenshot_$ip-$port.png --insecure
        whatweb -a 3 --url-prefix https://  $ip:$port | tee enumWEB/whatweb_https_$ip-$port.txt
        nikto -host $ip -p $port -o enumWEB/nikto_https_$ip-$port.csv -maxtime 300
    done
done

echo "####################################################################"
echo "Checking certificates on HTTPS servers"
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    echo -e "Running sslscan and Nikto for all IP's ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ip in $(cat ./results/$filename); do 
        sslscan --show-certificate --bugs $ip:$port | tee enumWEB/sslscan_$ip-$port.txt
        #Exporting the certificate: openssl s_client -connect {HOSTNAME}:{PORT} -showcerts
		openssl s_client -connect $ip:$port -showcerts | tee enumWEB/certificate_$ip-$port.txt
        #Check if the server supports TLSv1.0
        openssl s_client -connect $ip:$port -tls1 | tee enumWEB/tlsv1_$ip-$port.txt
        #if ($port==25) then 
        #openssl s_client -starttls smtp -showcerts -connect $i:25 -servername $i?
        #fi
    done
done
echo "####################################################################"

# Test SSL certificates
echo "Checking TLS connections on HTTPS using nmap..."
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    nmap -sV --script=ssl-enum-ciphers,ssl-ccs-injection.nse,ssl-dh-params.nse,ssl-date.nse,ssl-dh-params.nse,ssl-heartbleed.nse,ssl-known-key.nse,ssl-poodle.nse,sslv2-drown.nse,sslv2.nse -p $port -iL ./results/$filename -oA enumWEB/nmap_sslenum_$port
done
echo "Checking TLS connections on SQL Servers using nmap..."
nmap -sV --script=ssl-enum-ciphers -p 1433 -iL ./results/1433_all_TCP.ips -oA enumWEB/nmap_sslenum_1433


echo "####################################################################"
echo "Checking for printers ..."
mkdir enumPrinters;
# Grep selects only printers services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep '9100\|jetdirect\|printer' | awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumPrinters/printers.txt
numprinters==$(cat ./enumPrinters/printers.txt | wc -l)
echo -e "Total printers found: ${RED} $numprinters)${NC}"
cat ./enumPrinters/printers.txt 

echo "####################################################################"
echo "Checking for email servers ..."
mkdir enumEMAIL;
# Grep selects only smtp services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"25\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumEMAIL/smtp.txt
numemailserverssmtp==$(cat ./enumEMAIL/smtp.txt | wc -l)
echo -e "Total servers found: ${RED} $numemailserverssmtp)${NC}"
cat ./enumEMAIL/smtp.txt
#nmap -p25,587 --script=smtp-commands -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_commands
nmap -p25,587 --script=smtp-* -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_all

echo "####################################################################"
echo "Checking for postgres servers ..."
mkdir enumDB;
# Grep selects only postgres services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"5432\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumDB/postgres.txt
numservers==$(cat ./enumDB/postgres.txt | wc -l)
echo -e "Total servers found: ${RED} $numservers)${NC}"
nmap -p5432 -sV --script=pgsql-* -iL ./enumDB/postgres.txt -oA ./enumDB/postgres_all

echo "####################################################################"
echo "All checks has being completed"
echo "####################################################################"

# Checking insecure TLS
echo "Identifying Files with TLSv1.0 or SSL enabled..."
rm ./enumWEB/tls1.0.txt; touch ./enumWEB/tls1.0.txt
for filename in $(ls ./enumWEB/*.nmap); do
    if (( $(cat $filename | grep  TLSv1.0 | wc -l) != 0 )) ; then 
        cat $filename >> ./enumWEB/tls1.0.txt;
    fi
done

