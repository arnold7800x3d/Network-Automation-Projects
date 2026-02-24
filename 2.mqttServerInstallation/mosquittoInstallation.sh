#!/bin/bash

# error handling
set -euo pipefail

# read from the inventory file
source /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/inventory/inventory.txt

echo -e "Loaded server IP addresses: $mqttServerIP\n"

# check if server is up
echo -e "Task 1. Checking if the server is up...\n"
ping -c 4 $mqttServerIP

# install and configure bind on the server
setupMosquittoMQTTServer(){
    local serverIPAddress=$1

    echo -e "Subtask 2.1 System update and mosquitto mqtt packages installing...\n"
    ssh $serverIPAddress "apt update && apt install mosquitto mosquitto-clients -y"

    echo -e "Subtask 2.2 Verifying installation...\n"
    ssh $serverIPAddress "systemctl enable mosquitto"
    ssh $serverIPAddress "systemctl start mosquitto"
    ssh $serverIPAddress "systemctl status mosquitto --no-pager"

    echo -e "Subtask 2.3 Setting up basic configuration...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/templates/mosquitto.conf $serverIPAddress:/etc/mosquitto/mosquitto.conf  
    ssh $serverIPAddress "cat /etc/mosquitto/mosquitto.conf"

    echo -e "Subtask 2.4 Configuring authentication. Set up your user by creating a password...\n"
    ssh $serverIPAddress "mosquitto_passwd -c /etc/mosquitto/passwd Arnold"

    echo -e "Subtask 2.5 Fix file permissions to allow mosquitto to read password file...\n"
    ssh $serverIPAddress "chown mosquitto: /etc/mosquitto/passwd"
    ssh $serverIPAddress "chmod 600 /etc/mosquitto/passwd"  

    echo -e "Subtask 2.6 Setting up certificates for TLS support...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/2.mqttServerInstallation/templates/certs/ $serverIPAddress:/etc/mosquitto/certs/  

    echo -e "Subtask 2.7 Fix file permissions to allow mosquitto to read certificates...\n"
    ssh $serverIPAddress "chown -R mosquitto: /etc/mosquitto/certs"
    ssh $serverIPAddress "chmod 644 /etc/mosquitto/certs/ca.crt /etc/mosquitto/certs/server.crt"
    ssh $serverIPAddress "chmod 600 /etc/mosquitto/certs/server.key"
    ssh $serverIPAddress "systemctl restart mosquitto"
    ssh $serverIPAddress "systemctl status mosquitto --no-pager"    
}

# main execution section
echo -e "Subtask 2. Installing and configuring mosquitto MQTT...\n"
setupMosquittoMQTTServer $mqttServerIP