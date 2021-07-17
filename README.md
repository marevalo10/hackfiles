#README
This repository contains different utilities I have worked on as a part of my Penentration Testing learning path.
- 1. Recon: I took some scripts previously developed and I improved them based on the knowledge I got to complete a recon phase in an internal network.
- 2. BoF: this directory contains a short explanation of the fuzzing process to identify a buffer overflow. Additionally, it explains the steps to develop a Proof of Concept (PoC) in python to validate and exploit this BoF. I included the steps and the scripts in python to complete these steps.

# 1. Internal Recon Scripts
Useful scripts to run as a part of the initial recon in an internal network. This scripts should be used in a recent Kali Linux machine.
To use it:
* First, download the *kali_initialization.sh* script in this repository and run it to:
    * Create a new user / password (needs to modify the shell to change from marevalo to any other user), 
    * Download some tmux configuration files that let it work with mouse integration and logging enable (ctrl-b shift-p)
    * Download additional scripts that will be used during the recom.
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


