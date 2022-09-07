#!/bin/bash
# The script extracts all http and https identified ports and IP's from the resumenmap scripts
# Run discovery tools like curl, cutycapt, feroxbuster, gobuster to get initial information from the website
# Additionally, it completes a web vulnerability scan using nikto, whatweb and nmap
# Important files used by the app from files created with resumenmap*:
#   ./results/*_ipsnports_all.csv => Results of IP's and open ports. 
#       Each line contains an IP and one service identified on it. Example of filename: cdeips.txt.ipsnports_all.csv
#       Example of a line: "10.10.11.112","","4567","tcp","https","","" 
#   Takes the files for each of the ports identified as using http or https in the scan. example:
#   ./results/80_all_TCP.ips
#   ./results/443_all_TCP.ips
#   ./results/ANYPORTHTTP-HTTPS_all_TCP.ips
#
# Script creates these important files:
#   ./enumWEB/http_ips.txt and https_ips.txt  => contains IP port# by line for the identified IP's using http or https
#   ./enumWEB/httpports.txt and httpports.txt => contains the list of ports identified as having http or https servers
#   ./enumWEB/Cutycapt*.png => screenshots for all http/https servers
#   ./enumWEB/nikto_*, gobuster_*, feroxbuster_*, whatweb_*   => Results of nikto for each server-port found
######################################################################################
# TODO:
#   - Adjust resumenmap or take the right source to identify http ports. resumenmap was not detecting -sV, so after adjusted it needs to be checked....
#   - Include TLS validation for other ports using SSL like 3389, 1433. 25
######################################################################################
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
mkdir enumWEB/img;
mkdir enumWEB/whatweb;
mkdir enumWEB/nikto;
mkdir enumWEB/dirbuster;
mkdir enumWEB/ssl;
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
totalports2=$(cat ./enumWEB/httpsports.txt |wc -l)
echo -e "HTTPS Ports stored in file ${GREEN} ./enumWEB/httpsports.txt: ${NC} ${RED}($totalports2)${NC} "

echo "####################################################################"
echo -e "           ${GREEN}CHECKING HTTP SERVERS ${NC}"
# This file is used to register the list of IP and port using http (without encryption)
if test -e ./enumWEB/http_ips.txt; then
    rm ./enumWEB/http_ips.txt; 
fi
if test -e ./enumWEB/https_ips.txt; then
    rm ./enumWEB/https_ips.txt; 
fi
touch ./enumWEB/http_ips.txt
touch ./enumWEB/https_ips.txt
# A loop to read the file storing the IP's with the specific port open
indexport=1
# Change if it is required to start in a differeent point for any specific port. Only works for one
gappoint=0
gapport=80
gapstartpoint=0
for port in $(cat ./enumWEB/httpports.txt); do
    filename=$port"_all_TCP.ips"
    cp ./results/$filename ./enumWEB/
    numips=$(cat ./results/$filename | wc -l)
    echo "####################################################################"
    echo -e "## Checking port ${GREEN}$port${NC} ($indexport out of $totalports) for a total of ${RED}$numips${NC} IP's in file: ${GREEN} $filename ${NC} ###"
    echo -e "## Running curl, cutycapt, gobuster, Whatweb and Nikto for all IP's"
    # Counter to go through all IP's in this port
    indexip=1
    for ip in $(cat ./enumWEB/$filename); do 
        #Should ignore it?
        if [ $gappoint -eq 1 ]; then 
            echo "Ignoring IP $ip on port $port"
            #Last IP to ignore
            if [ $gapstartpoint -eq $indexip ]; then 
                gappoint=0; 
                echo "This was the last ignored IP for port $port"; 
            fi
        else  
            echo -e "${GREEN}####################################################################"
            echo -e "##                    Checking IP $ip  ($indexip out of $numips)"
            echo -e "####################################################################${NC}"
            #Add the IP and port to the file
            echo "$ip $port" >> ./enumWEB/http_ips.txt;

            #Check if the IP has a defined hostname in the DNS. If "not found" is not received in the anseer (grep result is empty), it means a hostname exist for the IP
            nodnsname=$(host $ip|grep "not found")
            #If nodnsname is empty, means it does not have a "not found" => it has a hostname in the DNS
            if test -z "$nodnsname"; then urlname=$(host $ip | cut -f 5 -d " " | sed "s/\.$//g"); else urlname=""; fi
            echo -e "Capturing a screenshot for ${GREEN}http://$ip:$port/${NC} with cutycapt"; 
                cutycapt --url=http://$ip:$port --out=./enumWEB/img/Cutycapt_$ip-$port.png
                # If urlname is not empty then tries to capture the webpage using the name
                if test -z $urlname; then
                    echo "No name was found in the DNS for $ip"; 
                else
                    #Hostname exist then check using it
                    echo -e "Capturing a screenshot for ${GREEN}http://$urlname:$port/${NC} with cutycapt"; 
                    cutycapt --url=http://$urlname:$port --out=./enumWEB/img/Cutycapt_$ip-$port-$urlname.png;
                fi

            echo "----------------------------------------------------------------------------------------------------------------------------------------"
            echo -e "Validating ${GREEN}http://$ip:$port/${NC} with WhatWeb"; 
                if test -z "$urlname"; then
                    #Hostname does not exist, then checks using the IP only
                    whatweb -a 3 -v $ip:$port --log-verbose=enumWEB/whatweb/whatweb_http_$ip-$port.txt;
                else
                    #Hostname exists then check using it
                    whatweb -a 3 -v $urlname:$port --log-verbose=enumWEB/whatweb/whatweb_http_$ip-$port.txt;
                fi

            echo "----------------------------------------------------------------------------------------------------------------------------------------"
            echo -e "Testing ${GREEN}http://$ip:$port/${NC} with Nikto"; 
                if test -z "$urlname"; then
                    #Hostname does not exist, then checks using the IP only
                    nikto -ask no -host $ip -p $port -o enumWEB/nikto/nikto_http_$ip-$port.csv -maxtime 200s
                else
                    #Hostname exists then check using it
                    nikto -ask no -host $urlname -p $port -o enumWEB/nikto/nikto_http_$ip-$port.csv -maxtime 200s
                fi


            echo "----------------------------------------------------------------------------------------------------------------------------------------"
            echo -e "Checking for interesting directories in ${GREEN}http://$ip:$port/${NC} with GoBuster"; 
                #https://www.hackingarticles.in/comprehensive-guide-on-gobuster-tool/
                #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 20 -x txt,php -u http://$ip:$port/
                #Additional options: -s 200 filter to check only status 200 pages, -to 10s timeout 10 seconds
                if test -z "$urlname"; then
                    #Hostname does not exist, then checks using the IP only
                    #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -t 20 -u http://$ip:$port/ -o enumWEB/gobuster_http_$ip-$port.txt;
                    #Small initially
                    gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -q -e -t 20 -u http://$ip:$port/ -o enumWEB/dirbuster/gobuster_http_$ip-$port.txt;
                else
                    #Hostname exists then check using it
                    #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -e -t 20 -u http://$urlname:$port/ -o enumWEB/gobuster_http_$ip-$port-$urlname.txt;
                    #Small initially
                    gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -q -e -t 20 -u http://$urlname:$port/ -o enumWEB/dirbuster/gobuster_http_$ip-$port-$urlname.txt;
                fi

            echo "----------------------------------------------------------------------------------------------------------------------------------------"
            #echo -e "Checking for interesting directories in ${GREEN}http://$ip:$port/${NC} with FeroxBuster"; 
            #    # Additional opts: -t threads, -d deep level, --silent prints only the URL's
            #        #-C 404 or --filter-status 400 Filter out / ignore 404 responses
            #        #-x php  #extenstions php or pdf or aspx or js (php,pdf)
            #        #--filter-regex '^ignore me$'
            #        #--filter-similar-to http://site.xyz/soft404
            #        #-H, --headers <HEADER> ex: -H Accept:application/json "Authorization: Bearer {token}"
            #        #--insecure --proxy http://127.0.0.1:8080
            #        #cat targets | feroxbuster --stdin --silent -s 200 301 302 --redirects -x js | fff -s 200 -o js-files
            #        #-w, --wordlist <FILE> 
            #    if test -z "$urlname"; then
            #        #Hostname does not exist, then checks using the IP only
            #        feroxbuster --url http://$ip:$port -o ./enumWEB/feroxbuster_http_$ip-$port.txt -t 20 -d 3 --silent
            #    else
            #        #Hostname exists then check using it
            #        feroxbuster --url http://$urlname:$port -o ./enumWEB/feroxbuster_http_$ip-$port-$urlname.txt -t 20 -d 3 --silent
            #    fi
            echo -e "${GREEN}####################################################################"
            echo -e "###          HTTP validation completed for IP $ip  ($indexip out of $numips)"
        fi
        indexip=$(($indexip+1))
    done
    echo -e "${GREEN}################################################################################################"
    echo -e "###       HTTP validation completed on PORT $port!  ($indexport out of $totalports ports)       ###"
    indexport=$(($indexport+1))
    echo -e "################################################################################################${NC}"
done

echo "####################################################################"
echo "                  Checking HTTPS servers "
echo "####################################################################"
indexport2=1
gappoint2=0
gapport2=443
gapstartpoint2=0
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips";
    cp ./results/$filename ./enumWEB/;
    numips=$(cat ./results/$filename | wc -l);
    echo -e "${GREEN}####################################################################"
    echo -e "Checking port  ${RED}($port)${NC} ($indexport2 out of $totalports2) for discovered IP's: ${RED}($numips)${NC} in file: ${GREEN} $filename ${NC}";
    if [ $port -ne 3389 ]; then 
        echo -e "Running curl, cutycpat, gobuster, Whatweb and Nikto for all IP's";
        echo "####################################################################";
        indexip2=1
        #If required to start in a different possition just change here this value
        startpoint2=0
        for ip in $(cat ./results/$filename); do 
            #Should ignore it?
            if [ $gappoint2 -eq 1 ]; then 
                echo "Ignoring IP $ip on port $port"
                #Last IP to ignore
                if [ $gapstartpoint2 -eq $indexip2 ]; then 
                    gappoint2=0; 
                    echo "This was the last ignored IP for port $port"; 
                fi
            else  
                echo -e "${GREEN}####################################################################"
                echo -e "##                    Checking IP $ip  ($indexip2 out of $numips)"
                echo -e "####################################################################${NC}"
                #Add the IP and port to the file
                echo "$ip $port" >> ./enumWEB/https_ips.txt;
                #Check if the IP has a defined hostname in the DNS. If "not found" is not received in the anseer (grep result is empty), it means a hostname exist for the IP
                nodnsname=$(host $ip|grep "not found")
                #If nodnsname is empty, means it does not have a "not found" => it has a hostname in the DNS
                if test -z "$nodnsname"; then urlname=$(host $ip | cut -f 5 -d " " | sed "s/\.$//g"); else urlname=""; fi
                echo -e "Capturing a screenshot for ${GREEN}https://$ip:$port/${NC} with cutycapt"; 
                    cutycapt --url=https://$ip:$port --out=./enumWEB/img/Cutycapt_$ip-$port.png --insecure;
                    # If urlname is not empty then tries to capture the webpage using the name
                    if test -z "$urlname"; then
                        echo "No name was found in the DNS for $ip"; 
                    else
                        #Hostname exist then check using it
                        echo -e "Capturing a screenshot for ${GREEN}https://$urlname:$port/${NC} with cutycapt"; 
                        cutycapt --url=https://$urlname:$port --out=./enumWEB/img/Cutycapt_$ip-$port-$urlname.png --insecure;
                    fi

                echo "----------------------------------------------------------------------------------------------------------------------------------------"
                    if test -z "$urlname"; then
                        echo -e "Validating ${GREEN}https://$ip:$port/${NC} with WhatWeb"; 
                        #Hostname does not exist, then checks using the IP only
                        whatweb -a 3 --url-prefix https://  $ip:$port | tee -a enumWEB/whatweb/whatweb_https_$ip-$port.txt
                    else
                        #Hostname exists then check using it
                        echo -e "Validating ${GREEN}https://$urlname:$port/${NC} with WhatWeb"; 
                        whatweb -a 3 --url-prefix https://  $urlname:$port | tee -a enumWEB/whatweb/whatweb_https_$ip-$port-$urlname.txt
                    fi

                echo "----------------------------------------------------------------------------------------------------------------------------------------"
                    if test -z "$urlname"; then
                        echo -e "Testing ${GREEN}https://$ip:$port/${NC} with Nikto"; 
                        #Hostname does not exist, then checks using the IP only
                        nikto -ask no -host $ip -p $port -o enumWEB/nikto/nikto_https_$ip-$port.csv -maxtime 200s
                    else
                        echo -e "Testing ${GREEN}https://$urlname:$port/${NC} with Nikto"; 
                        #Hostname exists then check using it
                        nikto -ask no -host $urlname -p $port -o enumWEB/nikto/nikto_https_$ip-$port-$urlname.csv -maxtime 200s
                    fi

                echo "----------------------------------------------------------------------------------------------------------------------------------------"
                    if test -z "$urlname"; then
                        echo -e "Checking for interesting directories in ${GREEN}https://$ip:$port/${NC} with GoBuster"; 
                        #Hostname does not exist, then checks using the IP only
                        #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -t 20 -k -u https://$ip:$port/ -o enumWEB/gobuster_https_$ip-$port.txt;
                        #Small first
                        gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -q -t 20 -k -u https://$ip:$port/ -o enumWEB/dirbuster/gobuster_https_$ip-$port.txt;
                    else
                        echo -e "Checking for interesting directories in ${GREEN}https://$urlname:$port/${NC} with GoBuster"; 
                        #Hostname exists then check using it
                        #gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -q -t 20 -k -u https://$urlname:$port/ -o enumWEB/dirbuster/gobuster_https_$ip-$port-$urlname.txt;
                        #Small first
                        gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -q -t 20 -k -u https://$urlname:$port/ -o enumWEB/dirbuster/gobuster_https_$ip-$port-$urlname.txt;
                    fi


                echo "----------------------------------------------------------------------------------------------------------------------------------------"
                #    # Additional opts: -t threads, -d deep level, --silent prints only the URL's
                #        #-C 404 or --filter-status 400 Filter out / ignore 404 responses
                #        #-x php  #extenstions php or pdf or aspx or js (php,pdf)
                #        #--filter-regex '^ignore me$'
                #        #--filter-similar-to http://site.xyz/soft404
                #        #-H, --headers <HEADER> ex: -H Accept:application/json "Authorization: Bearer {token}"
                #        #--insecure --proxy http://127.0.0.1:8080
                #        #cat targets | feroxbuster --stdin --silent -s 200 301 302 --redirects -x js | fff -s 200 -o js-files
                #        #-w, --wordlist <FILE> 
                #    if test -z "$urlname"; then
                #        echo -e "Checking for interesting directories in ${GREEN}https://$ip:$port/${NC} with FeroxBuster"; 
                #        #Hostname does not exist, then checks using the IP only
                #        feroxbuster --url https://$ip:$port -o ./enumWEB/feroxbuster_https_$ip-$port.txt -t 20 -d 3 --silent
                #    else
                #        echo -e "Checking for interesting directories in ${GREEN}https://$urlname:$port/${NC} with FeroxBuster"; 
                #        #Hostname exists then check using it
                #        feroxbuster --url https://$urlname:$port -o ./enumWEB/feroxbuster_https_$ip-$port.txt -t 20 -d 3 --silent
                #    fi

                echo -e "${GREEN}####################################################################"
                echo -e "###          HTTPS validation completed for IP $ip  ($indexip2 out of $numips)          ###"
            fi
            indexip2=$(($indexip2+1))
            echo -e "####################################################################${NC}"
        done
    fi
    echo -e "${GREEN}####################################################################"
    echo -e "###         HTTPS validation completed on port $port!  ($indexport2 out of $totalports2)          ###"
    indexport2=$(($indexport2+1))
    echo -e "####################################################################${NC}"
done

indexport3=1
gappoint3=0
gapport3=443
gapstartpoint3=21

echo "####################################################################"
echo -e "          ${GREEN}Checking certificates on HTTPS servers${NC}"
echo "####################################################################"
for port in $(cat ./enumWEB/httpsports.txt); do
    filename=$port"_all_TCP.ips"
    numips=$(cat ./results/$filename | wc -l)
    indexip3=1
    echo -e "Running sslscan, sslyze and openssl for all IP's ${RED}($numips)${NC} in ${GREEN} $filename ${NC}"
    for ip in $(cat ./results/$filename); do 
        if [ $gappoint3 -eq 1 ]; then 
            echo "Ignoring IP $ip on port $port"
            #Last IP to ignore
            if [ $gapstartpoint3 -eq $indexip3 ]; then 
                gappoint3=0; 
                echo "This was the last ignored IP ($ip) on port $port"; 
            fi
        else  
            #Check if the IP has a defined hostname in the DNS. If "not found" is not received in the anseer (grep result is empty), it means a hostname exist for the IP
            nodnsname=$(host $ip|grep "not found")
            #If nodnsname is empty, means it does not have a "not found" => it has a hostname in the DNS
            if test -z "$nodnsname"; then urlname=$(host $ip | cut -f 5 -d " " | sed "s/\.$//g"); else urlname=""; fi
            #Hostname does not exist, then checks using the IP only
            echo "####################################################################"
            echo -e "${GREEN}Checking certificate with sslscan using IP $ip${NC}"; 
            echo "####################################################################"
            sslscan --show-certificate --connect-timeout=30s --bugs $ip:$port | tee -a enumWEB/ssl/sslscan_$ip-$port.txt

            #I used timeout for this scan as it is taking too much time
            #echo "####################################################################"
            #echo -e "${GREEN}Checking certificate with sslyze using IP $ip${NC}"; 
            #echo "####################################################################"
            timeout 30s sslyze --json_out=enumWEB/ssl/sslyzeresults_$ip-$port.json --robot --sslv2 --sslv3 --tlsv1_1 --tlsv1_2 --tlsv1_3  --certinfo --reneg --openssl_ccs --heartbleed --fallback --http_headers $ip:$port| tee -a enumWEB/ssl/sslyze_$ip-$port.txt

            #Exporting the certificate: openssl s_client -connect {HOSTNAME}:{PORT} -showcerts
            #This command is getting longer in some websites until an enter is hit
            echo "####################################################################"
            echo -e "${GREEN}Checking certificate with openssl using IP $ip${NC}"; 
            echo "####################################################################"
            timeout 15s openssl s_client -connect $ip:$port -showcerts | tee -a enumWEB/ssl/certificate_$ip-$port.txt
            #echo -e "Checking support to TLSv1.0 with s_client using IP $ip"; 
            #openssl s_client -connect $ip:$port -tls1 | tee -a enumWEB/tlsv1_$ip-$port.txt

            # A hostname is found for the IP in the dns
            if test -n "$urlname"; then
                #Hostname exists then check using it
                echo "####################################################################"
                echo -e "${GREEN}Checking certificate with sslscan using name $urlname${NC}"; 
                echo "####################################################################"
                sslscan --show-certificate --connect-timeout=30s --bugs $urlname:$port | tee -a enumWEB/ssl/sslscan_$ip-$urlname-$port.txt

                #echo "####################################################################"
                #echo -e "${GREEN}Checking certificate with sslyze using name $urlname${NC}"; 
                #echo "####################################################################"
                timeout 30s sslyze --json_out=enumWEB/ssl/sslyzeresults_$ip-$urlname-$port.json --robot --sslv2 --sslv3 --tlsv1_1 --tlsv1_2 --tlsv1_3  --certinfo --reneg --openssl_ccs --heartbleed --fallback --http_headers $urlname:$port| tee -a enumWEB/ssl/sslyze_$ip-$urlname-$port.txt

                #Exporting the certificate: openssl s_client -connect {HOSTNAME}:{PORT} -showcerts
                echo "####################################################################"
                echo -e "${GREEN}Checking certificate with openssl using name $urlname${NC}"; 
                echo "####################################################################"
                timeout 15s openssl s_client -connect $urlname:$port -showcerts | tee -a enumWEB/ssl/certificate_$ip-$urlname-$port.txt
                #echo -e "Checking support to TLSv1.0 with s_client using name $urlname"; 
                timeout 15s openssl s_client -connect $urlname:$port -tls1 | tee -a enumWEB/tlsv1_$ip-$urlname-$port.txt
            fi
            echo -e "${GREEN}###############################################################################################${NC}"
            echo -e "###       Certificates validation completed for IP ${RED}$ip  ($indexip3 out of $numips)${NC}        ###"
        fi
        indexip3=$(($indexip3+1))
    done
    echo -e "${GREEN}####################################################################"
    echo -e "###     Certificates validation completed on port $port!  ($indexport3 out of $totalports3) "
    echo -e "####################################################################${NC}"
    indexport3=$(($indexport3+1))
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
for filenmap in $(ls ./*.nmap); do
    if (( $(cat $filenmap | grep  TLSv1.0 | wc -l) != 0 )) ; then 
        cat $filenmap >> ./enumWEB/tls1.0.txt;
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
    nmap -sV --script=ssl-enum-ciphers,ssl-ccs-injection.nse,ssl-dh-params.nse,ssl-date.nse,ssl-dh-params.nse,ssl-heartbleed.nse,ssl-known-key.nse,ssl-poodle.nse,sslv2-drown.nse,sslv2.nse --max-hostgroup 16 -p $port -iL ./results/$filename -oA enumWEB/ssl/nmap_sslenum_$port
done


echo "####################################################################"
echo "All checks has being completed"
echo "####################################################################"



##### ADDITIONAL THINGS TO DO WITH WEBSITES DISCOVERED
#HYDRA
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
