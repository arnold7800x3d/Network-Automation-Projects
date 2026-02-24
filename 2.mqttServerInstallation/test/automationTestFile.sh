#!/bin/bash

# convert files to UNIX format
dos2unix /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/inventory/inventory.txt
dos2unix /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/mosquittoInstallation.sh

# make files executable
chmod u+x /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/inventory/inventory.txt
chmod u+x /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/mosquittoInstallation.sh

# run automation file
/home/netadmin/networkAutomationProjects/2.mqttServerInstallation/mosquittoInstallation.sh

