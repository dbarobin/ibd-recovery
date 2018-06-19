#!/bin/bash
# FileName: auto_recovery_data_postfix.sh
# Copyright: DBA Team, KuGou Inc.
# Version: 1.0.0
# Author: robinwen
# Desc: Post operation of recovering data through orphan ibd file.
# CreatedAt: 2016/04/23 08:59:27 AM
# Updated: xxx
# UpdatedAt: xxxx/xx/xx xx:xx:xx PM
# UpdatedDesc: xxx
# Other: xxx

# File which include all of databases.
DB_FILE=""
# Directory which store all tables of specified database.
TABLE_DIR=""
# Client of MySQL.
MYSQL_CMD=""
# User used for recovering data, recommended use `root`
MYSQL_USR=""
# Password of user used for recovering data, recommended use encrypted password.
MYSQL_PWD=""
# Socket of user used for recovering data.
MYSQL_SOCK=""

for db in `cat ${DB_FILE}`
do
	for table in `cat ${TABLE_DIR}/$db.txt`
	do
		# Import tablespace.
		echo "[Info] Import $db.$table tablespace start at `date "+%Y-%m-%d %H:%M:%S"`."
		${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} <<EOF
ALTER TABLE $db.$table IMPORT TABLESPACE;
EOF
		echo "[Info] Import $db.$table tablespace end at `date "+%Y-%m-%d %H:%M:%S"`."
	done
done
