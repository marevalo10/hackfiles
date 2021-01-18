#!/bin/sh
echo "********************************************************************************************"
echo "Don't forget to put the ips.txt and ips.udp with the target ip's or segments (one per line)"
echo "********************************************************************************************"
echo "Press any key to resume ... or Ctrl - C to cancel"
read; 
SESSION_NAME="recon"
RECON_PATH="~/Scripts_recon"

cd $RECON_PATH
chmod +x *.sh
PS1="[\$(date +%F-%T)]"$PS1
export PS1
echo "********************************************************************************************"
echo "#Starting tmux to run all the scripts"
echo "********************************************************************************************"
SESSION_NAME="recon"
RECON_PATH="~/Scripts_recon"
# Check if a session exist
tmux has-session -t ${SESSION_NAME}
# If not....
if [ $? != 0 ]
then
    # Create the session named recon with a window named enumtcp
    tmux new-session -s ${SESSION_NAME} -n enumtcp -d

    # First window (1) -- run enumtcp
    tmux send-keys -t ${SESSION_NAME}:1 'PS1="[\$(date +%F-%T)]"$PS1' C-m

    # Window (2) - enumudp
    tmux new-window -n enumudp -t ${SESSION_NAME}:2
    tmux send-keys -t ${SESSION_NAME}:2 'PS1="[\$(date +%F-%T)]"$PS1' C-m

    # Run TCP part and wait until it is completed to complete next commands
    tmux send-keys -t ${SESSION_NAME}:1 'sudo '${RECON_PATH}'/1_resumenmap-tcp.sh -f ips.txt; tmux wait-for -S enumtcp-complete' C-m\; wait-for enumtcp-complete
    #If a light scan is required then: sudo nmap -oA target.txt.resumenmaplight.1 -sT -top-ports 100 -Pn  -T 4 -sV --open -vvvv --min-rate 5500 --max-rate 5700 --min-rtt-timeout 100ms --min-hostgroup 256 --privileged -iL ips.txt
	#In screen with ^b^z returns to the shell and let the screen run alone.
	#Once resumnmap-tcp has completed the scan, run  all remaining scripts. Each one can be run in a different screen
    tmux send-keys -t ${SESSION_NAME}:1 'sudo  ./3_preparefiles.sh; tmux wait-for -S files-completed' C-m\; wait-for files-completed
    # We will split the window 1 in 4: 1.0 to 1.3
    # Horizontal split
    tmux split-window -h -t ${SESSION_NAME}:1
    # Vertical split upper
    tmux split-window -v -t ${SESSION_NAME}:1.0
    # Vertical split lower
    tmux split-window -v -t ${SESSION_NAME}:1.2

    # Run commands in each window 1.x
    tmux send-keys -t ${SESSION_NAME}:1.0 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:1.0 'sudo  '${RECON_PATH}'/4_enumSMB.sh' C-m
    tmux send-keys -t ${SESSION_NAME}:1.1 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:1.1 'sudo  '${RECON_PATH}'/5_enumWEB.sh' C-m
    tmux send-keys -t ${SESSION_NAME}:1.2 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:1.2 'sudo  '${RECON_PATH}'/6_enumSSH.sh' C-m
    tmux send-keys -t ${SESSION_NAME}:1.3 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:1.3 'sudo  '${RECON_PATH}'/7_vulnSCAN-tcp.sh' C-m


    # Run UDP part in Window 2
    tmux send-keys -t ${SESSION_NAME}:2 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:2 'sudo '${RECON_PATH}'/2_resumenmap-udp.sh -f ips.udp; sudo  ./3_preparefiles.sh; tmux wait-for -S enumtcp-complete' C-m\; wait-for enumtcp-complete
    tmux send-keys -t ${SESSION_NAME}:2 'sudo  '${RECON_PATH}'/8_vulnSCAN-udp; chown -R marevalo:marevalo '${RECON_PATH}'/*' C-m
fi