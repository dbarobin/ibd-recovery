#!/bin/bash
# FileName: auto_backup_data.sh
# Copyright: DBA Team, KuGou Inc.
# Version: 1.0.0
# Author: robinwen
# Desc: Backup data through recovery MySQL instance.
# CreatedAt: 2016/04/23 09:03:27 AM
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

for db in `cat ${DB_FILE}`
do
	for table in `cat ${TABLE_DIR}/$db.txt`
	do
		# Backup tables.
		echo "[Info] Backup table $db.$table start at `date "+%Y-%m-%d %H:%M:%S"`."
		mkdir -p ${BACK_DIR}/${db}/${table}
		${MYSQL_CMD} -u{$MYSQL_USR} -p${MYSQL_PWD} --socket=${MYSQL_SOCK} --routines --triggers --events --master-data=2 --single-transaction $db $table > ${BACK_DIR}/${db}/${table}/${db}_${table}.sql
		echo "[Info] Backup table $db.$table end at `date "+%Y-%m-%d %H:%M:%S"`."
	done
done
