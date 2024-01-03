#!/bin/bash

#Check if a name was provided or ask for it or take the default (ips.txt)
file_name=$1
if [ -z "$file_name" ]; then
  echo "No file name received"
  read -p "Enter the file name used to run the analysis or hit enter to use default file (ips.txt): " file_name
  if [ -z "$file_name" ]; then
	file_name=ips.txt
  fi
fi
if [ ! -f "evasiontech1.$file_name" ]; then
  echo "File $file_name does not exist."
  exit 1
fi

tmp_file="tmp_$file_name"
tmp2_file="tmp2_$file_name"
#File that will contain a line with the IP and ports found open
output_file="reachable_$file_name"
output_file_canopy="reachable_canopy_$file_name"
#File that will contain a list of all ports open separated by comma
output_fileports="reachableports_$file_name"
#File that will contain a list of all IP address with open ports
output_fileips="reachableips_$file_name"
#tmp2_file="tmp2_${file%.txt}.txt"

#Creates a file with all the evasiontech results. It contains lines with nmap ... IP or lines with the port
cat evasiontech*.$file_name |grep "open\|report" |grep -v "filter" > $tmp_file
#Extract all the ports discovered as open in 1 line
cat evasiontech*.$file_name | grep open |grep -v "filter" |cut -f1 -d'/'|sort -n|uniq | paste -sd ',' >$output_fileports

#Creates a depured file by deleting nmap lines with no asociated open ports 
echo -n "" > $tmp2_file
while IFS= read -r line
do
	if [[ $prev_line == Nmap* ]]; then
		if [[ $line != Nmap* ]]; then
			echo "$prev_line" >> "$tmp2_file"
		fi
	else
		echo "$prev_line" >> "$tmp2_file"
	fi
	prev_line="$line"
done < "$tmp_file"
rm $tmp_file


echo "Creating file with IP and ports detected as open"
prev_line=""
# Read the file ($tmp2_file) to create the list of IP and open ports by line
while IFS= read -r line
do
	#Check for consecutive lines with Nmap
	if [[ $prev_line == Nmap* ]]; then
		# Extract the IP
		ip=$(echo -n "$prev_line" | awk '{print $NF}')
		line_to_store=$(echo -n $ip)
		#While there is a number in the line (open port)
		while [[ $line =~ ^[0-9] ]]; do
			port=$(echo "$line" | awk '{print $1}')
			# Append the first word to the output file
			line_to_store=$(echo -n $line_to_store" $port")

			# Read the next line
			line=$(IFS= read -r; echo "$REPLY")
		done
		echo "Open ports found: $line_to_store"
		echo $line_to_store >> "$tmp_file"
	fi
	prev_line="$line"
done < "$tmp2_file"

#Generates a file ordered by IP and removes duplicates
cat $tmp_file |sort -n |uniq > $tmp2_file
#As some IPs could be repeated due to multiple evasion techniques with different results, then 
#creates an array to store IPs and ports and then store them in a file
declare -A ip_ports  # Associative array to store IP addresses and their ports

while read -r line
do
    ip=${line%% *}  # Extract the IP address (everything before the first space)
    ports=${line#* }  # Extract the ports (everything after the first space)

    # Check if the IP already exists in the array
    if [[ ${ip_ports[$ip]+_} ]]; then
        # IP already exists, append the ports to the existing value
        ip_ports[$ip]="${ip_ports[$ip]} $ports"
    else
        # IP doesn't exist, create a new entry in the array
        ip_ports[$ip]="$ports"
    fi
done < "$tmp2_file"

# Write the IP addresses and their corresponding ports to the output file
rm -f $tmp_file $tmp2_file
for ip in "${!ip_ports[@]}"; do
    # Remove duplicate ports using uniq
    unique_ports=$(echo "${ip_ports[$ip]}" | tr ' ' '\n' | sort | uniq)

    # Join the unique ports back into a single string
    joined_ports=$(echo "$unique_ports" | paste -sd ' ')
    
    echo "$ip $joined_ports" >> "$tmp_file"
done

cat $tmp_file |sort -n > $output_file
#Extract all the IPs with open ports
cat $output_file  |cut -d' ' -f1 >$output_fileips
rm -f $tmp_file

#Creates the file in Canopy report required format

# Read the file line by line
while IFS= read -r linex
do
    # Divide the line into IP and the list of ports and protocols
    ip="${linex%% *}"
    ports="${linex#* }"

    # Divide the list of ports and protocols into individual elements
    IFS=' ' read -ra elements <<< "$ports"

    # Iterate through the elements to extract the protocol and port
    for element in "${elements[@]}"
    do
        # Divide the element into protocol and port
        protocol="${element##*/}"
        port="${element%/*}"

        # Print the information in the desired format
        echo "$protocol://$ip:$port" >> $output_file_canopy
    done
done < $output_file


ips=$(cat $output_fileips |wc -l)
echo "Total IPs found: $ips "
ports=$(cat $output_fileports | tr ',' ' ' |wc -w)
echo "Total different open ports found: $ports "
echo "Check file $output_file as it contains all the identified IPs and ports"
echo "Run cat $output_file_canopy to have the information ready to include in the report"
