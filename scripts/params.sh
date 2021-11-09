#!/bin/bash

# Variable
paramDir=
paramFileName=ssl-dhparams
paramSize=2048

# Generate Diffie-Hellman parameter
openssl dhparam -out ${paramDir}/${paramFileName}.pem ${paramSize}
