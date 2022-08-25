#!/usr/bin/zsh
nmap -Pn -p- -T4 --reason --open  -oA nmap_fastallports_ipsext -iL ipsext.txt
line=1                                                                                                                                                                          
rm portsbyhostTCP.csv
grep "open/tcp" nmap_fastallports_ipsext.gnmap > temprawtcp.txt
for ipadd in $(grep "open/tcp" nmap_fastallports_ipsext.gnmap | awk '{print $2}'); do
        tcpports=`awk FNR==$line temprawtcp.txt | grep -o  -E "\b[0-9]{1,5}/open"  | sed 's/\/open//g' | awk -vORS=, '{ print  }'`;
        echo $ipadd $tcpports | tee -a portsbyhostTCP.csv   
        line=$(($line+1));                            
done 
#Delete duplicated IP's
cp portsbyhostTCP.csv portsbyhostTCP.csv.tmp
cat portsbyhostTCP.csv.tmp | sort -u |tee portsbyhostTCP2.csv
