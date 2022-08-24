#!/bin/bash
#################################################################################
# SYNTAX: ./1_sniper.sh -d <domain>
# Run sniper for the specific domain
######################################################################################
# RESULTS
#   Files: 
#       sniper_$DOMAIN.txt      #contains all the output
#       ./sniper/$DOMAIN/*      #Contains all the workspace produced by Sniper
######################################################################################
#Identify file with targets and if is a new scan or an already started scan
#The base for this script was taken from a previous version provided by Carlos Marquez
#Some additions in this version were completed by Miguel Arevalo (M4rc14n0) to segregate TCP and UDP in different scripts and 
# to create the csv files once the script finishes
declare file
declare DOMAIN
USERNAME="marevalo"
echo "#################################################################################"


# When the program start, runs from here
# First check input for paramaters
validate_parameters()
{
    while getopts "d:hAVS" opt; do
        case $opt in
        # f to receive the file name to use as input for the ips to scan
        d)  #echo "-f was triggered, Parameter: $OPTARG" >&2
            DOMAIN=$OPTARG;
            fi
            ;;

        # help
        h)  echo "1_sniper.sh version 0.1";
            echo "";
            echo "A tool to execute sniper on the defined domain.";
            echo "SYNTAX: ./1_sniper.sh -fd<domain.com>"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./1_sniper.sh -d <domain.com> or ./1_sniper.sh -h for help" >&2
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
        echo "SYNTAX: ./1_autorecon.sh -d <domain.com> or ./1_autorecon.sh -h for help" >&2
        exit 1
    fi
}

# Validate arguments ($@ is the list of received parameters)
validate_parameters $@

#run sniper
sudo sniper -t $DOMAIN --osint --recon -fp -b | tee sniper_$DOMAIN.txt
mkdir sniper
sudo cp -r /usr/share/sniper/loot/workspace/$DOMAIN ./sniper
sudo chown -R $USERNAME:$USERNAME sniper_$DOMAIN.txt
sudo chown -R $USERNAME:$USERNAME ./sniper/*
