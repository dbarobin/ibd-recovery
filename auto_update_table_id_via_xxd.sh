#!/bin/bash
# FileName: auto_update_table_id_via_xxd.sh
# Copyright: DBA Team, KuGou Inc.
# Version: 1.0.0
# Author: robinwen
# Desc: Update table id via xxd command.
# CreatedAt: 2016/04/23 09:02:27 AM
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
# Data directory of MySQL instance.
DATA_DIR=""
# Backup directory of orphan ibd file.
BACK_DIR=""

for db in `cat ${DB_FILE}`
do
	for table in `cat ${TABLE_DIR}/$db.txt`
	do
		# Update table id.
		echo "[Info] Update $db.$table table id via xxd start at `date "+%Y-%m-%d %H:%M:%S"`."

		# Get old table id from data dictionary.
		old=`${MYSQL_CMD} -u{MYSQL_USR} -p{MYSQL_PWD} --socket=${MYSQL_SOCK} -Ne "SELECT CASE LENGTH(LOWER(HEX(old))) WHEN 2 THEN LOWER(CONCAT('00',HEX(old))) WHEN 3 THEN LOWER(CONCAT('0',HEX(old))) ELSE NULL END as 'old' FROM robin.config WHERE dbName='$db' AND tableName='$table';"`
		# Get new table id from data dictionary.
		new=`${MYSQL_CMD} -u{MYSQL_USR} -p{MYSQL_PWD} --socket=${MYSQL_SOCK} -Ne "SELECT CASE LENGTH(LOWER(HEX(new))) WHEN 2 THEN LOWER(CONCAT('00',HEX(new))) WHEN 3 THEN LOWER(CONCAT('0',HEX(new))) ELSE NULL END as 'new' FROM robin.config WHERE dbName='$db' AND tableName='$table';"`

		# Update table id via xxd command.
		xxd ${DATA_DIR}/$db/$table.ibd | sed "/^0000020/s/$old/$new/g" | xxd -r > ${DATA_DIR}/$db/${table}_new.ibd
		# Remove old ibd file.
		cd ${DATA_DIR} && rm -f $db/$table.ibd
		# Rename temporary ibd file to permanent file.
		mv ${DATA_DIR}/$db/${table}_new.ibd ${DATA_DIR}/$db/$table.ibd

		# Update owner and access privileges.
		chown mysql:mysql ${DATA_DIR}/$db/$table.ibd
		chmod 660 ${DATA_DIR}/$db/$table.ibd
		echo "[Info] Update $db.$table table id via xxd end at `date "+%Y-%m-%d %H:%M:%S"`."
	done
done
