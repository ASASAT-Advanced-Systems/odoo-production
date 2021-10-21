#!/bin/bash

# Variable
paramDir=/root/prod-${CLIENT}/ssl/nginx/certbot
paramFileName=ssl-dhparams
paramSize=2048

# Generate Diffie-Hellman parameter
openssl dhparam -out ${paramDir}/${paramFileName}.pem ${paramSize}

# -------------------------------------------------------------------------
# To run this file, type the following command in the terminal:
# - chmod +x /root/prod-${CLIENT}/ssl/scripts/dhparams-gen.sh
# -------------------------------------------------------------------------
