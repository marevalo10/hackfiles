#!/bin/bash
#Tested in [recon-ng v4.9.3, Tim Tomes (@LaNMaSteR53)]
#Original idea and source Dhayalan96: https://raw.githubusercontent.com/Dhayalan96/enumall/master/enumall.sh
# Modules that needs api’s: (bing_api google_api google_cse shodan_api builtwith_ap github_api ipinfodb_api twitter_api)
# input from command-line becomes domain to test
domain=$1
# input from command-line becomes company to test
company=$2
#run as bash enum2all.sh Domain.com Company

#timestamp
stamp=$(date +"%m_%d_%Y")
path=$(pwd)

#create rc file with workspace.timestamp and start enumerating hosts
touch $company-$domain$stamp.resource

echo "spool start $domain$stamp.log" >> $domain$stamp.resource

echo "Domain:" $domain
echo "Company:" $company

echo "workspaces select $domain$stamp" >> $domain$stamp.resource
echo "use recon/domains-hosts/bing_domain_web" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/bing_domain_api" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/google_site_api" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/netcraft" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/hackertarget" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-contacts/metacrawler" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
  
echo "use recon/domains-hosts/shodan_hostname" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/brute_hosts" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/certificate_transparency" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/resolve" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/reverse_resolve" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/bing_ip" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/ipinfodb" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/freegeoip" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/hosts-hosts/ssltools" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource


echo "use recon/domains-contacts/pgp_search" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-contacts/whois_pocs" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/companies-contacts/bing_linkedin_cache" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/builtwith" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/mx_spf_ip" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-hosts/ssl_san" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource 

echo "use recon/domains-vulnerabilities/ghdb" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource 

echo "use recon/domains-vulnerabilities/punkspider" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource 

echo "use recon/domains-vulnerabilities/xssed" >> $domain$stamp.resource
echo "set SOURCE $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource 


echo "use recon/companies-multi/github_miner" >> $domain$stamp.resource
echo "set SOURCE $company" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/profiles-contacts/github_users" >> $domain$stamp.resource
echo "set SOURCE $company" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/profiles-repositories/github_repos" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "run recon/repositories-profiles/github_commits" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "run recon/repositories-vulnerabilities/github_dorks" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/companies-multi/whois_miner" >> $domain$stamp.resource
echo "set SOURCE $company" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use recon/domains-domains/brute_suffix" >> $domain$stamp.resource
echo "set SOURCE $company" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use reporting/csv" >> $domain$stamp.resource
echo "set FILENAME $path/$domain.csv" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

echo "use reporting/html" >> $domain$stamp.resource
echo "set CREATOR cmarquez" >> $domain$stamp.resource
echo "set CUSTOMER $domain" >> $domain$stamp.resource
echo "set FILENAME $path/$domain.html" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource

cd /usr/share/recon-ng/
./recon-ng --no-check -r $path/$domain$stamp.resource

