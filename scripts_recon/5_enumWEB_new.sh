#!/bin/bash
# The script extracts all http and https identified ports and IP's from the resumenmap scripts
# Run discovery tools like curl, cutycapt, feroxbuster, gobuster to get initial information from the website
# Additionally, it completes a web vulnerability scan using nikto, whatweb and nmap
# Wordlists:  
# /usr/share/seclists/Discovery/Web-Content/common.txt
# /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt 
######################################################################################
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) 
######################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

mkdir enumWEB;
# Creates a file with the servers IP having HTTP and another for HTTPS
echo "####################################################################"
echo "                      WEB DISCOVERY AND SCAN "
echo "####################################################################"
echo "Selecting ports identified as http and https services in the scan"
# Grep selects only http services and not https (-v). awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep http | grep -v ssl | grep -v https | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpports.txt
totalports=$(cat ./enumWEB/httpports.txt |wc -l)
echo -e "HTTP Ports stored in file ${GREEN} ./enumWEB/httpports.txt: ${NC} ${RED}($totalports)${NC} "
# Selects https ports observed in the result of enumTCP 
cat ./results/*_ipsnports_all.csv | grep 'https\|ssl' | awk 'BEGIN {FS = ","}; {print $3}' | sed 's/\"//g' | sort -n | uniq > ./enumWEB/httpsports.txt
totalports=$(cat ./enumWEB/httpsports.txt |wc -l)
echo -e "HTTPS Ports stored in file ${GREEN} ./enumWEB/httpsports.txt: ${NC} ${RED}($totalports)${NC} "

echo "####################################################################"
echo -e "${GREEN}CHECKING HTTP SERVERS ON IDENTIFIED PORTS ...${NC}"
# This file is used to register the list of IP and port using http (without encryption)
if test -e ./enumWEB/http_ips.txt; then
    rm ./enumWEB/http_ips.txt; 
fi
if test -e ./enumWEB/https_ips.txt; then
    rm ./enumWEB/https_ips.txt; 
fi
touch ./enumWEB/http_ips.txt
touch ./enumWEB/https_ips.txt
echo "####################################################################"
# A loop to read the file storing the IP's with the specific port open
for port in $(cat ./enumWEB/httpports.txt); do
    filename=$port"_all_TCP.ips"
    cp ./results/$filename ./enumWEB/
    numips=$(cat ./results/$filename | wc -l)
    echo "####################################################################"
    echo -e "Checking port ${GREEN}$port${NC} for a total of ${RED}$numips${NC} IP's in file: ${GREEN} $filename ${NC}"
    echo -e "Running curl, cutycpat, gobuster, Whatweb and Nikto for all IP's"
    echo "####################################################################"
    for ip in $(cat ./enumWEB/$filename); do 
        #Add the IP and port to the file
        echo "$ip $port" >> ./enumWEB/http_ips.txt;
        #Check if the IP has a defined hostname in the DNS. If "not found" is not received in the anseer (grep result is empty), it means a hostname exist for the IP
        nodnsname=$(host $ip|grep "not found")
        #If nodnsname is empty, means it does not have a "not found" => it has a hostname in the DNS
        if test -z $nodnsname; then urlname=$(host $ip | cut -f 5 -d " " | sed "s/\.$//g"); else urlname=""; fi
        echo -e "Capturing a screenshot for ${GREEN}http://$ip:$port/${NC} with cutycapt"; 
            cutycapt --url=http://$ip:$port --out=./enumWEB/Cutycapt_$ip-$port.png
            # If urlname is not empty then tries to capture the webpage using the name
            if test -z $urlname; then
                echo "No name was found in the DNS for $ip"; 
            else
                #Hostname exist then check using it
                echo -e "Capturing a screenshot for ${GREEN}http://$urlname:$port/${NC} with cutycapt"; 
                cutycapt --url=http://$urlname:$port --out=./enumWEB/Cutycapt_$ip-$port_$urlname.png;
            fi
        echo "--------------------------------------------------------------------"
        echo -e "Checking for interesting directories in ${GREEN}http://$ip:$port/${NC} with GoBuster"; 
            #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 20 -x txt,php -u http://$ip:$port/
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -t 20 -u http://$ip:$port/ | tee enumWEB/gobuster_http_$ip-$port.txt;
            else
                #Hostname exists then check using it
                gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -t 20 -u http://$urlname:$port/ | tee enumWEB/gobuster_http_$ip-$port.txt;
            fi
        echo "--------------------------------------------------------------------"
        echo -e "Checking for interesting directories in ${GREEN}http://$ip:$port/${NC} with FeroxBuster"; 
            # Additional opts: -t threads, -d deep level, --silent prints only the URL's
                #-C 404 or --filter-status 400 Filter out / ignore 404 responses
                #-x php  #extenstions php or pdf or aspx or js (php,pdf)
                #--filter-regex '^ignore me$'
                #--filter-similar-to http://site.xyz/soft404
                #-H, --headers <HEADER> ex: -H Accept:application/json "Authorization: Bearer {token}"
                #--insecure --proxy http://127.0.0.1:8080
                #cat targets | feroxbuster --stdin --silent -s 200 301 302 --redirects -x js | fff -s 200 -o js-files
                #-w, --wordlist <FILE> 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                feroxbuster --url http://$ip:$port -o ./enumWEB/feroxbuster_http_$ip-$port.txt -t 20 -d 3 --silent
            else
                #Hostname exists then check using it
                feroxbuster --url http://$urlname:$port -o ./enumWEB/feroxbuster_http_$ip-$port.txt -t 20 -d 3 --silent
            fi

        echo "--------------------------------------------------------------------"
        echo -e "Validating ${GREEN}http://$ip:$port/${NC} with WhatWeb"; 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                whatweb -a 3 -v $ip:$port --log-verbose=enumWEB/whatweb_http_$ip-$port.txt;
            else
                #Hostname exists then check using it
                whatweb -a 3 -v $urlname:$port --log-verbose=enumWEB/whatweb_http_$ip-$port.txt;
            fi

        echo "--------------------------------------------------------------------"
        echo -e "Testing ${GREEN}http://$ip:$port/${NC} with Nikto"; 
        echo "Testing $ip port $port with nikto"; 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                nikto -host $ip -p $port -o enumWEB/nikto_http_$ip-$port.csv -maxtime 300
            else
                #Hostname exists then check using it
                nikto -host $urlname -p $port -o enumWEB/nikto_http_$ip-$port.csv -maxtime 300
            fi

        echo -e "                  ${GREEN}HTTP validation completed!${NC} "
        echo "####################################################################"
    done
done

echo "####################################################################"
echo "                  Checking HTTPS servers "
echo "####################################################################"
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    echo -e "Checking port  ${RED}($port)${NC} for discovered IP's: ${RED}($numips)${NC} in file: ${GREEN} $filename ${NC}"
    echo -e "Running curl, cutycpat, gobuster, Whatweb and Nikto for all IP's"
    echo "####################################################################"
    for ip in $(cat ./results/$filename); do 
        #Add the IP and port to the file
        echo "$ip $port" >> ./enumWEB/httpS_ips.txt;
        #Check if the IP has a defined hostname in the DNS. If "not found" is not received in the anseer (grep result is empty), it means a hostname exist for the IP
        nodnsname=$(host $ip|grep "not found")
        #If nodnsname is empty, means it does not have a "not found" => it has a hostname in the DNS
        if test -z $nodnsname; then urlname=$(host $ip | cut -f 5 -d " " | sed "s/\.$//g"); else urlname=""; fi
        echo -e "Capturing a screenshot for ${GREEN}https://$ip:$port/${NC} with cutycapt"; 
            cutycapt --url=https://$ip:$port --out=./enumWEB/Cutycapt_$ip-$port.png
            # If urlname is not empty then tries to capture the webpage using the name
            if test -z $urlname; then
                echo "No name was found in the DNS for $ip"; 
            else
                #Hostname exist then check using it
                echo -e "Capturing a screenshot for ${GREEN}https://$urlname:$port/${NC} with cutycapt"; 
                cutycapt --url=https://$urlname:$port --out=./enumWEB/Cutycapt_$ip-$port_$urlname.png;
            fi


        echo "--------------------------------------------------------------------"
        echo -e "Checking for interesting directories in ${GREEN}https://$ip:$port/${NC} with GoBuster"; 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -t 20 -u https://$ip:$port/ | tee enumWEB/gobuster_https_$ip-$port.txt;
            else
                #Hostname exists then check using it
                gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -t 20 -u https://$urlname:$port/ | tee enumWEB/gobuster_https_$ip-$port.txt;
            fi


        echo "--------------------------------------------------------------------"
        echo -e "Checking for interesting directories in ${GREEN}https://$ip:$port/${NC} with FeroxBuster"; 
            # Additional opts: -t threads, -d deep level, --silent prints only the URL's
                #-C 404 or --filter-status 400 Filter out / ignore 404 responses
                #-x php  #extenstions php or pdf or aspx or js (php,pdf)
                #--filter-regex '^ignore me$'
                #--filter-similar-to http://site.xyz/soft404
                #-H, --headers <HEADER> ex: -H Accept:application/json "Authorization: Bearer {token}"
                #--insecure --proxy http://127.0.0.1:8080
                #cat targets | feroxbuster --stdin --silent -s 200 301 302 --redirects -x js | fff -s 200 -o js-files
                #-w, --wordlist <FILE> 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                feroxbuster --url https://$ip:$port -o ./enumWEB/feroxbuster_https_$ip-$port.txt -t 20 -d 3 --silent
            else
                #Hostname exists then check using it
                feroxbuster --url https://$urlname:$port -o ./enumWEB/feroxbuster_https_$ip-$port.txt -t 20 -d 3 --silent
            fi


        echo "--------------------------------------------------------------------"
        echo -e "Validating ${GREEN}https://$ip:$port/${NC} with WhatWeb"; 

        echo "Testing $ip port $port with nikto"; 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                whatweb -a 3 --url-prefix https://  $ip:$port | tee enumWEB/whatweb_https_$ip-$port.txt
            else
                #Hostname exists then check using it
                whatweb -a 3 --url-prefix https://  $urlname:$port | tee enumWEB/whatweb_https_$ip-$port.txt
            fi


        echo "--------------------------------------------------------------------"
        echo -e "Testing ${GREEN}https://$ip:$port/${NC} with Nikto"; 
            if test -z $urlname; then
                #Hostname does not exist, then checks using the IP only
                nikto -host $ip -p $port -o enumWEB/nikto_https_$ip-$port.csv -maxtime 300
            else
                #Hostname exists then check using it
                nikto -host $urlname -p $port -o enumWEB/nikto_https_$ip-$port.csv -maxtime 300
            fi

        echo -e "                  ${GREEN}HTTPS validation completed!${NC} "
        echo "####################################################################"
    done
done

echo "####################################################################"
echo -e "${GREEN}Checking certificates on HTTPS servers${NC}"
echo "####################################################################"
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    echo -e "Running sslscan, sslyze and openssl for all IP's ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ip in $(cat ./results/$filename); do 
        sslscan --show-certificate --bugs $ip:$port | tee enumWEB/sslscan_$ip-$port.txt
        sslyze --json_out=sslyzeresults.json --robot --sslv2 --sslv3 --tlsv1_1 --tlsv1_2 --tlsv1_3  --certinfo --reneg --openssl_ccs --heartbleed --fallback --http_headers $ip:$port| tee enumWEB/sslyze_$ip-$port.txt
        #Exporting the certificate: openssl s_client -connect {HOSTNAME}:{PORT} -showcerts
		openssl s_client -connect $ip:$port -showcerts | tee enumWEB/certificate_$ip-$port.txt
        #Check if the server supports TLSv1.0
        #openssl s_client -connect $ip:$port -tls1 | tee enumWEB/tlsv1_$ip-$port.txt
        #if ($port==25) then 
        #openssl s_client -starttls smtp -showcerts -connect $i:25 -servername $i?
        #fi
    done
done
# Checking insecure TLS
echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Identifying Files with TLSv1.0 or SSL enabled...${NC}"
if test -e ./enumWEB/tls1.0.txt; then
    rm ./enumWEB/tls1.0.txt;
fi
touch ./enumWEB/tls1.0.txt
for filename in $(ls ./enumWEB/*.nmap); do
    if (( $(cat $filename | grep  TLSv1.0 | wc -l) != 0 )) ; then 
        cat $filename >> ./enumWEB/tls1.0.txt;
    fi
done


echo "####################################################################"

# Test SSL certificates
echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}TLS connections on HTTPS using nmap...${NC}"
echo "####################################################################"
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    nmap -sV --script=ssl-enum-ciphers,ssl-ccs-injection.nse,ssl-dh-params.nse,ssl-date.nse,ssl-dh-params.nse,ssl-heartbleed.nse,ssl-known-key.nse,ssl-poodle.nse,sslv2-drown.nse,sslv2.nse -p $port -iL ./results/$filename -oA enumWEB/nmap_sslenum_$port
done

# Test certificates used in SQL Servers
echo "Checking TLS connections on SQL Servers using nmap...";
if test -e ./results/1433_all_TCP.ips; then
    nmap -sV --script=ssl-enum-ciphers -p 1433 -iL ./results/1433_all_TCP.ips -oA enumWEB/nmap_sslenum_1433;
fi


echo ""
echo ""
echo "####################################################################"
echo "${GREEN}Checking for printers ...${NC}"
echo "####################################################################"
mkdir enumPrinters;
# Grep selects only printers services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | grep '9100\|jetdirect\|printer' | awk 'BEGIN {FS = ","}; {print $1}' | sed 's/\"//g' | sort -n | uniq > ./enumPrinters/printers.txt
numprinters==$(cat ./enumPrinters/printers.txt | wc -l)
echo -e "Total printers found: ${RED} $numprinters${NC}. Check them manually in the file ./enumPrinters/printers.txt"
echo "####################################################################"


echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for email servers ...${NC}"
echo "####################################################################"
mkdir enumEMAIL;
# Grep selects only smtp services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"25\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumEMAIL/smtp.txt
numemailserverssmtp=$(cat ./enumEMAIL/smtp.txt | wc -l)
echo -e "Total servers found: ${RED} $numemailserverssmtp${NC}"
cat ./enumEMAIL/smtp.txt
#nmap -p25,587 --script=smtp-commands -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_commands
nmap -p25,587 --script=smtp-* -iL ./enumEMAIL/smtp.txt -oA ./enumEMAIL/smtp_all

echo ""
echo ""
echo "####################################################################"
echo -e "${GREEN}Checking for postgres servers ...${NC}"
mkdir enumDB;
# Grep selects only postgres services. awk extract only the third field (port). sed removes the " symbol. Sort them by number and unique ports
cat ./results/*_ipsnports_all.csv | awk 'BEGIN {FS = ","}; {if ($3=="\"5432\"") {print $1}}' | sed 's/\"//g' | sort -n | uniq > ./enumDB/postgres.txt
numservers==$(cat ./enumDB/postgres.txt | wc -l)
echo -e "Total Postgres servers found: ${RED} $numservers${NC}"
nmap -p5432 -sV --script=pgsql-* -iL ./enumDB/postgres.txt -oA ./enumDB/postgres_all


echo "####################################################################"
echo "All checks has being completed"
echo "####################################################################"



##### ADDITIONAL THINGS TO DO WITH WEBSITES DISCOVERED
HYDRA
#Error message is different when the logins is wrong / password is wrong. => Brute force attack to identify logins
#hydra -L ./fsocity.dic -p test $target http-post-form "/wp-login.php:log=^USER^&pwd=^PASS^:Invalid username" -t 64
#After identifying a valid user, then the password
#hydra -l elliot -P./fsocity.dic -p test $target http-post-form "/wp-login.php:log=^USER^&pwd=^PASS^:The password you entered for " -t 64
#An example using a different port and additional features
#hydra -l admin -P /usr/share/seclists/Passwords/darkweb2017-top10000.txt $target -s 8080 http-post-form "/j_acegi_security_check:j_username=^USER^&j_password=^PASS^&from=%2F&Submit=Sign+in:Invalid username" -t 64
#To restore the session:
#hydra -R

#I used turbointruder in Burp. The password field needs a %s t be replaced


#Now enter and edit apparence and mdify any php file to include the php reverse shell and then call it:
#http://10.10.62.92/wp-content/themes/twentyfifteen/archive.php

#Nikto -Tuning x performs all scans except the specified after x
#nikto -host $target -Tuning x -Cgidirs all -o nikto_$target -F txt


#Wordpress Installed
#nmap -p80 --script http-wordpress-* $target

#/usr/share/seclists/Discovery/Web-Content/CMS/wp-plugins.fuzz.txt
#/usr/share/seclists/Discovery/Web-Content/CMS/wp-themes.fuzz.txt

#wpscan  --api-token loR9MI0vB1rVoo4VrdgridHFflJsjt3wNaaRBgjOsMM --url http://$target/wordpress --enumerate u  --passwords /usr/share/wordlists/rockyou.txt  

#Look for vuln plugings (vp) and enumerate users
#wpscan --url http://$target/blog -e vp,u

#If a user is found then:
#wpscan --url http://$target/blog --usernames admin --passwords /usr/share/wordlists/rockyou.txt --max-threads 50

#When you have access to the wp console, then php pages can be modified to include a reverse shell

#Vulns:
#nmap -p 80 -sC -sV --script vuln $target -oA $machinename/nmap_vulns80_$target
