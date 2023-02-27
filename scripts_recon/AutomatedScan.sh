#https://medium.com/@0xelkot/how-i-get-10-sqli-and-30-xss-via-automation-tool-cebbd9104479
#!/bin/bash 
domain=$1
mkdir ./$1
mkdir ./$1/xray
#$1 is the parameter received with the domain name
subfinder -d $1 -silent | anew ./$1/subs.txt
assetfinder -subs-only $1 | anew ./$1/subs.txt
amass enum -passive -d $1 | anew ./$1/subs.txt
python sublist3r.py -d $1| anew ./$1/subs.txt
github-subdomains -t <github token> -d $1 | anew ./$1/subs.txt
#Nabu is a fast port scaner: https://github.com/projectdiscovery/naabu
cat ./$1/subs.txt | naabu -p — -silent | anew ./$1/open-ports.txt
cat ./$1/open-ports.txt | httpx -silent | anew ./$1/alive.txt
#Or just:
#cat ./$1/subs.txt | httpx -silent | anew ./$1/alive.txt 

#Checking vulns with nuclei
#Cent is a tool collect all templates of nuclei from others Repos on GitHub and make it in one repo to test all nuclei templates
#https://github.com/xm1k3/cent
cat ./$1/alive.txt | nuclei -t /path/to/cent/ -es info | anew ./$1/nuclei-results.txt

#XRay  crawl every host and test generic vulnerabilities for all params on URL and Body request.
#https://github.com/chaitin/xray
for i in $(cat ./$1/alive.txt); do xray_linux_amd64 ws — basic-crawler $i — plugins xss,sqldet,xxe,ssrf,cmd-injection,path-traversal — ho $(date +”%T”).html ; done



