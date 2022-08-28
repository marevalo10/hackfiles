#!/usr/bin/zsh
#If not installed:
#go install github.com/tomnomnom/waybackurls@latest
#username=$(whoami)
#export PATH=$PATH:/home/$username/go/bin/
echo "********************************************************************************************"
echo "Be sure file domains.txt exists and it contains all the domains you want to wayback"
echo "********************************************************************************************"
echo "Getting the urls and dates stored in wayback...."
cat domains.txt | waybackurls -dates  |tee wayback_url_dates.txt
echo "********************************************************************************************"
echo "Information saved on file tee url_dates.txt"
echo "********************************************************************************************"
echo "Getting the urls from in wayback...."
cat domains.txt | waybackurls  |tee wayback_urls.txt
echo "********************************************************************************************"
echo "Information saved on file tee urls.txt"
echo "********************************************************************************************"
#Check any interesting path on these results
echo "If some of them are interesting, based on the date, it could be checked the url to point."
cat domains.txt | waybackurls -get-versions | tee wayback_versions.txt
echo "********************************************************************************************"
echo "Information saved on file versions.txt"
echo "********************************************************************************************"

