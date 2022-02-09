#!/bin/bash
# SYNTAX: ./0_detecthostsup.sh -f targets.txt
# This script extract the hosts identified as alive in each subnet received using some special techniques:
#   sudo nmap -sn -n -PA -PU -PO -T4 $network -oG - | awk '/Up$/{print $2}' 
# The result is stored in an output file hostup_<filename> containing one IP by line identified us up
# Resulting file could be used in the nmap tcp / udp as it is focused in the systems identified as up.
# The script reads each line in the file with the networks list / IP
# Created by M@rc14n0
declare file
declare outfile

# When the program start, runs from here
# First check input for paramaters
validate_parameters()
{
    while getopts "f:hAVS" opt; do
        case $opt in
        # f to receive the file name to use as input for the ips to scan
        f)  #echo "-f was triggered, Parameter: $OPTARG" >&2
            file=$OPTARG;
            outfile=hostup_$file
            #Target file provided exists AND it's size is > 0?
            if test -s "$file"
            then
                #Read number of lines of target files
                limit=$(cat $file | wc -l);
                echo "OK $file exists and it contains $limit lines to identify hosts up";
            else
                echo "ERROR: $file does not exist or is empty. "
            exit 1
            fi
            ;;

        # help
        h)  echo "0_detecthostsup version 0.1";
            echo "";
            echo "A tool to identify which hosts are up using different techniques";
            echo "Please use a file with the segments or IP's wanted to be validated per line (host, range or network).";
            echo "A file with the same name + .hostlist.txt will be created with the list of all IP's found up"
            echo "Created by M@rc14n0"
            echo "";
            echo "SYNTAX: ./0_detecthostsup.sh -f targets.txt"
            echo "";
            exit 0	>&2;;

        *) echo "SYNTAX: ./0_detecthostsup.sh -f targets.txt or ./0_detecthostsup.sh -h for help" >&2
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
        echo "SYNTAX: ./0_detecthostsup.sh -f targets.txt or ./0_detecthostsup.sh -h for help" >&2
        exit 1
    fi

    # Check if the file nets.txt exist
    if test -f $file; then
        echo "********************************************************************************************"
        echo "#Reading network list from file "$file
    else
        echo "********************************************************************************************"
        echo -e "File "$file" not found. Execution cancelled..."
        echo "********************************************************************************************"
        echo "********************************************************************************************"
        exit 1
    fi

    #Check if the outputfile already exists
    if test -f $outfile; then
        echo -e "File "$outfile" already exists.... Additional hosts will be appended to the file"
        read -p "Are you sure? (y|n): " -n 1 -r; echo -e "\n";
        if [[ $REPLY =~ ^[Yy]$ ]]; 	then
            echo -e "Appending to files "$outfile
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

# Runs the nmap validation
index=1
for network in $(cat $file); do 
    echo "********************************************************************************************"
    echo "#Starting host identification for network "$network
    echo "#This could take time if it is a big network"
    echo "********************************************************************************************"
    echo "Creating the file hostup_"$index$file" to include the hosts from network "$network
    sudo nmap -sn -n -PA -PU -PO -T4 $network -oG - | awk '/Up$/{print $2}' |tee hostup_$index$file
    echo "Adding hosts found to file "$outfile
    cat hostup_$index$file >> $outfile;
    index=$(($index+1));
done;

totalips=(cat $outfile | wc -l)
echo "Total IP's found alive: "$totalips
echo "File with the list: "$outfile
