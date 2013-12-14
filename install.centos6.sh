#!/bin/bash -x

#
# xaviertidus/FreeRadiusQuickScript
#
# Installs FreeRadius in a very basic way on CentOS 6
#
# @package FreeRadiusQuickScript 1.0
# @since FreeRadiusQuickScript 1.0
# @author Xavier Hutchinson
#

(

#VAR Declaration
RAD_MYSQL_USER_PASS="radpass"
RAD_AUTH_REQ_SECRET="testing123"

echo "Before we begin I need just two peices of information from you:"
read "Please enter a password for freeradius to use to connect to MySQL [radpass]:" IN_RAD_MYSQL_USER_PASS
read "Please enter a password for localhost to attempt to validate logins for users against your radius [testing123]:" IN_RAD_AUTH_REQ_SECRET

if len

#Let's go!
yum install freeradius freeradius-mysql freeradius-utils mysql-server -y

### MySQL
# start MySQL
service mysqld start
# add our radius database and permissions for the radius user.
mysql -uroot << EOFMYSQL
CREATE DATABASE radius;
GRANT ALL PRIVILEGES ON radius.* TO radius@localhost IDENTIFIED BY "radpass";
flush privileges;
use radius;
SOURCE /etc/raddb/sql/mysql/schema.sql
INSERT INTO `radcheck` (`id`, `username`, `attribute`, `op`, `value`) VALUES (1,'myusername','User-Password',':=','mypassword');
exit
EOFMYSQL


### sql.conf
# backup original
echo "Backing up '/etc/raddb/sql.conf' to '/etc/raddb/sql.conf.original'"
mv /etc/raddb/sql.conf /etc/raddb/sql.conf.original
# configure this script's version of sql.conf
sed -i "s/FRQS-RAD_MYSQL_USER_PASS/$RAD_AUTH_REQ_SECRET/g" "/opt/sql.conf"
# get this script version
echo "Writing our version of '/etc/raddb/sql.conf'"
mv /opt/sql.conf /etc/raddb/sql.conf

### radiusd.conf
# backup original
echo "Backing up '/etc/raddb/radiusd.conf' to '/etc/raddb/radiusd.conf.original'"
mv /etc/raddb/radiusd.conf /etc/raddb/radiusd.conf.original
# get this script version
echo "Writing our version of '/etc/raddb/radiusd.conf'"
mv /opt/radiusd.conf /etc/raddb/radiusd.conf

### sites-available/default
# backup original
echo "Backing up '/etc/raddb/sites-available/default' to '/etc/raddb/sites-available/default.original'"
mv /etc/raddb/sites-available/default /etc/raddb/sites-available/default.original
# get this script version
echo "Writing our version of '/etc/raddb/sites-available/default'"
mv /opt/sites-available/default /etc/raddb/sites-available/default

### sites-available/inner-tunnel
# backup original
echo "Backing up '/etc/raddb/sites-available/inner-tunnel' to '/etc/raddb/sites-available/inner-tunnel.original'"
mv /etc/raddb/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel.original
# get this script version
echo "Writing our version of '/etc/raddb/sites-available/inner-tunnel'"
mv /opt/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel

### clients.conf
# backup original
echo "Backing up '/etc/raddb/clients.conf' to '/etc/raddb/clients.conf.original'"
mv /etc/raddb/clients.conf /etc/raddb/clients.conf.original
# get this script version
echo "Writing our version of '/etc/raddb/clients.conf'"
mv /opt/clients.conf /etc/raddb/clients.conf

### FreeRadius
# start free radius
echo "Starting FreeRadius"
service radiusd restart
# test an authentication request to free radius
echo "Sending a test auth request to FreeRadius"
radtest myusername mypassword 127.0.0.1 0 $RAD_AUTH_REQ_SECRET
echo " "
echo " "
echo "Job complete! Remember these details:"
echo " "
echo "Your radius user for MySQL uses this as a password: $RAD_MYSQL_USER_PASS"
echo "When you are trying to authenticate a user from localhost, this is the authentication secret for FreeRadius: $RAD_AUTH_REQ_SECRET"
echo " "
echo "############### IMPORTANT! ###############"
echo "1) You need to secure your mysql installation now by running: /usr/bin/mysql_secure_installation If you need help with this see http://xaviertidus.com/?p=47 for more information"
echo "2) A testing user was added to the radius database (username: myusername password: mypassword), don't forget to delete it when you are finished testing! It's a security risk. If you need help with this see http://xaviertidus.com/?p=49 for more information"
echo "3) If you plan to have external servers authenticating against your new FreeRadius server, you need to add the appropriate entries in the /etc/raddb/clients.conf file. If you need help with this see http://xaviertidus.com/?p=45 for more information"





) 2>&1 | tee /var/log/FreeRadiusQuickScript-CentOS6-installer.log