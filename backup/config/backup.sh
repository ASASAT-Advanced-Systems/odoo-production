#!/bin/bash

# Variable
backupDir=
clientWebsite=
odooDatabase=
adminPassword=

# make a backup
curl -X POST \
	-F “master_pwd=${adminPassword}” \
	-F “name=${odooDatabase}” \
	-F “backup_format=zip” \
	-o ${backupDir}/${odooDatabase}.$(date +%F-%H-%M).zip \
	http://${clientWebsite}/web/database/backup

# delete old backups if older than 30 days
find ${backupDir} -type f -mtime +30 -delete
