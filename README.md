# SoftEther VPN Guided Installer for Debian ARM devices
Script is a guided installer for SoftEther VPN server on ARM devices.
- Testing hardware: Raspbery Pi 4 & 3, OrPi Zero 2
- Testing OS: Raspian Lite x86 and x64, Armbian x86
  
#### UPDATE: 4/23/2021
- arm64 support added, tested working on Raspbian Lite Buster (x64) on Raspi 4
- Building from source is the only way as of now, pulls the latest version from the Stable repo
- Custom Makefile: only installs vpnserver & vpmcmd, reconfigured directories, syntax fixed for compatibility
- Added vpncmd executable 
- General tweaks, fixes, etc.

---

## HOW TO RUN

```
git clone https://github.com/illogicalpartition/softethervpn-guided-installer-arm.git  
cd softethervpn-guided-installer-arm  
sudo chmod 755 softetherinstall_deb_Arm.sh  
sudo ./softether_install_deb_arm.sh  
```

---


SoftEther VPN website: https://www.softether.org/