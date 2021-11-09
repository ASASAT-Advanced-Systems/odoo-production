#!/bin/bash

# Variable
backupDir=
clientWebsite=
odooDatabase=
adminPassword=
backupCommand="curl -X POST -F “master_pwd=${adminPassword}” -F “name=${odooDatabase}” -F “backup_format=zip” -o ${backupDir}/${odooDatabase}.$(date +%F-%H-%M).zip https://${clientWebsite}/web/database/backup" 
deleteOldBackups="find ${backupDir} -type f -mtime +30 -name “${odooDatabase}.*.zip” -delete"

# Make a default directory for backup
mkdir -p ${backupDir}

# Write out current crontab
crontab -l > backup_cron

# Echo new cron into cron file
echo "15 2 * * * ${backupCommand} && ${deleteOldBackups}" >> backup_cron
# Cron Line Explaination
# * * * * * "command to be executed"
# - - - - -
# | | | | |
# | | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
# | | | ------- Month (1 - 12)
# | | --------- Day of month (1 - 31)
# | ----------- Hour (0 - 23)
# ------------- Minute (0 - 59)

# Install new cron file
crontab backup_cron
rm backup_cron
