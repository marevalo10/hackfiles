#!/bin/bash
#################################################################################
# SYNTAX: ./1_autorecon.sh -f ips.txt
# Run automatic scans for all ports identified as open
######################################################################################
# RESULTS
#   Files:
######################################################################################
#Identify file with targets and if is a new scan or an already started scan
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) to segregate TCP and UDP in different scripts and 
# to create the csv files once the script finishes
declare file
declare limit
#Ports to scan
declare topports
topports=10000
USERNAME="marevalo"
echo "#################################################################################"


# When the program start, runs from here
# First check input for paramaters
validate_parameters()
{
    while getopts "f:hAVS" opt; do
        case $opt in
        # f to receive the file name to use as input for the ips to scan
        f)  #echo "-f was triggered, Parameter: $OPTARG" >&2
            file=$OPTARG;
            #Target file provided exists AND it's size is > 0?
            if test -s "$file"
            then
                #Read number of lines of target files
                limit=$(cat $file | wc -l);
                echo "OK $file exists and it contains $limit lines to be validated with nmap";
            else
                echo "ERROR: $file does not exist or is empty. "
            exit 1
            fi
            ;;

        # help
        h)  echo "1_autorecon.sh version 0.1";
            echo "";
            echo "A tool for execute automatic scan and recon on identified open ports.";
            echo "Please use a targets file with one target per line (host, range or network).";
            echo "";
            echo "SYNTAX: ./1_autorecon.sh -f ips.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./1_autorecon.sh -f ips.txt or ./1_autorecon.sh -h for help" >&2
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

    # If no -f file was specified then it is a mistake
    if [[ $@ != *"-f"* ]] ; then
        echo "ERROR: No target file was indicated!"
        echo "SYNTAX: ./1_autorecon.sh -f ips.txt or ./1_autorecon.sh -h for help" >&2
        exit 1
    fi
}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

# Loop to extract the information relative to each network segment analized
n=` cat $file | wc -l`
echo -e "Number of IP's to autorecon: $n"

echo "Autorecon all IP's in $file. Results in folder ./autorecon_results"
#sudo $(which autorecon) -t $file
#sudo chown -R $USERNAME:$USERNAME results/*
sudo env "PATH=$PATH" autorecon  -vv -o autorecon_results -t $file
sudo chown -R $USERNAME:$USERNAME autorecon_results/*

echo "Rustscan all IP's in $file. Results in folder ./autorecon_results"
for ipadd in $(cat "$file"); do
    echo "Rustscan IP $ipadd"
    rustscan --accessible -a $ipadd -r 1-65535  -- -sC -sV -Pn -T4 -A -oA ./autorecon_results/rustscan_$ipadd | tee ./autorecon_results/rustscan_results_$ipadd.txt
done


