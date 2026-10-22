Python script for updating static DHCP mappings from OPNSense and automatic update Trilium note 'Network Inventory'<br>
Crontab: First day of every month:<br> ```15 3 1 * * /usr/bin/python3 /srv/docker/network-inventory/update_inventory.py >> /srv/docker/network-inventory/update.log 2>&1```
