#!/bin/bash

# error handling
set -euo pipefail

# read from the inventory file
source /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/inventory/inventory.txt

# check if the server is up
echo -e "Task 1 - Checking if the server is up...\n"
ping -c 4 $lampServer

# install the lamp stack
setupLAMPStack(){
    local serverIP=$1

    echo -e "Subtask 2.1 - System update...\n"
    ssh $serverIP "apt update"

    echo -e "Subtask 2.2 - Installing apache...\n"
    ssh $serverIP "apt install apache2 -y"

    echo -e "Substask 2.3 - Verifying installation...\n"
    ssh $serverIP "systemctl start apache2"
    ssh $serverIP "systemctl enable apache2"
    ssh $serverIP "systemctl status apache2 --no-pager"

    echo -e "Subtask 2.4 - Installing MariaDB database server...\n"
    ssh $serverIP "apt install mariadb-server -y"

    echo -e "Substask 2.3 - Verifying installation...\n"
    ssh $serverIP "systemctl start mariadb"
    ssh $serverIP "systemctl enable mariadb"
    ssh $serverIP "systemctl status mariadb --no-pager"

    echo -e "Subtask 2.5 - Installing PHP...\n"
    ssh $serverIP "apt install php libapache2-mod-php php-mysql php-cgi php-mysqli php-pear php-mbstring php-common php-phpseclib -y"

    echo -e "Subtask 2.6 - Verifying installation...\n"
    ssh $serverIP "php -v"

    echo -e "Subtask 2.7 - Create a database user to use for loggin into phpMyAdmin...\n"
    ssh $serverIP "mysql < /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/scripts/dbSetup.sql"

    echo -e "Subtask 2.8 - Installing phpMyAdmin...\n"
    ssh $serverIP "cd /var/www/html && wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"

    echo -e "Subtask 2.9 - Extracting the archive, renaming and setting the correct permissions...\n"
    ssh $serverIP "tar -xvzf phpMyAdmin-latest-all-languages.tar.gz"
    ssh $serverIP "rm phpMyAdmin-latest-all-languages.tar.gz"
    ssh $serverIP "mv phpMyAdmin-5.2.2-all-languages phpmyadmin"
    ssh $serverIP "chown -R www-data:www-data phpmyadmin/"

    echo -e "Subtask 2.10 - Creating a virtual host file to configure phpMyAdmin to be accessible via a domain name...\n"
    rsync -avz /home/netautomator/Network-Automation-Projects/4.lampStackInstallation/templates/phpmyadmin.conf $serverIPAddress:/etc/apache2/sites-available/phpmyadmin.conf
    ssh $serverIP "ls /etc/apache2/sites-available"

    echo -e "Subtask 2.11 - Enabling the Apache configuration files for Wordpress...\n"
    ssh $serverIP "sudo a2enmod rewrite"
    ssh $serverIP "sudo a2ensite phpmyadmin.conf"

    echo -e "Subtask 2.12 - Checking the Apache2 syntax...\n"
    ssh $serverIP "apachectl -t"

    echo -e "Subtask 2.13 - Restarting Apache...\n"
    ssh $serverIP "systemctl restart apache2"

}

# main execution section
setupLAMPStack $lampServer