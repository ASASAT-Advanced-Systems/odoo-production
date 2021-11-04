#!/bin/bash

# Variable
envDir=/root/prod-almashriq
envFileName=.env
read -p "Please enter the production database name: " mainDB
read -p "Please enter the master password for the database: " adminPass
read -p "Please enter the desired database password: " dbPass
base64Pass=$(echo "${dbPass}" | base64)

# Generating the Env File
echo "PSQL_PASSWORD='${base64Pass}'
ADMIN_PASS='${adminPass}'
PRODUCTION_DATABASE='${mainDB}'
" > ${envDir}/${envFileName}

# -------------------------------------------------------------------------
# To run this file, type the following command in the terminal:
# - chmod +x /root/prod-almashriq/config/odoo-psql-pass-gen.sh
# -------------------------------------------------------------------------
