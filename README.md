# HomeLab
Homelab documentation for current setup
### Proxmox at HP Proliant DL380 G7
##### Linux LXC's
- Jellyfin
- Pulse (https://github.com/rcourtman/Pulse)
##### Linux VM's
- Dockerhost
- Fileserver (Debian file storage)
- Owncloud
- Debian OS
### Proxmox at HP Prodesk 600 G3
Internet Gateway machine
- vmbr0 bridge, 192.168.1.105/24, Gateway 192.168.1.1, VLAN aware - ID 100
##### LXC
- PiHole
##### VM's
- OPNSense
- Netdocker (Debian Trixie)
  1. Vaultwarden
  2. Nginx Reverse Proxy
### Proxmox at Intel NUC
- Home Assistant VM
### Debian Trixie at HP Proliant ML350 G7
- Backup server running MergerFS & Snapraid
