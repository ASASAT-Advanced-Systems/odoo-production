#!/bin/bash

# Write out current crontab
crontab -l > renew_cron

# Echo new cron into cron file
echo "5 2 * * * cd $(dirname $(dirname $(pwd))) && docker-compose up -d certbot-ssl" >> renew_cron
echo "10 2 * * * docker exec nginx-ssl nginx -s reload " >> renew_cron

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
crontab renew_cron
rm renew_cron
