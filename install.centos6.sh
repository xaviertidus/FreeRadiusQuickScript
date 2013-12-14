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



#Let's go!
yum install freeradius freeradius-mysql freeradius-utils mysql-server -y

service mysqld start

mysql -uroot << EOFMYSQL
CREATE DATABASE radius;
GRANT ALL PRIVILEGES ON radius.* TO radius@localhost IDENTIFIED BY "radpass";
flush privileges;
use radius;
SOURCE /etc/raddb/sql/mysql/schema.sql
exit
EOFMYSQL



### sql.conf
# backup original
mv /etc/raddb/sql.conf /etc/raddb/sql.conf.original
# get script version
wget 







) 2>&1 | tee /var/log/FreeRadiusQuickScript-CentOS6-installer.log