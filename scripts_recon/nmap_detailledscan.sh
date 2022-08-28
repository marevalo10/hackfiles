#!/usr/bin/zsh
USERNAME="marevalo"

#Validates if the command was run as sudo / root
echo $EUID
if [[ "$EUID" != 0 ]]; then
        echo "Should run it as sudo $0";
        username=$(whoami);
        echo "You are running as "$username;
        exit 0;
else
        echo "Running as root";
fi


n=` cat portsbyhostTCP.csv | wc -l`
for i in {1..`echo $n`} 
do 
	line=`awk FNR==$i portsbyhostTCP.csv`;
	#Extract the IP from the line and the ports;
	ipadd=`echo $line | awk '{ print $1 }'`;
	tports=`echo $line | awk '{ print $2 }'`;
	outfile=$ipadd"_vulnscanTCP";
	echo "**************************************************************";
	echo "Will run nmap for IP $ipadd and ports $tports into file $outfile";
	echo "**************************************************************";
	sudo nmap -R -PE -PP -Pn --traceroute --reason -sV -A -sC -O --script=default,auth,vuln,version --open -vvv -oA $outfile --max-rate 700 --privileged -p "T:"$tports $ipadd; 
	echo "**************************************************************";
	echo "Creating file nmap_portsbyhost_`echo $ipadd`.csv with ip and port by line"
    python3 ./nmaptocsv.py -i `echo $outfile`.nmap -o nmap_portsbyhost_`echo $ipadd`.csv 
    sudo chown $USERNAME:$USERNAME $outfile.*
    sudo chown $USERNAME:$USERNAME nmap_portsbyhost_`echo $ipadd`.csv
	echo "**************************************************************";
	echo "IP $ipadd scanned! $i out of $n";
	echo "**************************************************************";
done

