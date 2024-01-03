# Segmentation Test Scripts
These scripts are oriented to help with the segmentation tests.  
First, create a file (e.g. ips.txt) and include there all the IP addresses or network segments in CIDR notation (eg. x.y.z.w/24).  

Example of content for file ips.txt:

>10.150.110.0/24
>10.2.6.41
>10.2.6.47


## 0. Look for active IPs
Use the script 0_detecthostsup.sh and pass the file containing the list of IP or networks wanted to be checked.  

SYNTAX: 
```
./0_detecthostsup.sh -f <filename>
```
This script extract the hosts identified as alive in each subnet received using some special techniques:
```
   sudo nmap -sn -n -PA -PU -PO -T4 $network -oG - 
```
The result is stored in an output file hostup_<filename> (e.g. hostup_ips.txt) containing one IP by line identified as alive.


## 1. Use evasion techniques to discover IPs and ports  
This script attempts to bypass network controls to validate if a connection can be established to any of the  IPs in the list.

It takes the hosts / network segments from the received file (e.g. ips.txt) and tries to check if they are reachable using some evasion techniques.  By default, it uses the top 1000 tcp ports and top 200 udp ports to complete the technique.

Nmap results using each teachnique are left in files evasiontech**\<X\>**.ips.txt (or the filename used) where X is a numbeer \[1 to 9\] used for each technique used. The script uses these techniques:  
1. Fragment Packets (-f)
2. MTU (--mtu)
3. BADSUM (--badsum)
4. FW BYPASS (--script firewall-bypass)
5. RANDOM DECOY (-D RND:10)  //This line commented. Should be enabled and customised as applicable
6. SPOOFING INTERNAL IPs (-D $SOURCEIPS) //This line is commented. Should be enabled and customised as applicable.
7. SOURCE PORT (--source-port 53) //Using port 53. Can be customised as desired in the file.
8. SPOOF MAC (--spoof Dell)  // Using a Dell mac. Can be customised as applicable, in case there are some network exceptions based on the mac address.
9. UDP  (-sU)  // This technique uses the top 200 ports. This can be customised in the script

More info about evasion techniques: https://nmap.org/book/man-bypass-firewalls-ids.html

**Please note this script could take a lot of time if there are many network segments.**  
You can disable any technique in the script by commenting the line. You can stop the script at any time and take the results from the techniques completed. In some cases, just with one technique could be enough to discover some IPs and ports exposed.

SYNTAX: 
```
    sudo ./0.1_evasiontechs.sh [-f <filename>]
```
By default it tries to use the file ips.txt


## 2. Run the script to extract the results to be included in the report
Based on the results from the script 0.1_evasiontechs.sh, this script analyse the resulting files and extract the IPs and ports identified as open and left them in the file "reachableips_<filename>" (e.g. reachableips_ips.txt)

SYNTAX: 
```
    sudo ./0.2_analyseresultsevasion.sh [-f <filename>]
```
By default the script tries to use ips.txt as the name of the input file

Example of results:
>10.150.110.24 3389/tcp  
>10.150.110.25 3389/tcp  
>10.150.110.28 3389/tcp 389/tcp 389/udp 443/tcp 80/tcp  
>10.150.110.5 123/udp 135/tcp 3389/tcp 389/tcp 389/udp 53/tcp 53/udp  
>10.2.6.41 123/udp 161/udp 22/tcp 443/tcp 80/tcp  
