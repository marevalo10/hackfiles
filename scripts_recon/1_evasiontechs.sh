#!/bin/bash
file=cdeipshide.txt
sudo nmap -f -iL $file -oN evasiontech1.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap --mtu 16 -iL $file -oN evasiontech2.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap --badsum -iL $file -oN evasiontech3.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap -sS -T4 -iL $file --script firewall-bypass -oN evasiontech4.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap -D RND:10 -iL $file -oN evasiontech5.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap -D 10.68.254.1,10.68.100.129,172.30.35.10,10.68.58.101,10.69.25.111 -iL $file -oN evasiontech6.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap --source-port 53 -iL $file -oN evasiontech7.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv
sudo nmap -sT -Pn --spoof Dell -iL $file -oN evasiontech8.$file -F --max-rate 100 --min-rtt-timeout 100ms --max-hostgroup 1 -Pn -vvvv

# Using a Zombie machine:
echo "Run: sudo nmap -sI [ZOMbie] [trget]-F -oN evasiontech8.txt"


#hping3 -S -c 1 -s 5151 -p 80 192.168.1.12
#hping3 -A -c 1 -s 5151 -p 80 192.168.1.12

# Metasploit:
echo "In Metasploit: use auxiliary/scanner/ip/ipidseq"
echo "set RHOSTS ip1,ip2,..."
echo "run"
msfconsole
