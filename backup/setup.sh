#!/bin/bash

# Variables
read -p "Please enter the production database name: " mainDB
echo "PRODUCTION_DATABASE='${mainDB}'" >> $(dirname $(pwd))/.env

# Change the execution rights for shell scripts
chmod +x $(pwd)/config/backup.sh
chmod +x $(pwd)/config/cron.sh

# Configure Backup
python3 $(pwd)/config/backup.py

sh $(pwd)/config/cron.sh
