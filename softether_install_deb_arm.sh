#!/bin/bash
###############################################################################
#
#  FILE: softether_install_deb_arm.sh
#  BY: illogicalpartition (https://github.com/illogicalpartition)
# 
#  Script is a guided installer for SoftEther VPN server on ARM devices.
#  It is tested working on Raspbian and Armbian.
#  It could also be used on Ubuntu and Debian if the downloaded tarball is
#  changed to the non-ARM Linux version. This is currently being tested on 
#  Ubuntu 18.04.
#
#  TO RUN:
#  > git clone https://github.com/illogicalpartition/softethervpn-guided-installer-arm.git
#  > cd softethervpn-guided-installer-arm
#  > sudo chmod 755 softether_install_deb_arm.sh
#  > sudo ./softether_install_deb_arm.sh
#
#  SoftEther VPN website: https://www.softether.org/
#
###############################################################################

### Start banner
clear && clear
printf '=%.0s' {1..65}
echo
echo -e " ___        __  _    ___  _    _               __   __ ___  _  _"
echo -e "/ __| ___  / _|| |_ | __|| |_ | |_   ___  _ _  \ \ / /| _ \| \| |"
echo -e "\__ \/ _ \|  _||  _|| _| |  _|| ' \ / -_)| '_|  \ V / |  _/| .' |"
echo -e "|___/\___/|_|   \__||___| \__||_||_|\___||_|     \_/  |_|  |_|\_|"
printf '=%.0s' {1..65}
echo -e "\n- SoftEther VPN Guided Installer for Debian ARM -"
echo -e "- illogicalpartition @ github.com -\n"

### Update OS
echo "=== Checking for OS updates... ==="
sudo apt-get update -qq -y
sudo apt-get upgrade -qq -y
echo -e "Done!\n"

### Install essential packages
echo "=== Installing SoftEther VPN dependencies... ==="
sudo apt-get install build-essential checkinstall -qq -y
echo "Making sure packages installed correctly..."
pkgfound=$(dpkg-query -W --showformat='${Status}\n' build-essential | grep "install ok installed")
if [ "" == "$pkgfound" ]; then
  echo "build-essential did not install correctly. Try installing it manually using: "
  echo "sudo apt-get install build-essential"
  echo "Exiting script."
  exit 1
fi
pkgfound=$(dpkg-query -W --showformat='${Status}\n' checkinstall | grep "install ok installed")
if [ "" == "$pkgfound" ]; then
  echo "checkinstall did not install correctly. Try installing it manually using:"
  echo "sudo apt-get install checkinstall"
  echo "Exiting script."
  exit 1
fi
echo -e "Done!\n"

### Install SoftEther VPN
echo "=== Downloading SoftEther VPN... ==="
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.30-9696-beta/softether-vpnserver-v4.30-9696-beta-2019.07.08-linux-arm_eabi-32bit.tar.gz -q
tar -xzf softether-vpnserver-v4.30-9696-beta-2019.07.08-linux-arm_eabi-32bit.tar.gz 
echo "=== Installing SoftEther VPN... ==="
cd vpnserver
echo -e "1\n1\n1" | sudo make > /dev/null
cd ..
sudo cp -r vpnserver /usr/local
sudo chmod 600 *
sudo chmod 700 /usr/local/vpnserver/vpncmd
sudo chmod 700 /usr/local/vpnserver/vpnserver
echo -e "Done!\n"

### Check for install errors
echo "=== Checking for install errors... ==="
check=$(echo -e "3\nCheck" | sudo /usr/local/vpnserver/./vpncmd | grep "The command completed successfully")
if [ ! "$check" ]; then
  echo "Error, SoftEther did not install correctly."
  echo "Please retry the installation process."
  echo "Exiting script."
  exit 1
else
  echo -e "No errors!\n"
fi

### Create service file
echo -e "=== Creating service file... ==="
sudo cp vpnserver.service /lib/systemd/system
sudo chmod 644 /lib/systemd/system/vpnserver.service
sudo systemctl daemon-reload
sudo systemctl start vpnserver
sudo systemctl enable vpnserver
echo -e "Done!\n"

### Set up server password for remote configuration
echo "=== The VPN server requires a password to be set for remote management. ==="
while true; do
    read -s -p "Enter an admin password to use: " pswd
    echo
    read -s -p "Enter password again to confirm: " pswd2
    echo
    [ "$pswd" = "$pswd2" ] && break
        echo -e "Passwords do not match, please try again.\n"
done
echo -e "1\n\n\nServerPasswordSet\n$pswd\n$pswd" | sudo /usr/local/vpnserver/./vpncmd > /dev/null
echo

# Cleanup
sudo rm softether-vpnserver-*
sudo rm -rf vpnserver
sudo rm vpnserver.service

### All done!
clear
printf '=%.0s' {1..41}
echo
echo -e " ___  _        _      _             _  _"
echo -e "| __|(_) _ _  (_) ___| |_   ___  __| || |"
echo -e "| _| | || ' \ | |(_-<| ' \ / -_)/ _' ||_|"
echo -e "|_|  |_||_||_||_|/__/|_||_|\___|\__,_|(_)"
printf '=%.0s' {1..41}
echo -e "\nTo finish your configuration, be sure to download the SoftEther Server Manager.\n\n"

exit 0
