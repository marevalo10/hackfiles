# Internal Recon Scripts
Nmap and some other tool scripts to complete a recon in an internal network
To use it:
* First download and install Kali-Linux
* Once it is installed, download the *kali_initialization.sh* script in this repository to any directory in Kali
* Run it to create a user (needs to modify the shell to change from marevalo to any other user), to change password, to download some tmux configuration files, and additional scripts that will be used during the recom.
* Install the required software by running the *SoftwareInstall.sh*

## Prepare list of IP's or networks to scan
- [ ] Before running the recon scripts, you should define the scope IP's or networks by creating a file *ips.txt* inside the recon_scripts folder. 
- [ ] This file should contain all the IP's or subnets (x.y.x.w/24) line by line.
- [ ] If there is a big network (i.e. /22) you can use the script *0_detecthostsup.sh* to quickly identify the hosts up inside this network. 
    - [ ] To call this script run:
        *./0_detecthostsup.sh -f [targets.txt]*
        Where targets.txt contains the networks you want to look for hosts up.
        As a result, a file called [targets.txt].hostlist.txt will be created

## Start the recon
- [ ] Next step is to execute the *run_scripts_tmux.sh*. This file calls the recon scripts in a way they can be run sequencially.
    This will create a tmux session with 2 main windows: enumtcp and enumudp
    Within this windows, the script will start running the scripts for each protocol following a "numeric order" except for the 2nd script (udp) that will run after all the tcp scripts have been completed based in previous experiences.


