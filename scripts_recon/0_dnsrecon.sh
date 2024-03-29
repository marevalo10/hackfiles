#!/bin/bash
# SYNTAX: ./0_dnsrecon.sh -d domain.com
# This script complete some basic DNS checks and stores the results in the file dnsrecon.txt
# This script is suposed to be run in an internal network
# Created by M@rc14n0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
declare outfile
declare domain
outfile=dnsrecon.txt

# First check input for paramaters
validate_parameters()
{
    while getopts "d:hAVS" opt; do
        case $opt in
        # d to receive the domain name to evaluate
        d)  #echo "-d was triggered, Parameter: $OPTARG" >&2
            domain=$OPTARG;
            outfile=dnsrecon_$domain.txt
            ;;

        # help
        h)  echo "0_dnsrecon version 0.1";
            echo "";
            echo "A tool to identify which hosts are up using different techniques";
            echo "Please use a file with the segments or IP's wanted to be validated per line (host, range or network).";
            echo "A file with the same name + .hostlist.txt will be created with the list of all IP's found up"
            echo "Created by M@rc14n0"
            echo "";
            echo "SYNTAX: ./0_dnsrecon.sh -d domain.co"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./0_dnsrecon.sh -d domain.co or ./0_dnsrecon.sh -h for help" >&2
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

    # If no -d was specified then it is a mistake
    if [[ $@ != *"-d"* ]] ; then
        echo "ERROR: No target domain was specified!"
        echo "SYNTAX: ./0_dnsrecon.sh -d domain.co or ./0_dnsrecon.sh -h for help" >&2
        exit 1
    fi

    #Check if the outputfile already exists
    if test -d $outfile; then
        echo -e "File "$outfile" already exists and will be overwrotten.... "
        read -p "Are you sure? (y|n): " -n 1 -r; echo -e "\n";
        if [[ $REPLY =~ ^[Yy]$ ]]; 	then
            echo -e "Replacing file "$outfile
        else
            echo -e "Execution cancelled..."
            exit 1
        fi
    else
        echo "Creating file "$outfile
        touch $outfile
    fi

}

# Validates the parameters required
validate_parameters $@

# Runs a dig query to extract the name servers
echo "********************************************************************************************"  |tee $outfile
echo "dig ns $domain response: "   > $outfile
echo "********************************************************************************************"   |tee -a $outfile
dig ns $domain >> $outfile
grep -E "NS.+\.$" $outfile | sed 's/\.$//g' | cut -f 5 > dnsservers.txt
cat dnsservers.txt
index=1
for nameserver in $(cat dnsservers.txt); do 
    echo "********************************************************************************************" |tee -a $outfile
    echo -e "#Checking if the dns server ${GREEN}$nameserver${NC} has transfer zone open "  |tee -a $outfile
    req="@"$nameserver
    dig $req $domain axfr |tee -a $outfile
    echo "********************************************************************************************"  |tee -a $outfile
    index=$(($index+1));
done;
echo -e "Total DNS Servers reviewed: ${GREEN}$index${NC} "  |tee -a $outfile
echo "********************************************************************************************"  |tee -a $outfile

#Run dnsrecon (python)
echo "********************************************************************************************"  |tee -a $outfile
echo "dnsrecon $domain results: "   |tee -a $outfile
echo "********************************************************************************************"   |tee -a $outfile
# -a checks zone transfer, -s runs reverse lookups for names in soa, 
# -k performs crt.sh enumeration to check for public certificates using this domain 
# -w runs a deep whois record analysis and reverse lookups, -z executes a DNSSEC zone walk
dnsrecon -d $domain -a -s -k -w |tee -a $outfile

#Run nmap for dns
echo "********************************************************************************************"  |tee -a $outfile
echo "Running nmap for DNS servers: sudo nmap -p53 -sU -sC -sV --script vuln -i dnsservers.txt "   |tee -a $outfile
echo "********************************************************************************************"   |tee -a $outfile
sudo nmap -p53 -sU -sC -sV --script vuln -i dnsservers.txt -oA nmap_dnsservers

# For each IP in the file (allips.txt) will try to look for a name associated with it
echo "********************************************************************************************"  |tee -a $outfile
echo "Running reverse lookup for each IP in the file allips.txt "   |tee -a $outfile
echo "A file with all IP's (allips.txt) extracted from ips*.txt and hostup_*.txt will be created. "
echo "This file will be used to check if a name is asociated with each IP."
echo "You can also run the script 0_dnsrev.sh specifying the file with all the ips later to complete this process"
dnsserver=$(head -n 1 dnsservers.txt);
echo "Call it using ./0_dnsrev.sh -t targetips.txt -n $dnsserver"
echo "Do you want to continue (y/n)?"
read isready
if [ $isready = 'y' ]; then
    echo "Creating file allips.txt "   |tee -a $outfile;
    cat ips*.txt hostup_*.txt |grep -v "#" |grep -v "/" | sort -u >allips.txt;
    numips=$(cat allips.txt |wc -l);
    echo "A total of $numips will be checked for a associated name"   |tee -a $outfile;
    echo "Output will be saved in file dnsreverseallips.txt "   |tee -a $outfile;
    filename=allips.txt;
    for ip in $(cat $filename); do host $ip $dnsserver | grep pointer|cut -d " " -f 5 |sort -n|uniq | sed "s/\.$/\t$ip/g"; done | tee dnsreverseallipstmp.txt;
    numipsreversed=$(cat dnsreverseallips.txt | wc -l);
    cat dnsreverseallipstmp.txt |sort > dnsreverseallips.txt; rm dnsreverseallipstmp.txt;
    echo "A total of $numipsreversed were found with an associated name!"   |tee -a $outfile;
    echo "Check results in file dnsreverseallips.txt "   |tee -a $outfile;
    echo "********************************************************************************************"   |tee -a $outfile;
else
    echo "No reverse process was completed..."  |tee -a $outfile
fi
echo "********************************************************************************************"  |tee -a $outfile
echo "Batch Process compelted successfully " |tee -a $outfile
echo "********************************************************************************************"   |tee -a $outfile
