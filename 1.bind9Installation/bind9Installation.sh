#!/bin/bash

# read from the inventory file
source /home/netadmin/networkAutomationProjects/1.bind9Installation/inventory/inventory.txt

echo -e "Loaded server IP address: $serverIP\n"
echo -e "Loaded client IP addresses: ${clientIPs[*]}\n"

# check health status of the server and two clients
echo -e "Task 1. Checking the health status of the server and clients...\n"
echo -e "Pinging server $serverIP...\n"
ping -c 4 $serverIP
nodeHealthCheck(){
    local ipAddress=$1
    echo -e "Pinging client $ipAddress...\n"
    ping -c 4 $ipAddress
}

for clientIp in "${clientIPs[@]}";
do
    nodeHealthCheck $clientIp
done

# install and configure bind on the server
echo -e "Task 2. Installing and configuring bind9...\n"
setupBind9Server(){
    local serverIPAddress=$1

    echo -e "Subtask 2.1 System update and bind9 packages installing...\n"
    ssh $serverIPAddress "apt update"
    ssh $serverIPAddress "apt install bind9 bind9-dnsutils -y"

    echo -e "Subtask 2.2 Verifying installation...\n"
    ssh $serverIPAddress "systemctl status bind9"

    echo -e "Subtask 2.3 Creating the zone file...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.bind9Installation/templates/db.asl.com $serverIPAddress:/etc/bind/db.asl.com
    ssh $serverIPAddress "ls /etc/bind/"

    echo -e "Subtask 2.4 Updating the serial number of the zone file...\n"
    local serial=`date +"%Y%m%d01"`
    ssh $serverIPAddress "sed -i 's/xxxxxxxxxx/$serial/' /etc/bind/db.asl.com"
    ssh $serverIPAddress "cat /etc/bind/db.asl.com"
}

setupBind9Server $serverIP