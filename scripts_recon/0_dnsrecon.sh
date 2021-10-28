#!/bin/bash
# SYNTAX: ./0_dnsrecon.sh -d domain.com
# This script complete some basic DNS checks and stores the results in the file dnsrecon.txt
# Created by M@rc14n0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
declare outfile
declare domain

# First check input for paramaters
validate_parameters()
{
    while getopts "f:hAVS" opt; do
        case $opt in
        # d to receive the domain name to evaluate
        d)  #echo "-d was triggered, Parameter: $OPTARG" >&2
            domain=$OPTARG;
            outfile=dnsrecon.txt
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
echo "dig ns $domain response: "   |tee -a $outfile
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
echo "********************************************************************************************"  |tee $outfile
echo "dnsrecon $domain results: "   |tee -a $outfile
echo "********************************************************************************************"   |tee -a $outfile
dnsrecon -d $domain -a -s -k -w |tee -a $outfile
