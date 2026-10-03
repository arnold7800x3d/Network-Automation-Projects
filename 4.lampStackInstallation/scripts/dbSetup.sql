-- Create a database user
CREATE USER 'netadmin'@'localhost' IDENTIFIED BY 'h0m353rv3r';

-- Create a database
CREATE DATABASE TestDB;

-- Grant privileges
GRANT ALL PRIVILEGES ON TestDB.* TO 'netadmin'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Display databases
SHOW DATABASES;

-- Display users
SELECT User, Host FROM mysql.user;

EXIT;