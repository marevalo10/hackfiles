echo "Downloading and Installing important dotfiles"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/dotfiles_mod.zip
unzip  dotfiles_mod.zip
cd dotfiles
chmod +x *.sh
sudo ./install.sh
echo "Copying the tmux logging files to ~/tmux-logging"
cp -R tmux-logging ~/
cd ..
echo "*********************************************************"

echo "#Downloading recon scripts"
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/run_scripts_tmux.sh
chmod +x run_scripts_tmux.sh
wget https://raw.githubusercontent.com/marevalo10/hackfiles/main/scripts_recon.zip
unzip scripts_recon.zip
cd scripts_recon
chmod +x *.sh
echo "#Files in Scripts_recon"
cd ..
echo "*********************************************************"
echo "Download completed and files are ready"
echo "You can run ./run_scripts_tmux.sh to start the automated scans"
echo "*********************************************************"
