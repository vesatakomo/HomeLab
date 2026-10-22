##### Network-inventory
Python script for updating static DHCP mappings from OPNSense and automatic update Trilium note 'Network Inventory'<br>
Crontab: First day of every month:<br> ```15 3 1 * * /usr/bin/python3 /srv/docker/network-inventory/update_inventory.py >> /srv/docker/network-inventory/update.log 2>&1```
##### mac_check.sh
My docker stack had strange delays when connecting to containers. Turned out there was duplicate MAC-addresses in docker network. This python script is for checking duplicate MAC addresses
