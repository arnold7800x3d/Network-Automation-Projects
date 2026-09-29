#!/bin/bash

# error handling
set -euo pipefail

# read from the inventory file
source /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/inventory/inventory.txt

echo -e "Loaded server IP addresses: $localCAServerIP\n"

# check if the server is up
echo -e "Task 1 - Checking if the server is up...\n"
ping -c 4 $localCAServerIP

# update the csr and the ext file and sign the certificate
updateServerConfiguration(){
    local serverIP=$1

    echo -e "Subtask 2.1 - Update the server's certificate signing request...\n"
    ssh $serverIP "openssl req -new -key /home/netadmin/localCA/certs/server.key -out /home/netadmin/localCA/certs/server.csr -subj "/C=KE/ST=Nairobi/L=Nairobi/O=Makerspace/OU=Research/CN=$serverIP""

    echo -e "Subtask 2.2 - Update the server.ext file...\n"
    ssh $serverIP "sed -i '4c\\subjectAltName = IP:$serverIP' /home/netadmin/localCA/certs/server.ext"
    ssh $serverIP "cat /home/netadmin/localCA/certs/server.ext"

    echo -e "Subtask 2.3 - Sign the server CSR with the root CA certificate and create the server certificate...\n"
    ssh $serverIP "openssl x509 -req -in /home/netadmin/localCA/certs/server.csr -CA /home/netadmin/localCA/certs/ca.crt -CAkey /home/netadmin/localCA/certs/ca.key -CAcreateserial -out /home/netadmin/localCA/certs/server.crt -days 365 -sha256 -extfile /home/netadmin/localCA/certs/server.ext"
    ssh $serverIP "openssl verify -CAfile /home/netadmin/localCA/certs/ca.crt /home/netadmin/localCA/certs/server.crt"
    ssh $serverIP "openssl x509 -in /home/netadmin/localCA/certs/server.crt -noout -subject -issuer -ext subjectAltName"
}

# main execution section
echo -e "Task 2 - Updating the server csr, .ext file and signing the csr...\n"
updateServerConfiguration $localCAServerIP