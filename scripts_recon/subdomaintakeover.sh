#!/usr/bin/zsh
domain="test.com"
PATH=$PATH:~/go/bin/
# 1. Find all possible subdomains.
echo "**************************************************************"
echo "Finding possible subdomains using subfinder, dnsprobe and httprobe ..."
echo "**************************************************************"
sudo subfinder -d $domain -silent | ~/go/bin/dnsprobe -silent -f domain |sort -u  |tee subdomains_$domain.txt
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