# SoftEther VPN Guided Installer (Debian ARM)
Script installs SoftEther VPN server and guides the user through its essential setup. Works on x86 and x64 ARM devices running Debian-based distros.
Current testing devices:
- Raspbery Pi 4 (Raspbian Lite Buster x64)
- Raspberry Pi 3 (Raspbian Lite Buster x86)
- Orange Pi Zero 2 (Armbian Buster x86)
  
#### UPDATE: 4/23/2021
- arm64 support added, tested working on Raspbian Lite Buster (x64) on Raspi 4
- Building from source is the only way as of now, pulls the latest version from the Stable repo
- Custom Makefile: only installs vpnserver & vpmcmd, reconfigured directories, syntax fixed for compatibility
- Added vpncmd executable 
- General tweaks, fixes, etc.

---

## RUN DIRECTIONS

```
sudo apt-get install git -y
git clone https://github.com/illogicalpartition/softethervpn-guided-installer-arm.git  
cd softethervpn-guided-installer-arm  
sudo chmod 755 softetherInstall_deb_Arm.sh  
sudo ./softetherInstall_deb_Arm.sh  
```

---


SoftEther VPN website: https://www.softether.org/