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
read -p "Please enter the master password for the database: " adminPass
read -p "Please enter the desired database password: " dbPass
base64Pass=$(echo "${dbPass}" | base64)

# Generating the Env File
echo "PRODUCTION_DIR='${envDir}'
PSQL_PASSWORD='${base64Pass}'
ADMIN_PASS='${adminPass}'" > ${envDir}/${envFileName}

if promptyn "Do you wish to install the enterprise version?"; then
    echo "ENTERPRISE='yes'" >> ${envDir}/${envFileName} 
    git clone git@github.com:asasat/enterprise.git
else
    echo "ENTERPRISE='no'" >> ${envDir}/${envFileName} 
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
    echo "ADDONS='${addons[*]}'" >> ${envDir}/${envFileName} 
fi
# read -p "Please enter the addons directory: " addonsDir

if promptyn "Do you wish to configure backups of the production database?"; then
    BACKUP="yes"
    read -p "Please enter the production database name: " mainDB
    echo "PRODUCTION_DATABASE='${mainDB}'" >> ${envDir}/${envFileName}
else
    BACKUP="no"
fi        

if promptyn "Is the domain ready?"; then
    SSL="yes"
	read -p "Please enter the desired client website: " clientWebsite
    echo "CLIENT_WEBSITE='${clientWebsite}'" > ${envDir}/${envFileName}
else
    SSL="no"
	read -p "Please enter IP address of the server: " ipAddress
    echo "IP_ADDRESS='${ipAddress}'" >> ${envDir}/${envFileName}
fi

# Downloading the requirements
pip3 install -r ${envDir}/requirements.txt

# Run python config scripts
python3 ${envDir}/config/nginx.py
python3 ${envDir}/config/odoo.py

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
    openssl dhparam -out ${envDir}/ssl/letsencrypt/ssl-dhparams.pem 2048

    python3 ${envDir}/ssl/config/nginx.py
	docker compose up -d nginx-ssl

    # Change the execution rights for shell scripts
    chmod +x ${envDir}/ssl/config/cron.sh

    sh ${envDir}/ssl/config/cron.sh
fi

if [ ${BACKUP} == "yes" ]; then
    # Change the execution rights for shell scripts
    chmod +x ${envDir}/backup/config/backup.sh
    chmod +x ${envDir}/backup/config/cron.sh

    # Configure Backup
    python3 ${envDir}/config/backup.py

    sh ${envDir}/backup/config/cron.sh
fi
