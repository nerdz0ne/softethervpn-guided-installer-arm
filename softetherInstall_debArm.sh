#!/bin/bash
###############################################################################
#
#  FILE: softetherInstall_debArm.sh
#  illogicalpartition (https://github.com/illogicalpartition)
# 
#  Script installs SoftEther VPN server and guides the user through essential setup. 
#  Works on x86 and x64 ARM devices running Debian-based distros.
#
#  SoftEther VPN website: https://www.softether.org/
#
###############################################################################

################################
#  Start!
################################
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


################################
#  Dependencies and Updates
################################

### Install essential packages
echo "=== Installing SoftEther VPN dependencies... ==="
sudo apt-get update -qq -y
sudo apt-get install build-essential cmake gcc g++ git make libncurses5-dev libssl-dev pkg-config libsodium-dev libreadline-dev zlib1g-dev -qq -y
echo "Making sure packages installed correctly..."
pkgInst=$(dpkg-query -W --showformat='${Status}\n' build-essential cmake gcc g++ make libncurses5-dev libssl-dev pkg-config libsodium-dev libreadline-dev zlib1g-dev | grep "install ok installed")
if [[ ! "$pkgInst" ]]; then
  echo "One or more dependencies did not install correctly. Try installing them manually:"
  echo "build-essential cmake gcc g++ make git libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev"
  echo "Exiting script."
  exit 1
fi
echo -e "Done!\n"


################################
#  Server Installation
################################
# x64 installation
arm64Inst() {
  echo "x64 detected! Starting the 64-bit install process. This will probably take a bit!" 
  read -e -p "Begin download and install? (y/N): " choice
  if [[ "$choice" != "y"  || "$choice" != "Y" ]]; then
    echo "Install cancelled, exiting script."
    exit 0
  fi
  echo -e "\n=== Downloading SoftEther VPN... ==="
  git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git
  echo -e "Done!\n"
  echo "=== Installing SoftEther VPN... ==="
  cp Makefile-x64 ./SoftEtherVPN_Stable/Makefile
  cd SoftEtherVPN_Stable
  make > /dev/null 2>&1
  sudo make install > /dev/null 2>&1
  make clean > /dev/null
  cd ..
  echo -e "Done!\n"
}

# x86 installation
armelhfInst() {
  echo "x86 detected! Starting the 32-bit install process...\n\n" 
  echo "=== Downloading SoftEther VPN... ==="
  wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.34-9745-beta/softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-arm_eabi-32bit.tar.gz -q
  tar -xzf softether-vpnserver-*
  echo -e "Done!\n"
  echo "=== Installing SoftEther VPN... ==="
  cd vpnserver
  echo -e "1\n1\n1" | sudo make > /dev/null
  cd ..
  sudo mv vpnserver /usr/local/softether
  sudo chmod 600 /usr/local/softether/*
  sudo chmod 755 /usr/local/softether /usr/local/softether/vpnserver /usr/local/softether/vpncmd
  sudo chown -R root /usr/local/softether && sudo chgrp -R root /usr/local/softether 
  # Faux symlink to correctly execute vpncmd w/o the absolute path and editing root $path for sudo
  echo -e '#!/bin/sh\nopts="$*"\ncd /usr/local/softether\nsudo ./vpncmd $opts' | sudo tee /usr/local/bin/vpncmd > /dev/null
  sudo chmod 755 /usr/local/bin/vpncmd 
  echo -e "Done!\n"
}

### Determine install function
echo "=== Checking architecture... ==="
if [[ $(getconf LONG_BIT) == "64"]]; then
  arm64Inst
else 
  armelhfInst
fi

### Check for install errors
echo "=== Checking for install errors... ==="
check=$(echo -e "3\nCheck" | sudo vpncmd | grep "The command completed successfully")
if [[ ! "$check" ]]; then
  echo "Error, SoftEther did not install correctly."
  echo "Please retry the installation process."
  echo "Exiting script."
  exit 1
else
  echo -e "No errors!\n"
fi

### Create service file
echo -e "=== Creating service file... ==="
sudo cp se-vpnserver.service /lib/systemd/system
sudo chmod 644 /lib/systemd/system/se-vpnserver.service
sudo systemctl daemon-reload
sudo systemctl start se-vpnserver
sudo systemctl enable se-vpnserver
echo -e "Done!\n"


################################
#  Server Configuration
################################
### Set up server password for remote management
echo "=== Setting remote management password... ==="
while true; do
  read -s -p "Enter an admin password to use: " pswd
  echo
  read -s -p "Enter password again to confirm: " pswd2
  echo
  [[ "$pswd" = "$pswd2" ]] && break
  echo -e "Passwords do not match, please try again.\n"
done
sudo vpncmd /server localhost /password:none /cmd ServerPasswordSet $pswd > /dev/null
echo -e "Password set!\n"

### Create Hub
echo "=== Creating Virtual Hub... ==="
read -e -p "Enter a virtual hub name: " hubName  
while [[ -z $hubName ]]; do
  read -e -p "Invalid name, enter a valid virtual hub name: " hubName
done
sudo vpncmd /server localhost /password:$pswd /cmd HubCreate $hubName /PASSWORD:$pswd > /dev/null
echo -e "Hub created!\n"


### Create bridge
echo "=== Creating bridge to $hubName... ==="
echo ">> Available interfaces: "
lan=$(ip link show | grep eth\[0-9] | awk '{print substr( $2, 1, length($2)-1)}')
wlan=$(ip link show | grep wlan\[0-9] | awk '{print substr( $2, 1, length($2)-1)}')
[[ -z $wlan ]] && wlan="None found"
echo -e "Wired: $lan"
echo -e "Wireless: $wlan"
read -e -p "Enter an interface: " brInt  
while [[ -z $brInt || $lan != $brInt && $wlan != $brInt ]]; do
  read -e -p "Invalid entry, enter a valid interface: " brInt
done
sudo vpncmd /server localhost /password:$pswd /cmd BridgeCreate $hubName /DEVICE:$brInt > /dev/null
echo -e "Bridge created!\n"


### Create clients/users
echo "=== Creating clients for $hubName... ==="
read -e -p "Number of clients/users to make on this hub: " numC
while [[ -z $numC || $numC =~ ^[a-zA-Z]+$ ]]; do
  read -e -p "Not a valid number, enter a valid number: " numC
done
echo "---"
for i in $( seq 1 $numC ); do
  read -e -p "Client username: " uname
  while [[ -z $uname ]]; do
    read -e -p "Input cannot be empty, enter a valid username: " uname  
  done
  read -s -p "Client password: " cPswd
  while [[ -z $cPswd ]]; do
    read -s -p "\nInput cannot be empty, enter a valid password: " cPswd    
  done
  sudo vpncmd /server localhost /password:$pswd /adminhub:$hubName \
    /cmd UserCreate $uname /GROUP:none /REALNAME:none /NOTE:none > /dev/null
  sudo vpncmd /server localhost /password:$pswd /adminhub:$hubName \
    /cmd UserPasswordSet $uname /PASSWORD:$cPswd > /dev/null
  echo -e "\nSuccess!\n"
done
  echo -e "Client(s) finished!\n"

  
### Configure DDNS
echo "=== Configuring DDNS... ==="
read -e -p "Enter a unique hostname for the VPN: " ddns
while true; do
  if [[ -z $ddns ]]; then
    read -e -p "Input cannot be blank, enter a unique hostname for the VPN: " ddns
  else
    check=$(sudo vpncmd /server localhost /password:$pswd /cmd DynamicDNSSetHostname $ddns \
      | grep "is already used")
    if [[ "$check" ]]; then
      read -e -p "That hostname is already taken, try a different one: " ddns
    else
      break
    fi
  fi
done
sudo vpncmd /server localhost /password:$pswd /cmd DynamicDNSSetHostname $ddns > /dev/null
echo -e "DDNS configured!\n"

  
### Set up L2TP/IPSec
echo "=== Setting up L2TP/IPSec... ==="
read -e -p "Enable L2TP/IPSec? (Y/n): " choice
if [[ $choice == "y"  || $choice == "Y" || -z $choice ]]; then
  read -s -p "Enter a shared key to use: " psk
  while [[ -z $psk ]]; do
    read -s -p "Key cannot be blank, enter a valid key: " psk
  done
  sudo vpncmd /server localhost /password:$pswd /cmd IPsecEnable /L2TP:yes \
    /L2TPRAW:no /ETHERIP:no /PSK:$psk /DEFAULTHUB:$hubName > /dev/null
  echo -e "\nL2TP/IPSec set up!\n"
else
  echo -e "Skipping L2TP/IPSec.\n"
fi


### Cleanup
echo -e "=== Cleaning up... ==="
sudo rm softether-vpnserver-*
sudo rm se-vpnserver.service
sleep 2

### All done!
clear
printf '=%.0s' {1..41}
echo
echo -e " ___  _        _      _             _  _"
echo -e "| __|(_) _ _  (_) ___| |_   ___  __| || |"
echo -e "| _| | || ' \ | |(_-<| ' \ / -_)/ _' ||_|"
echo -e "|_|  |_||_||_||_|/__/|_||_|\___|\__,_|(_)"
printf '=%.0s' {1..41}
echo -e "\n>> DDNS Hostname: $(sudo vpncmd /server localhost /password:$pswd /cmd DynamicDNSGetStatus | \
    grep "Assigned Dynamic DNS Hostname (Full)" | awk '{print substr($6,2)}')"
echo -e ">> Global IPv4 Address: $(sudo vpncmd /server localhost /password:$pswd /cmd DynamicDNSGetStatus | \
    grep IPv4 | awk '{print substr($4,2)}')"
echo -e ">> Local IP Address: $(ip addr show eth0 | grep "inet " | awk '{print $2}')"
echo -e "\nFor extra configuration, download the SoftEther Server Manager @ https://www.softether.org/.\n"
echo -e "- illogicalpartition @ github.com -\n\n"

exit 0
