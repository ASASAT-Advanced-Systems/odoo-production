#!/bin/bash

promptyn () {
    while true; do
        read -p "${1} " yn
        case ${yn} in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Variable
envDir=$(echo "$(pwd)")
envFileName=.env
read -p "Please enter the production database name: " mainDB
read -p "Please enter the master password for the database: " adminPass
read -p "Please enter the desired database password: " dbPass
base64Pass=$(echo "${dbPass}" | base64)
read -p "Please enter the addons directory: " addonsDir

if promptyn "Is the domain ready?"; then
    SSL="yes"
	read -p "Please enter the desired client website: " clientWebsite
else
    SSL="no"
	read -p "Please enter IP address of the server: " clientWebsite
fi

# Downloading the requirements
pip3 install -r ${envDir}/requirements.txt

# Change the execution rights for shell scripts
chmod +x ${envDir}/scripts/backup.sh
chmod +x ${envDir}/scripts/renew.sh
chmod +x ${envDir}/scripts/params.sh

# Generating the Env File
echo "PRODUCTION_DIR='${envDir}'
ADDONS_DIR='${addonsDir}'
PRODUCTION_DATABASE='${mainDB}'
CLIENT_WEBSITE='${clientWebsite}'
PSQL_PASSWORD='${base64Pass}'
ADMIN_PASS='${adminPass}'" > ${envDir}/${envFileName}

# Run python config scripts
python3 ${envDir}/config/nginx.py
python3 ${envDir}/config/odoo.py

# Run docker-compose.yml
docker-compose up -d odoo db nginx

# Configure SSL
if [ ${SSL} == "yes" ]; then
	docker-compose up -d certbot
	docker-compose stop nginx

	sh ${envDir}/scripts/params.sh
	docker compose up -d nginx-ssl certbot-ssl
	sh ${envDir}/scripts/renew.sh
fi

# Configure Backup
if [ ${SSL} == "yes" ]; then
	python3 ${envDir}/config/backup.py
	sh ${envDir}/scripts/backup.sh
fi
