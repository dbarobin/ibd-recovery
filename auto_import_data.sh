#!/bin/bash
# FileName: auto_import_data.sh
# Copyright: DBA Team, KuGou Inc.
# Version: 1.0.0
# Author: robinwen
# Desc: Import data through recovery MySQL instance.
# CreatedAt: 2016/04/23 09:07:27 AM
# Updated: xxx
# UpdatedAt: xxxx/xx/xx xx:xx:xx PM
# UpdatedDesc: xxx
# Other: xxx

# File which include all of databases.
DB_FILE=""
# Directory which store all tables of specified database.
TABLE_DIR=""
# Backup command of MySQL.
MYSQL_CMD=""
# User used for backuping data, recommended use `root`
MYSQL_USR=""
# Password of user used for backuping data, recommended use encrypted password.
MYSQL_PWD=""
# Socket of user used for backuping data.
MYSQL_SOCK=""
# Backup directory.
BACK_DIR=""

# Create database which recoverd.
for db in `cat ${DB_FILE}`
do
	${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} <<EOF
	CREATE DATABASE $db DEFAULT CHARACTER SET utf8;
EOF
done

# Obtain all tables of database.
for db in `cat ${DB_FILE}`
do
	mkdir -p ${TABLE_DIR}/$db
	cd ${BACK_DIR}/$db && ls > ${TABLE_DIR}/$db/$db.txt
done

# Import data from backup files.
for db in `cat ${DB_FILE}`
do
	for table in `cat ${TABLE_DIR}/$db/$db.txt`
	do
		echo "[Info] Import $db.$table start at `date "+%Y-%m-%d %H:%M:%S"`."
		${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} <<EOF
		USE $db;
		SOURCE ${BACK_DIR}/$db/$table/${db}_${table}.sql;
EOF
		echo "[Info] Import $db.$table end at `date "+%Y-%m-%d %H:%M:%S"`."
	done
done
