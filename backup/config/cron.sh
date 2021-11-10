#!/bin/bash

# Write out current crontab
crontab -l > backup_cron

# Echo new cron into cron file
echo "15 2 * * * $(pwd)/backup.sh" >> backup_cron

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
