#!/bin/bash

# error handling
set -euo pipefail

# read from the inventory file
source /home/netautomator/Network-Automation-Projects/3.certificateAuthoritySetup/inventory/inventory.txt

echo -e "Loaded server IP addresses: $localCAServerIP\n"

# check if the server is up
echo -e "Task 1 - Checking if the server is up...\n"
ping -c 4 $localCAServerIP

# setup the local CA and sign a server certificate
configureLocalCAandServer(){
    local serverIP=$1

    echo -e "Subtask 2.1 - System update...\n"
    ssh $serverIP "apt update" 

    echo -e "Subtask 2.2 - Create a structured directory for the root CA...\n"
    ssh $serverIP "mkdir -p /home/netadmin/localCA/certs && chmod 700 /home/netadmin/localCA/certs"

    echo -e "Subtask 2.3 - Create a private key for the root CA...\n"
    ssh $serverIP "openssl genrsa -out /home/netadmin/localCA/certs/ca.key 2048"

    echo -e "Subtask 2.4 - Generate self-signed CA certificate and secure the CA key...\n"
    ssh $serverIP "openssl req -x509 -new -nodes -key /home/netadmin/localCA/certs/ca.key -sha256 -days 365 -out /home/netadmin/localCA/certs/ca.crt -subj "/C=KE/ST=Nairobi/L=Nairobi/O=Makerspace/OU=Research/CN=MakerspaceRootCA""
    ssh $serverIP "chmod 600 /home/netadmin/localCA/certs/ca.key"

    echo -e "Subtask 2.5 - Create a key for the server...\n"
    ssh $serverIP "openssl genrsa -out /home/netadmin/localCA/certs/server.key 2048"

    echo -e "Subtask 2.6 - Generate a certificate signing request for the server...\n"
    ssh $serverIP "openssl req -new -key /home/netadmin/localCA/certs/server.key -out /home/netadmin/localCA/certs/server.csr -subj "/C=KE/ST=Nairobi/L=Nairobi/O=Makerspace/OU=Research/CN=192.168.100.24""

    echo -e "Subtask 2.7 - Create a config file for the Subject Alternative Name (SAN); server.ext...\n"
    ssh $serverIP "touch /home/netadmin/localCA/certs/server.ext"
    ssh $serverIP "cat > /home/netadmin/localCA/certs/server.ext" <<'EOF'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment
subjectAltName=IP:192.168.100.24
EOF
    ssh $serverIP "cat /home/netadmin/localCA/certs/server.ext"
    
    echo -e "Subtask 2.8 - Sign the server CSR with the root CA certificate and create the server certificate...\n"
    ssh $serverIP "openssl x509 -req -in /home/netadmin/localCA/certs/server.csr -CA /home/netadmin/localCA/certs/ca.crt -CAkey /home/netadmin/localCA/certs/ca.key -CAcreateserial -out /home/netadmin/localCA/certs/server.crt -days 365 -sha256 -extfile /home/netadmin/localCA/certs/server.ext"

    echo -e "Subtask 2.9 - Verify the certificate...\n"
    ssh $serverIP "openssl x509 -in /home/netadmin/localCA/certs/server.crt -noout -subject -issuer -ext subjectAltName"
}

# main execution section
echo -e "Task 2 - Setting up the root CA and signing a signing request...\n"
configureLocalCAandServer $localCAServerIP