#!/bin/bash
# SYNTAX: ./0_dnsrev.sh -t targetnets.txt -n <ipdns>
# This script complete some basic DNS checks and stores the results in the file dnsrecon.txt
# Created by M@rc14n0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
declare outfile
declare networklist
declare nameserver
outfile=dnsrev.txt

# First check input for paramaters
validate_parameters()
{
    while getopts "d:hAVS" opt; do
        case $opt in
        # t to receive the networklist name to evaluate
        t)  #echo "-t was triggered, Parameter: $OPTARG" >&2
            networklist=$OPTARG;
            ;;

        # n nameserver IP
        n)  echo "-n was triggered, Parameter: $OPTARG" >&2
            nameserver=$OPTARG

        # help
        h)  echo "0_dnsrev version 0.1";
            echo "";
            echo "A tool to identify which hosts are up using different techniques";
            echo "Please use a file with the segments or IP's wanted to be validated per line (host, range or network).";
            echo "A file with the same name + .hostlist.txt will be created with the list of all IP's found up"
            echo "Created by M@rc14n0"
            echo "";
            echo "SYNTAX: ./0_dnsrev.sh -t targetnets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./0_dnsrev.sh -t targetnets.txt or ./0_dnsrev.sh -h for help" >&2
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
        echo "ERROR: No target networklist was specified!"
        echo "SYNTAX: ./0_dnsrev.sh -t targetnets.txt -n <ip_nameserver> or ./0_dnsrev.sh -h for help" >&2
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

#Loop to get each subnet (assuming it is /24 and it comes with 0 at the end
echo "********************************************************************************************" |tee -a $outfile
echo -e "#Checking reverse dns server ${GREEN}$nameserver${NC} "  |tee -a $outfile
for subnet in $(cat $networklist); do 
    echo -e "#Checking subnet ${GREEN}$subnet${NC} "  |tee -a $outfile
    #This expresion extracts the first 3 parts of the network 10.10.10.
    sub=$((echo $subnet | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\.\)\(.\+\)/\1/g'))
    for ip in $(seq 1 254); do host $sub.$ip $nameserver; done |tee dnsreverse.txt
done;
echo "********************************************************************************************"  |tee -a $outfile

# For each IP in the file (allips.txt) will try to look for a name associated with it
#echo "********************************************************************************************"  |tee $outfile
#echo "Running reverse lookup for each IP in the file allips.txt "   |tee -a $outfile
#echo "Output will be saved in file dnsreverseallips.txt "   |tee -a $outfile
#echo "********************************************************************************************"   |tee -a $outfile
#networklist=allips.txt
#for ip in $(cat $networklist); do host $ip $nameserver | grep pointer|cut -d " " -f 5 |sort -n|uniq | sed "s/\.$/\t$ip/g"; done | tee $outfile
