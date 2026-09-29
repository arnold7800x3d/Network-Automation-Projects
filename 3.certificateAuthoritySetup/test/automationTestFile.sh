#!/bin/bash

# convert files to unix format
dos2unix /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/inventory/inventory.txt
dos2unix /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthoritySetup.sh
dos2unix /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthorityUpdate.sh

# make files executable
chmod u+x /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/inventory/inventory.txt
chmod u+x /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthoritySetup.sh
chmod u+x /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthorityUpdate.sh

# run automation files
if [ ${1,,} == setup ]; then
    /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthoritySetup.sh
elif [ ${1,,} == update ]; then
    /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/certificateAuthorityUpdate.sh
else
    echo "Invalid command option"
fi

