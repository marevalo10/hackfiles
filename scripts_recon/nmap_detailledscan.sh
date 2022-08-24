#!/usr/bin/zsh
USERNAME="marevalo"
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
    sudo chown $USERNAME:$USERNAME $outfile.*
	echo "**************************************************************";
	echo "Creating file nmap_portsbyhost_`echo $ipadd`.csv with ip and port by line"
    ./nmaptocsv.py -i `echo $outfile`.nmap -o nmap_portsbyhost_`echo $ipadd`.csv 
	echo "**************************************************************";
	echo "IP $ipadd scanned! $i out of $n";
	echo "**************************************************************";
done

