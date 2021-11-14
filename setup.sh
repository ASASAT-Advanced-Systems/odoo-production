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

# Variables
read -p "Please enter the master password for the database: " adminPass
read -p "Please enter the desired database password: " dbPass
base64Pass=$(echo "${dbPass}" | base64)

# Generating the Env File
echo "PRODUCTION_DIR='$(pwd)'
PSQL_PASSWORD='${base64Pass}'
ADMIN_PASS='${adminPass}'" > $(pwd)/.env

if promptyn "Do you wish to install the enterprise version?"; then
    echo "ENTERPRISE='yes'" >> $(pwd)/.env 
    git clone git@github.com:asasat/enterprise.git
else
    echo "ENTERPRISE='no'" >> $(pwd)/.env 
fi

addons=()
while true; do
    read -p "Please enter the addons directory name: (type q to exit) " addonsDir
    case ${addonsDir} in 
        [Qq]* ) break;;
        * ) 
            addons+=("${addonsDir}") 
            git clone git@github.com:ASASAT-Advanced-Systems/${addonsDir}.git
    esac
done

if [ ${addons} ]; then
    echo "ADDONS='${addons[*]}'" >> $(pwd)/.env 
fi

if promptyn "Do you wish to configure backups of the production database?"; then
    BACKUP="yes"
    read -p "Please enter the production database name: " mainDB
    echo "PRODUCTION_DATABASE='${mainDB}'" >> $(pwd)/.env
else
    BACKUP="no"
fi        

if promptyn "Is the domain ready?"; then
    SSL="yes"
	read -p "Please enter the desired client website: " clientWebsite
    echo "CLIENT_WEBSITE='${clientWebsite}'" > $(pwd)/.env
else
    SSL="no"
	read -p "Please enter IP address of the server: " ipAddress
    echo "IP_ADDRESS='${ipAddress}'" >> $(pwd)/.env
fi

# Downloading the requirements
pip3 install -r $(pwd)/requirements.txt

# Run python config scripts
python3 $(pwd)/config/nginx.py
python3 $(pwd)/config/odoo.py

# Make a default directory for logs
mkdir -p logs
chmod -R 777 logs/

# Run docker-compose.yml
docker-compose up -d odoo db nginx

# Configure SSL
if [ ${SSL} == "yes" ]; then
	docker-compose up -d certbot
	docker-compose stop nginx

    # Generate Diffie-Hellman parameter
    openssl dhparam -out $(pwd)/ssl/letsencrypt/ssl-dhparams.pem 2048

    python3 $(pwd)/ssl/config/nginx.py
	docker compose up -d nginx-ssl

    # Change the execution rights for shell scripts
    chmod +x $(pwd)/ssl/config/cron.sh

    sh $(pwd)/ssl/config/cron.sh
fi

if [ ${BACKUP} == "yes" ]; then
    # Change the execution rights for shell scripts
    chmod +x $(pwd)/backup/config/backup.sh
    chmod +x $(pwd)/backup/config/cron.sh

    # Configure Backup
    python3 $(pwd)/backup/config/backup.py

    sh $(pwd)/backup/config/cron.sh
fi
