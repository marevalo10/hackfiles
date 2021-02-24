#!/bin/bash
echo "********************************************************************************************"
echo "Script to start responder to capture user credentials / hashes"
echo "Logs will be stored in /usr/share/responder/log"
echo "********************************************************************************************"
read -n1 -s -r -p $'Press any key to continue ... or Ctrl - C to cancel\n' key
SESSION_NAME="responder"
#It could be ~/Pentest/scripts_recon
RECON_PATH="scripts_recon"

# Run a command to include the timestamp in the prompt. It could be enabled/disable if it is already working in the current shell
#PS1="[\$(date +%F-%T)]"$PS1
#export PS1
echo "********************************************************************************************"
echo "#Starting tmux session to run responder. Session name: "${SESSION_NAME}
# Check if a session exist
if (tmux has-session -t ${SESSION_NAME} 2>/dev/null); then
    echo "Session${SESSION_NAME} exists... cancelling the session"
else
    echo "Starting a new session.... "${SESSION_NAME}
    # Create the detached session 
    tmux new-session -s ${SESSION_NAME} -d

    echo "Starting a new window ...."
    # First window (1) -- run enumtcp
    tmux rename-window responder
    # Replaced by the previous line 
    # In tmux C-m is enter!
    #tmux new-window -n enumtcp -t ${SESSION_NAME}:1
    #tmux send-keys -t ${SESSION_NAME}:1 'PS1="[\$(date +%F-%T)]"$PS1' C-m

    # Run responder
    tmux send-keys -t ${SESSION_NAME}:1 'sudo responder -I eth0 -A' C-m
    # Creates a new Vertical split upper window to check the logs
    tmux split-window -h -t ${SESSION_NAME}:1
    tmux send-keys -t ${SESSION_NAME}:1.1 'cd /usr/share/responder/logs; ls -la' C-m
    echo "Please attach to the tmux session to check the progress and if required provide the password...."
    echo "Run this command to access the session: "
    echo "******************************"
    echo "tmux attach -t"${SESSION_NAME}
    echo "******************************"
    echo "Do not forget to start the tmux logging: Ctrl-b + P"
    echo "Responder logs will be stored in /usr/share/responder/logs"
fi
