#!/usr/bin/env bash

####################
## Initialization ##
####################

# Get paths and names
SN=$(echo ${0%.*} | sed 's,^./,,g') # Script name
SP="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" # Script path

# Load .env file for the script
if [[ -f ${SP}/${SN}.env ]]; then . ${SP}/${SN}.env; else echo "Missing ${SN}.env file"; exit 1; fi


###################
## Build process ##
###################

# Run container
docker run --rm --env-file ${SP}/certbot-dns-gandi.env -v ${OUT_DIR}:/challenge/certs ${CT_IMAGE}
