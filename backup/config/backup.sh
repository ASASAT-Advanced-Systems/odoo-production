#!/bin/bash

# Variable
backupDir=
clientWebsite=
odooDatabase=
adminPassword=

# make a backup
wget \
  --post-data "master_pwd=${adminPassword}&name=${odooDatabase}&backup_format=zip" \
  -O ${backupDir}/${odooDatabase}.$(date +%F-%H-%M).zip \
  http://${clientWebsite}/web/database/backup

# delete old backups if older than 30 days
find ${backupDir} -type f -mtime +30 -delete
