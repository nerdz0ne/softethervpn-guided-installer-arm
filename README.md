# SoftEther VPN Guided Installer for Debian ARM devices
Script is a guided installer for SoftEther VPN server on ARM devices.
- Testing hardware: RasPi 4, RasPi 3, OrPi Zero 2
- Testing OS: Raspian Lite x86 and x64, Armbian x86
  
### UPDATE: 4/23/2021
- arm64 support added, tested working on Raspbian Lite Buster (x64) on Raspi 4 :^)
- Building from source is the only way as of now, pulls the latest version from the Stable repo
- Custom Makefile: only installs vpnserver & vpmcmd, reconfigured directories, syntax fixed for compatibility
- Added vpncmd executable 
- General tweaks, fixes, etc.

### UPDATE: 4/15/2021
- Updated to download the newest version.
- Tested working on Raspbian Lite Buster (x86), running on Raspberry Pi 4 
- Testing working on Armbian Buster (x86), running on Orange Pi Zero 2
- arm64 is a WIP

---

## HOW TO RUN

```
git clone https://github.com/illogicalpartition/softethervpn-guided-installer-arm.git  
cd softethervpn-guided-installer-arm  
sudo chmod 755 softether_install_deb_arm.sh  
sudo ./softether_install_deb_arm.sh  
```

---


SoftEther VPN website: https://www.softether.org/