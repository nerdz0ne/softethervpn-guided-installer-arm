# SoftEther VPN Guided Installer (Debian ARM)
Script installs SoftEther VPN server and guides the user through essential setup. Works on x86 and x64 ARM devices running Debian-based distros.
Current testing devices:
- Raspbery Pi 4 (Raspbian Lite Buster x64)
- Raspberry Pi 3 (Raspbian Lite Buster x86)
- Orange Pi Zero 2 (Armbian Buster x86)
  
#### UPDATE: 12/28/2021
- Updated script to now use arm64 download package, rather than the custom makefile workaround and building from source. 
- Expanded bridge choice to include interfaces aside from the the Raspi's wired and wireless interfaces (e.g. USB adapters).
- Made DDNS an optional feature to enable/configure.

---

## RUN DIRECTIONS

```
sudo apt-get install git -y
git clone https://github.com/illogicalpartition/softethervpn-guided-installer-arm.git  
cd softethervpn-guided-installer-arm  
sudo chmod 755 softetherInstall_debArm.sh  
sudo ./softetherInstall_debArm.sh  
```

---


SoftEther VPN website: https://www.softether.org/