#!/bin/bash

# convert files to unix format
dos2unix /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/inventory/inventory.txt
dos2unix /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/lampStackInstallation.sh

# make files executable
chmod u+x /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/inventory/inventory.txt
chmod u+x /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/lampStackInstallation.sh

# run automation file
/home/netautomator/Network-Automation-Projects/4.lampStackInstallation/lampStackInstallation.sh
