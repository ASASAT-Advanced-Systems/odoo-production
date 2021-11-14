#!/bin/bash

# Variables
read -p "Please enter the desired client website: " clientWebsite
echo "CLIENT_WEBSITE='${clientWebsite}'" > $(dirname $(pwd))/.env

docker-compose up -d certbot
docker-compose stop nginx

# Generate Diffie-Hellman parameter
openssl dhparam -out $(pwd)/letsencrypt/ssl-dhparams.pem 2048

python3 $(pwd)/config/nginx.py
docker compose up -d nginx-ssl

# Change the execution rights for shell scripts
chmod +x $(pwd)/config/cron.sh

sh $(pwd)/config/cron.sh
