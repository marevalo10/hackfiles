#!/usr/bin/env python3
import argparse
from os import path,mkdir
import re
from urllib.parse import quote_plus

def get_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--domain", dest="domain", help="Domain")
    option = parser.parse_args()
    return option

def dorking(domain):
    if not path.exists(domain):
        mkdir(domain)
    with open(f'./{domain}/google-dorking.html', 'a') as f:
        f.write(
            f'<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"> <title>GMSectec - Google Dorks for {domain}</title> </head> <body><br>')
        
        # Files Containing Juicy Info
        f.write('<h4>File Containing Juicy Info</h4>')
        dorks = [
            'intitle:"index of" settings.py','intitle:"index of" *.apk','Fwd: intitle:"Index of /" intext:"resource/"','db_password filetype:env','inurl:/wp-content/uploads/ inurl:"robots.txt" "Disallow:" filetype:txt',
            'intitle:"index of" "apache.log" | "apache.logs"','intitle:"index of/documents"','intitle:"index of" "screenshot*.jpg"','intitle:"index of" "/public_html"'
        ]
        for dork in dorks:
            url = f"https://www.google.com/search?q=site%3A.{domain}+{quote_plus(dork)}"
            f.write(f'<a target="_blank" href="{url}">{dork}</a><br>')
        
        # File extensions
        f.write('<h4>File Extensions</h4>')
        dorks = [
            'filetype:docx|xlsx|pptx|doc|xls|ppt','filetype:xml|php|asp|aspx|jsp|war','filetype:pdf|conf|config|py|sh'
        ]
        for dork in dorks:
            url = f"https://www.google.com/search?q=site%3A.{domain}+{quote_plus(dork)}"
            f.write(f'<a target="_blank" href="{url}">{dork}</a><br>')

        # Sensitive Directories
        f.write('<h4>Sensitive Directories</h4>')
        dorks = [
            'intitle:"index of" ".env"','intitle:"index of "/Invoices*"','intitle:"index of" backup.php"','intitle:"index of" "payment"','intitle:"index of" "private/log"','intitle:"index of" "/configs"',
            '"-----BEGIN EC PRIVATE KEY-----" | " -----BEGIN EC PARAMETERS-----" ext:pem | ext:key | ext:txt','"-----BEGIN PGP PRIVATE KEY BLOCK-----" ext:pem | ext:key | ext:txt -git','intitle:"index of" "dump.sql"',
            '"-- PostgreSQL database dump complete" ext:sql | ext:txt | ext:log | ext:env','intitle:"index of" "slapd.conf"','intitle:"Index of" inurl:admin/uploads','inurl: /.git','ssh_host_dsa_key.pub+ssh_host_key+ssh_config = "index of / "'
        ]
        for dork in dorks:
            url = f"https://www.google.com/search?q=site%3A.{domain}+{quote_plus(dork)}"
            f.write(f'<a target="_blank" href="{url}">{dork}</a><br>') 
        
        # Web Server Detection
        f.write('<h4>Web Server Detection</h4>')
        dorks = [
            'inurl:8080 inrul:login.php','inurl:"/app/kibana#"','intitle:"index of" AND inurl:magento AND inurl:/dev','intitle:"Welcome to WildFly" intext:"Administration Console"','"Cisco Systems, Inc. All Rights Reserved." -cisco.com filetype:jsp',
            'intitle:"Current Network Status" "Nagios"','intitle:"GlassFish Server - Server Running"','inurl:"/phpmyadmin/user_password.php','allintitle:"Pi-hole Admin Console"','intitle:"Microsoft Internet Information Services" -IIS'
        ]
        for dork in dorks:
            url = f"https://www.google.com/search?q=site%3A.{domain}+{quote_plus(dork)}"
            f.write(f'<a target="_blank" href="{url}">{dork}</a><br>')

        # Parameters
        f.write('<h4>Parameters in URL</h4>')
        dorks = [
            'inurl:&'
        ]
        for dork in dorks:
            url = f"https://www.google.com/search?q=site%3A.{domain}+{quote_plus(dork)}"
            f.write(f'<a target="_blank" href="{url}">{dork}</a><br>')

        '''
        # Others
        f.write('<h4>Other Dorks</h4>')
        url = f"https://www.google.com/search?q=site%3A.{domain}+intext%3A+%22index+of+%2F%22"
        f.write(f'<a target="_blank" href="{url}">Index of /</a><br>')
        url = f"https://www.google.com/search?q=site%3A.{domain}+db_password+%3D%3D%3D"
        f.write(f'<a target="_blank" href="{url}">db_password ===</a><br>')
        url = f"https://www.google.com/search?q=site%3A.{domain}+ext%3Aenv+|+ext%3Alog+|+ext%3Asql+|+ext%3Ayml+|+ext%3Apem+|+ext%3Aini+|+ext%3Alogs+|+ext%3Aibd+|+ext%3Atxt+|+ext%3Aphp.txt+|+ext%3Aold+|+ext%3Akey+|+ext%3Afrm+|+ext%3Abak+|+ext%3Azip+|+ext%3Aswp+|+ext%3Aconf+|+ext%3Adb+|+ext%3Aconfig+|+ext%3Aovpn+|+ext%3Asvn+|+ext%3Agit+|+ext%3Acfg+|+ext%3Aexs+|+ext%3Adbf+|+ext%3Amdb+ext%3Apem+ext%3Apub+ext%3Ayaml+ext%3Azip+ext%3Aasc+ext%3Axls+ext%3Axlsx"
        f.write(f'<a target="_blank" href="{url}">Interesting extensions</a><br>')
        '''

options = get_arguments()
if options.domain and re.match("^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$", options.domain):
    try:
        dorking(options.domain)
        print(f"\n[+] Success. Please check the {options.domain} directory.\n")
    except:
        print(f"\n[-] Directory '{options.domain}' is already present.\n")
else:
    print(f"\n[-] Usage: python3 {path.basename(__file__)} -d example.com\n")
