#!/bin/bash

dos2unix /home/netadmin/networkAutomationProjects/1.bind9Installation/inventory/inventory.txt
dos2unix /home/netadmin/networkAutomationProjects/1.bind9Installation/bash/bind9Installation.sh

chmod u+x /home/netadmin/networkAutomationProjects/1.bind9Installation/inventory/inventory.txt
chmod u+x /home/netadmin/networkAutomationProjects/1.bind9Installation/bash/bind9Installation.sh

/home/netadmin/networkAutomationProjects/1.bind9Installation/bash/bind9Installation.sh