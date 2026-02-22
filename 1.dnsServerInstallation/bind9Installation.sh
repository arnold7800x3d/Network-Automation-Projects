#!/bin/bash

# error handling
set -euo pipefail

# read from the inventory file
source /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/inventory/inventory.txt

echo -e "Loaded server IP address: $serverIP\n"
echo -e "Loaded client IP addresses: ${clientIPs[*]}\n"

# check health status of the server and clients
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
setupBind9Server(){
    local serverIPAddress=$1

    echo -e "Subtask 2.1 System update and bind9 packages installing...\n"
    ssh $serverIPAddress "apt update"
    ssh $serverIPAddress "apt install bind9 bind9-dnsutils -y"

    echo -e "Subtask 2.2 Verifying installation...\n"
    ssh $serverIPAddress "systemctl status bind9 --no-pager"

    echo -e "Subtask 2.3 Configuring the base configuration file /etc/bind/named.conf...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/templates/named.conf $serverIPAddress:/etc/bind/named.conf
    ssh $serverIPAddress "cat /etc/bind/named.conf"

    echo -e "Subtask 2.4 Configuring DNS forwarders and various DNS options...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/templates/named.conf.options $serverIPAddress:/etc/bind/named.conf.options
    ssh $serverIPAddress "cat /etc/bind/named.conf.options"

    echo -e "Subtask 2.5 Adding zone for the domain...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/templates/named.conf.internal-zones $serverIPAddress:/etc/bind/named.conf.internal-zones
    
    echo -e "Subtask 2.6 Creating the zone file...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/templates/db.homelab.com $serverIPAddress:/etc/bind/db.homelab.com
    ssh $serverIPAddress "ls /etc/bind/"

    echo -e "Subtask 2.7 Updating the serial number of the zone file...\n"
    ssh $serverIPAddress "sed -i 's/xxxxxxxxxx/$(date +%Y%m%d01)/' /etc/bind/db.homelab.com"
    ssh $serverIPAddress "cat /etc/bind/db.homelab.com"

    echo -e "Subtask 2.8 Creating the reverse lookup file...\n"
    rsync -avz /home/netadmin/networkAutomationProjects/1.dnsServerInstallation/templates/db.100.168.192 $serverIPAddress:/etc/bind/db.100.168.192
    ssh $serverIPAddress "ls /etc/bind"

    echo -e "Subtask 2.9 Updating the serial number of the reverse lookup file...\n"
    ssh $serverIPAddress "sed -i 's/xxxxxxxxxx/$(date +%Y%m%d01)/' /etc/bind/db.100.168.192"
    ssh $serverIPAddress "cat /etc/bind/db.100.168.192"

    echo -e "Subtask 2.10 Validating BIND configuration...\n"
    ssh $serverIPAddress "named-checkconf"
    ssh $serverIPAddress "named-checkzone homelab.com /etc/bind/db.homelab.com"
    ssh $serverIPAddress "named-checkzone 100.168.192.in-addr.arpa /etc/bind/db.100.168.192"

    echo -e "Subtask 2.11 Restarting the DNS server...\n"
    ssh $serverIPAddress "systemctl restart bind9 --no-pager"
    ssh $serverIPAddress "systemctl status bind9 --no-pager"
}

# updating clients to use the newly configured DNS server and verifying resolution
verifyClientResolution(){
    local clientIPAddress=$1

    echo -e "Subtask 3.1 Updating resolution file. Note this update is temporary, network changes will result in a change in this file...\n"
    ssh $clientIPAddress "sed -i '2 i\nameserver 192.168.100.24' /etc/resolv.conf"
    ssh $clientIPAddress "cat /etc/resolv.conf"

    echo -e "Subtask 3.2 Verifying resolution...\n"
    ssh $clientIPAddress "nslookup dns.homelab.com"
    ssh $clientIPAddress "dig dns.homelab.com"
    ssh $clientIPAddress "nslookup 192.168.100.24"
    ssh $clientIPAddress "dig -x 192.168.100.24"
}

# main execution section
echo -e "Task 2. Installing and configuring bind9...\n"
setupBind9Server $serverIP

echo -e "Task 3 Updating clients 1 and 2 to use the DNS server...\n"
for nodeIP in "${clientIPs[@]}";
do
    verifyClientResolution $nodeIP
done
 