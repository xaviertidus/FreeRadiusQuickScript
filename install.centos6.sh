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
echo "Please enter a password for freeradius to use to connect to MySQL [radpass]:" 
read IN_RAD_MYSQL_USER_PASS
echo "Please enter a password for localhost to attempt to validate logins for users against your radius [testing123]:" 
read IN_RAD_AUTH_REQ_SECRET

case "$IN_RAD_MYSQL_USER_PASS" in
  "") IN_RAD_AUTH_REQ_SECRET = $IN_RAD_AUTH_REQ_SECRET;;
esac

case "$IN_RAD_AUTH_REQ_SECRET" in
  "") IN_RAD_AUTH_REQ_SECRET = $IN_RAD_AUTH_REQ_SECRET;;
esac


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
echo -e '\E[37;44m'"\033[1m Backing up '/etc/raddb/sql.conf' to '/etc/raddb/sql.conf.original'\033[0m"
mv /etc/raddb/sql.conf /etc/raddb/sql.conf.original
# configure this script's version of sql.conf
sed -i "s/FRQS-RAD_MYSQL_USER_PASS/$RAD_AUTH_REQ_SECRET/g" "/opt/FreeRadiusQuickScript/sql.conf\033[0m"
# get this script version
echo -e '\E[37;44m'"\033[1m Writing our version of '/etc/raddb/sql.conf'\033[0m"
mv /opt/FreeRadiusQuickScript/sql.conf /etc/raddb/sql.conf

### radiusd.conf
# backup original
echo -e '\E[37;44m'"\033[1m Backing up '/etc/raddb/radiusd.conf' to '/etc/raddb/radiusd.conf.original'\033[0m"
mv /etc/raddb/radiusd.conf /etc/raddb/radiusd.conf.original
# get this script version
echo -e '\E[37;44m'"\033[1m Writing our version of '/etc/raddb/radiusd.conf'\033[0m"
mv /opt/FreeRadiusQuickScript/radiusd.conf /etc/raddb/radiusd.conf

### sites-available/default
# backup original
echo -e '\E[37;44m'"\033[1m Backing up '/etc/raddb/sites-available/default' to '/etc/raddb/sites-available/default.original'\033[0m"
mv /etc/raddb/sites-available/default /etc/raddb/sites-available/default.original
# get this script version
echo -e '\E[37;44m'"\033[1m Writing our version of '/etc/raddb/sites-available/default'\033[0m"
mv /opt/FreeRadiusQuickScript/sites-available/default /etc/raddb/sites-available/default

### sites-available/inner-tunnel
# backup original
echo -e '\E[37;44m'"\033[1m Backing up '/etc/raddb/sites-available/inner-tunnel' to '/etc/raddb/sites-available/inner-tunnel.original'\033[0m"
mv /etc/raddb/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel.original
# get this script version
echo -e '\E[37;44m'"\033[1m Writing our version of '/etc/raddb/sites-available/inner-tunnel'\033[0m"
mv /opt/FreeRadiusQuickScript/sites-available/inner-tunnel /etc/raddb/sites-available/inner-tunnel

### clients.conf
# backup original
echo -e '\E[37;44m'"\033[1m Backing up '/etc/raddb/clients.conf' to '/etc/raddb/clients.conf.original'\033[0m"
mv /etc/raddb/clients.conf /etc/raddb/clients.conf.original
# get this script version
echo -e '\E[37;44m'"\033[1m Writing our version of '/etc/raddb/clients.conf'\033[0m"
mv /opt/FreeRadiusQuickScript/clients.conf /etc/raddb/clients.conf

### FreeRadius
# ensure FreeRadius starts automatically
echo -e '\E[37;44m'"\033[1m Making sure FreeRadius will automatically start at boot\033[0m"
chkconfig radiusd on
# start free radius
echo -e '\E[37;44m'"\033[1m Starting FreeRadius\033[0m"
service radiusd restart
# test an authentication request to free radius
echo -e '\E[37;44m'"\033[1m Sending a test auth request to FreeRadius\033[0m"
radtest myusername mypassword 127.0.0.1 0 $RAD_AUTH_REQ_SECRET
echo " "
echo " "
echo -e '\E[37;44m'"\033[1m Job complete! Remember these details:\033[0m"
echo " "
echo -e '\E[37;44m'"\033[1m Your radius user for MySQL uses this as a password: $RAD_MYSQL_USER_PASS\033[0m"
echo -e '\E[37;44m'"\033[1m When you are trying to authenticate a user from localhost, this is the authentication secret for FreeRadius: $RAD_AUTH_REQ_SECRET\033[0m"
echo " "
echo -e '\E[37;44m'"\033[1m ############### IMPORTANT! ###############\033[0m"
echo -e '\E[37;44m'"\033[1m 1) You need to secure your mysql installation now by running: /usr/bin/mysql_secure_installation If you need help with this see http://xaviertidus.com/?p=47 for more information\033[0m"
echo -e '\E[37;44m'"\033[1m 2) A testing user was added to the radius database (username: myusername password: mypassword), don't forget to delete it when you are finished testing! It's a security risk. If you need help with this see http://xaviertidus.com/?p=49 for more information\033[0m"
echo -e '\E[37;44m'"\033[1m 3) If you plan to have external servers authenticating against your new FreeRadius server, you need to add the appropriate entries in the /etc/raddb/clients.conf file. If you need help with this see http://xaviertidus.com/?p=45 for more information\033[0m"
) 2>&1 | tee /var/log/FreeRadiusQuickScript-CentOS6-installer.log