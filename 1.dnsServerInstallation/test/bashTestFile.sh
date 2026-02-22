#!/bin/bash

# convert files into UNIX format
dos2unix /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/inventory/inventory.txt
dos2unix /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/bind9Installation.sh

# make files executable
chmod u+x /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/inventory/inventory.txt
chmod u+x /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/bind9Installation.sh

# run automation file
/home/netadmin/networkAutomationProjects/1.dnsServerInstallation/bind9Installation.sh