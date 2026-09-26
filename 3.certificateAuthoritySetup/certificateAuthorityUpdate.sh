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
    remoteUser=$(whoami)

    echo -e "Subtask 2.1 - Update the server's certificate signing request...\n"
    ssh $serverIP "openssl req -new -key /home/$remoteUser/localCA/certs/server.key -out /home/$remoteUser/localCA/certs/server.csr -subj "/C=KE/ST=Nairobi/L=Nairobi/O=Makerspace/OU=Research/CN=$serverIP""

    echo -e "Subtask 2.2 - Update the server.ext file...\n"
    ssh $serverIP "sed -i 4c\subjectAltName = IP:$serverIP /home/$remoteUser/localCA/certs/server.ext"

    echo -e "Subtask 2.3 - Sign the server CSR with the root CA certificate and create the server certificate...\n"
    ssh $serverIP "openssl x509 -req -in /home/$remoteUser/localCA/certs/server.csr -CA /home/$remoteUser/localCA/certs/ca.crt -CAkey /home/$remoteUser/localCA/certs/ca.key -CAcreateserial -out /home/$remoteUser/localCA/certs/server.crt -days 365 -sha256 -extfile /home/$remoteUser/localCA/certs/server.ext"
}