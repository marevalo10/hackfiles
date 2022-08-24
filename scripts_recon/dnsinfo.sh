#!/bin/bash
# SYNTAX: ./dnsinfo.sh -d domain.com
# This script complete some basic DNS checks and stores the results in the file dnsinfo_<domainname>.txt
# This script is suposed to be run during external pentest
# Created by M@rc14n0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
declare outfile
declare DOMAIN
USERNAME=`whoami`
# First check input for paramaters
validate_parameters()
{
    while getopts "d:hAVS" opt; do
        case $opt in
        # d to receive the domain name to evaluate
        d)  #echo "-d was triggered, Parameter: $OPTARG" >&2
            DOMAIN=$OPTARG;
            outfile=dnsinfo_$DOMAIN.txt
            ;;

        # help
        h)  echo "dnsinfo version 0.1";
            echo "";
            echo "A tool to identify basic dns configuration and possible mistakes";
            echo "Created by M@rc14n0"
            echo "";
            echo "SYNTAX: ./dnsinfo.sh -d <domain.com>";
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./dnsinfo.sh -d <domain.com> or ./dnsinfo.sh -h for help" >&2
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
        echo "SYNTAX: ./dnsinfo.sh -d <domain.com> or ./dnsinfo.sh -h for help" >&2
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

echo "**************************************************************"  | tee -a $outfile
echo "Running host"   | tee -a $outfile
echo "host -a $DOMAIN"   | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
host -a $DOMAIN        | tee -a $outfile                                
echo "host -t ns $DOMAIN"   | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
host -t ns $DOMAIN        | tee -a $outfile                                
echo "**************************************************************"  | tee -a $outfile
echo "DIG Results any (This could take some seconds)"  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
dig $DOMAIN ANY  | tee -a $outfile
echo "DIG NS Results zone transfer"  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
dig ns $DOMAIN | tee -a $outfile
echo "DIG zone transfer results"  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
dig ns $DOMAIN | grep -E "NS.+\.$" | sed 's/\.$//g' | cut -f 6 > dnsservers_$DOMAIN.txt
index=1
for nameserver in $(cat dnsservers_$DOMAIN.txt); do 
    echo "**************************************************************" |tee -a $outfile
    echo -e "#Checking if the dns server ${GREEN}$nameserver${NC} has transfer zone open "  |tee -a $outfile
    req="@"$nameserver
    dig $req $DOMAIN axfr |tee -a $outfile
    index=$(($index+1));
done;
echo "**************************************************************"  |tee -a $outfile
echo -e "Total DNS Servers reviewed: ${GREEN}$index${NC} "  |tee -a $outfile
echo "**************************************************************"  |tee -a $outfile


echo "**************************************************************"  | tee -a $outfile
echo "DNS ENUM to file dnsenum_$DOMAIN.xml" | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
dnsenum --noreverse $DOMAIN --output dnsenum_$DOMAIN.xml
echo "**************************************************************"  | tee -a $outfile
echo "DNS recon to file dnsrecon_$DOMAIN.xml" | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
sudo dnsrecon -d $DOMAIN -a -b -y -k -z -x dnsrecon_$DOMAIN.xml
sudo mv /usr/share/dnsrecon/dnsrecon_$DOMAIN.xml .
sudo chown $USERNAME:$USERNAME dnsrecon_$DOMAIN.xml
echo "**************************************************************"  | tee -a $outfile
echo "FIERCE"  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
fierce --domain $DOMAIN  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
echo "DMITRY DNS ENUM"  | tee -a $outfile
echo "**************************************************************"  | tee -a $outfile
#dnsdict6  
dmitry -iwnse $DOMAIN  | tee -a $outfile

#This part requires an API
# echo "**************************************************************"  | tee -a $outfile
# echo "HACKER TARGET" | tee -a $outfile
# echo "**************************************************************"  | tee -a $outfile
# echo "Route"  | tee -a $outfile
# curl https://api.hackertarget.com/mtr/?q=$DOMAIN
# echo "Access to the on-line Test Ping API"
# curl https://api.hackertarget.com/nping/?q=$DOMAIN
# echo "Access to the DNS Lookup API"
# curl https://api.hackertarget.com/dnslookup/?q=$DOMAIN
# echo "Access to the Reverse DNS Lookup API"
# curl https://api.hackertarget.com/reversedns/?q=$DOMAIN
# echo "Access to the Whois Lookup API"
# curl https://api.hackertarget.com/whois/?q=$DOMAIN
# echo "Access to the GeoIP Lookup API"
# curl https://api.hackertarget.com/geoip/?q=$DOMAIN
# echo "Access to the Reverse IP Lookup API"
# curl https://api.hackertarget.com/reverseiplookup/?q=$DOMAIN
# echo "Access to the HTTP Headers API"
# curl https://api.hackertarget.com/httpheaders/?q=www.$DOMAIN
# echo "Access to the Page Links API"
# curl https://api.hackertarget.com/pagelinks/?q=www.$DOMAIN
# echo "Access to the AS Lookup API"
# curl https://api.hackertarget.com/aslookup/?q=$DOMAIN
