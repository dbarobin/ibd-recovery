#!/bin/bash
# FileName: auto_info_collect.sh
# Copyright: DBA Team, KuGou Inc.
# Version: 1.0.0
# Author: robinwen
# Desc: Collect related information about MySQL database and tables and take notes of used command.
# CreatedAt: 2016/04/23 09:00:27 AM
# Updated: xxx
# UpdatedAt: xxxx/xx/xx xx:xx:xx PM
# UpdatedDesc: xxx
# Other: xxx

# File which include all of databases.
DB_FILE=""
# Directory which store all tables of specified database.
TABLE_DIR=""
# Client of MySQL.
MYSQL_CMD="/usr/local/mysql/bin/mysql"
# Admin command of MySQL.
MYSQL_ADMIN="/usr/local/mysql/bin/mysqladmin"
# Daemon commnad of MySQL.
MYSQL_SAFE="/usr/local/mysql/bin/mysqldsafe"
# User used for recovering data, recommended use `root`
MYSQL_USR=""
# Password of user used for recovering data, recommended use encrypted password.
MYSQL_PWD=""
# Socket of user used for recovering data.
MYSQL_SOCK=""
# Data directory of MySQL instance.
DATA_DIR=""
# Root directory of MySQL.
MYSQL_ROOT=""
# Backup directory of orphan ibd file.
BACK_DIR=""

# Config table structure.
CREATE TABLE `config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dbName` varchar(100) DEFAULT NULL,
  `tableName` varchar(100) DEFAULT NULL,
  `old` int(11) DEFAULT NULL,
  `new` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

# File which include all of databases.
${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} -Ne "SHOW DATABASES;" | grep -v information_schema | grep -v performance_schema | grep -v test | grep -v mysql > ${DB_FILE}

# Tables of specified database.
for db in `cat ${DB_FILE}`
do
	mkdir -p ${TABLE_DIR}/$db
	# Method 1.
	${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} -Ne "USE $db; SHOW TABLES;" > ${TABLE_DIR}/$db.txt
	# Method 2.
	find ${BACK_DIR}/$db -name "*.ibd" | perl -pe 's/(.*)\..*$/$1/;s{^.*/}{}' > ${TABLE_DIR}/$db.txt
done

# Analyze MySQL error log.
grep "InnoDB: Error: tablespace id and flags in file" mysql_error.log -A 1 | sed 's#^.*flags in file \x27./\(.*\)\x27 are \(\w\+\).*$#\1 \2#;s/^.*they are \(\w\+\) and .*$/\1/g' | sed "s/\//,/g" | sed "s/.ibd//g" | sed "s/\ /,/g" | sed "s/--//g" | sed "/^$/d"

# Load data to MySQL.
LOAD DATA INFILE '${TABLE_DIR}/ibd.txt' INTO TABLE config
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
(@col1,@col2,@col3,@col4) set dbName=@col1,tableName=@col2,old=@col3,new=@col4;

# Arguments of forcing recovery.
innodb_force_recovery = 6

# Shutdown MySQL instance command.
${MYSQL_ADMIN} u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} status
${MYSQL_ADMIN} u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} shutdown

# Startup MySQL.
nohup ${MYSQL_SAFE} --defaults-file=${MYSQL_ROOT}/my.cnf &
