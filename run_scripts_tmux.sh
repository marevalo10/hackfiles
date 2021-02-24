#!/bin/bash
echo "******************************************************************************************************************************************************"
echo " Don't forget to modify the script by including the files in Sect 2.1 and 2.2 with the target ip's by group (i.e. cde.txt, dmz.txt, or support.txt"
echo " By default it will take cde.txt and support.txt as the files that contains the IP's or segments to scan"
echo "******************************************************************************************************************************************************"
read -n1 -s -r -p $'Press any key to resume ... or Ctrl - C to cancel\n' key
SESSION_NAME="recon"
#It could be ~/Pentest/scripts_recon
RECON_PATH="scripts_recon"
file1=cde.txt
file2=support.txt

cd ~; cd $RECON_PATH
chmod +x *.sh
# Run a command to include the timestamp in the prompt. It could be enabled/disable if it is already working in the current shell
#PS1="[\$(date +%F-%T)]"$PS1
#export PS1
echo "********************************************************************************************"
echo "# Starting tmux to run all the scripts"
echo "********************************************************************************************"
#############################
# 0 Check if a session exists
#############################
if (tmux has-session -t ${SESSION_NAME} 2>/dev/null); then
    echo "Session${SESSION_NAME} already exists."
    echo "Aborting execution. Close previous tmux session"
else
    ######################
    # 1. INIT TMUX WINDOWS
    ######################
    echo "Starting a new session.... "${SESSION_NAME}
    # Create the session named recon with a window named enumtcp
    tmux new-session -s ${SESSION_NAME} -d

    echo "Starting a new window enumtcp...."
    # First window (1) -- run enumtcp (It is not working)
    tmux rename-window enumtcp
    # Replaced by the previous line 
    # In tmux C-m is enter!
    #tmux new-window -n enumtcp -t ${SESSION_NAME}:1
    #tmux send-keys -t ${SESSION_NAME}:1 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    # Start logging Not working
    #tmux send-keys -t ${SESSION_NAME}:1 C-P

    echo "Starting a new window enumudp...."
    # Window (2) - enumudp
    tmux new-window -n enumudp -t ${SESSION_NAME}:2
    #tmux send-keys -t ${SESSION_NAME}:2 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    #tmux send-keys -t ${SESSION_NAME}:2 C-P

    ################################
    # 2. Starts the enumeration part
    ################################
    echo "Start running  enumtcp...."
    echo "Please attach to the tmux session to check the progress and if required provide the password...."
    echo "Run this command and provide credentials for each case: "
    echo "**************************"
    echo "tmux attach -t"${SESSION_NAME}
    echo "**************************"
    echo "And go to the Window 1 (enumtcp) -> ^b 1"
    echo "Once enumtcp has been completed, all the other scans will start"
    # We will split the window 1 in 4: 1.0 to 1.3
    # Horizontal split
    echo "Spliting the windows enumtcp...."
    tmux split-window -h -t ${SESSION_NAME}:1
    # Vertical split upper
    tmux split-window -v -t ${SESSION_NAME}:1.0
    # Vertical split lower
    tmux split-window -v -t ${SESSION_NAME}:1.2

    ###################################################################################
    # 2.1 Run TCP part and wait until it is completed to continue running next commands
    # Modify this part to include a scan for each grupo you have (cde.txt or dmz.txt, or just ips.txt...)
    ###################################################################################
    tmux send-keys -t ${SESSION_NAME}:1.0 'sudo ./1_resumenmap-tcp_new.sh -f $file1; tmux wait-for -S enumtcp0-complete' C-m\;
    tmux send-keys -t ${SESSION_NAME}:1.1 'sudo ./1_resumenmap-tcp_new.sh -f $file2; tmux wait-for -S enumtcp1-complete' C-m\; 
    tmux send-keys -t ${SESSION_NAME}:1.0  wait-for enumtcp0-complete
    tmux send-keys -t ${SESSION_NAME}:1.1  wait-for enumtcp1-complete
    #If the scan was innitiated but canceled at some point, the scan will resume from the previous completed part automatically
	#In screen with ^b^z returns to the shell and let the screen run alone.
	#Once resumnmap-tcp has completed the scan, run  all remaining scripts. Each one can be run in a different screen
    echo "Preparing the files after enumtcp...."
    tmux send-keys -t ${SESSION_NAME}:1.0 './3_preparefiles_new.sh -f $file1; tmux wait-for -S files-completed' C-m\; wait-for files-completed
    tmux send-keys -t ${SESSION_NAME}:1.0 './3_preparefiles_new.sh -f $file2; tmux wait-for -S files-completed' C-m\; wait-for files-completed
    # Run commands in each window 1.x
    echo "Running enumSMB...."
    #tmux send-keys -t ${SESSION_NAME}:1.0 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    tmux send-keys -t ${SESSION_NAME}:1.0 './4_enumSMB.sh' C-m
    echo "Running enumWEB...."
    #tmux send-keys -t ${SESSION_NAME}:1.1 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    #Start loging the window
    #tmux send-keys -t ${SESSION_NAME}:1.1 C-P
    tmux send-keys -t ${SESSION_NAME}:1.1 './5_enumWEB.sh' C-m
    echo "Running enumSSH...."
    #tmux send-keys -t ${SESSION_NAME}:1.2 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    #Start loging the window
    #tmux send-keys -t ${SESSION_NAME}:1.2 C-P
    tmux send-keys -t ${SESSION_NAME}:1.2 './6_enumSSH.sh' C-m
    echo "Running VulnSCAN-tcp...."
    #tmux send-keys -t ${SESSION_NAME}:1.3 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    #Start loging the window
    #tmux send-keys -t ${SESSION_NAME}:1.3 C-P
    tmux send-keys -t ${SESSION_NAME}:1.3 './7_vulnSCAN-tcp.sh' C-m

    ###################################################################################
    # 2.2 Run UDP part and wait until it is completed to continue running next commands
    # Modify this part to include a scan for each grupo you have (cde.txt or dmz.txt, or just ips.txt...)
    ###################################################################################
    echo "***************************************************"
    echo "Starting enumupd...."
    echo "In tmux go to the window 2 and PROVIDE the password (if required) to start UDP scan"
    #tmux send-keys -t ${SESSION_NAME}:2 'PS1="[\$(date +%F-%T)]"$PS1' C-m
    #Start loging the window
    #tmux send-keys -t ${SESSION_NAME}:2 C-P
    tmux send-keys -t ${SESSION_NAME}:2  C-m
    tmux send-keys -t ${SESSION_NAME}:2 'sudo ./2_resumenmap-udp_new.sh -f $file1; tmux wait-for -S enumudp-complete' C-m\; wait-for enumudp-complete 
    tmux send-keys -t ${SESSION_NAME}:2 'sudo ./2_resumenmap-udp_new.sh -f $file2; tmux wait-for -S enumudp-complete' C-m\; wait-for enumudp-complete 
    #If the scan was stoped at some point, calling the script again will start from the previous saved status automatically (grouped by 64 IP's)
    echo "Preparing the files after enumudp...."
    tmux send-keys -t ${SESSION_NAME}:1 './3_preparefiles.sh -f $file1; tmux wait-for -S files-completed' C-m\; wait-for files-completed
    tmux send-keys -t ${SESSION_NAME}:1 './3_preparefiles.sh -f $file2; tmux wait-for -S files-completed' C-m\; wait-for files-completed
    echo "Running VulnSCAN-udp...."
    tmux send-keys -t ${SESSION_NAME}:2 './8_vulnSCAN-udp.sh; sudo chown -R marevalo:marevalo *' C-m
fi