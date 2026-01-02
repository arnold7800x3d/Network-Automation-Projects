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

    echo -e "Subtask 2.3 Editing the base configuration file /etc/bind/named.conf...\n"
    ssh $serverIPAddress 'echo "include \"/etc/bind/named.conf.internal-zones\";" >> /etc/bind/named.conf'
    ssh $serverIPAddress "cat /etc/bind/named.conf"

    echo -e "Subtask 2.4 Configuring DNS forwarders and various DNS options...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.bind9Installation/templates/named.conf.options $serverIPAddress:/etc/bind/named.conf.options
    ssh $serverIPAddress "cat /etc/bind/named.conf.options"

    echo -e "Subtask 2.5 Adding zone for the domain...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.bind9Installation/templates/named.conf.internal-zones $serverIPAddress:/etc/bind/named.conf.internal-zones
    
    echo -e "Subtask 2.6 Creating the zone file...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.bind9Installation/templates/db.asl.com $serverIPAddress:/etc/bind/db.asl.com
    ssh $serverIPAddress "ls /etc/bind/"

    echo -e "Subtask 2.7 Updating the serial number of the zone file...\n"
    local serial=`date +"%Y%m%d01"`
    ssh $serverIPAddress "sed -i 's/xxxxxxxxxx/$serial/' /etc/bind/db.asl.com"
    ssh $serverIPAddress "cat /etc/bind/db.asl.com"

    echo -e "Subtask 2.8 Creating the reverse lookup file...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.bind9Installation/templates/db.100.168.192 $serverIPAddress:/etc/bind/db.100.168.192
    ssh $serverIPAddress "ls /etc/bind"

    echo -e "Subtask 2.9 Updating the serial number of the reverse lookup file...\n"
    local serial=`date +"%Y%m%d01"`
    ssh $serverIPAddress "sed -i 's/xxxxxxxxxx/$serial/' /etc/bind/db.100.168.192"
    ssh $serverIPAddress "cat /etc/bind/db.100.168.192"

    echo -e "Subtask 2.10 Restarting the DNS server...\n"
    ssh $serverIPAddress "systemctl restart bind9"
    ssh $serverIPAddress "systemctl status bind9"
}

setupBind9Server $serverIP