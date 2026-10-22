#### Installed scripts:
- Storage Health Monitor
- Ultimate-Updater (https://github.com/BassT23/Proxmox)
- Dynamic vCPUs. Tdarr encoding -> dockerhost VM vCPUs 6 ->12
#### Basic settings:
- NFS shares for JellyfinLXC
    1. 192.168.1.5:/srv/vault /mnt/storage nfs defaults        0       0
    2. 192.168.1.20:/mnt/datadisk/shares/Videolibrary /mnt/videolibrary nfs defaults   0       0
- Crontab mounting shares after VM's are up ```@reboot sleep 180 && /usr/bin/mount -a```
 
