#!/usr/bin/zsh
domain="test.com"
PATH=$PATH:~/go/bin/
username=$(whoami)
# 1. Find all possible subdomains.
echo "**************************************************************"
echo "Finding possible subdomains using different tools ..."
echo "**************************************************************"
sudo subfinder -d $domain -silent | ~/go/bin/dnsprobe -silent -f domain |sort -u  |tee subdomains_subfinder_$domain.txt
echo $domain | assetfinder --subs-only | tee subdomains_assetfinder_$domain.txt
#Sublist3r:
sublister -d $domain | tee subdomains_sublister_$domain.txt
#Amass:
amass enum -passive -d $domain | tee subdomains_amass_$domain.txt
#Sublist3r using bruteforce is not working well (-b)
sublist3r -d $domain -o subdomains_sublist3r_$domain.txt

#dnsrecon dnsenum requires manuall check / file preparation
#Additional information can be gathered from sniper
sudo chown $username:$username subdomains_*
cat subdomains_*.txt | sort -u > subdomains_$domain.txt

#2. Test if some of the subdomains is vulnerable.
echo "**************************************************************"
echo "Testing subdomains to check if they are vulnerable with nuclei..."
# Nuclei templates under ~/.local/nuclei-templates
echo "**************************************************************"
cat subdomains_$domain.txt | httprobe -prefer-https | nuclei -t nuclei-templates/takeovers/ 
#Check for vulnerabilities
#cat subdomains_$domain.txt | httpx |nuclei -t nuclei-templates/vulnerabilities -v

echo "**************************************************************"
echo "Testing subdomains with subjack and subzy..."
echo "**************************************************************"
subjack -w subdomains_$domain.txt -t 100 -timeout 30 -ssl -v
subjack -w subdomains_$domain.txt -t 100 -timeout 30 -ssl -v -c /usr/share/subjack/fingerprints.json
subzy --https --targets subdomains_$domain.txt
cat subdomains_$domain.txt | httpx | tee tmp$domain.txt; subzy --targets tmp$domain.txt

echo "For those possible takeovers look at https://github.com/EdOverflow/can-i-take-over-xyz to validate if the provider is in the list"
