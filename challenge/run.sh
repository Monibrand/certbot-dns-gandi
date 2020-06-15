#!/usr/bin/env bash

####################
## Initialization ##
####################

# Removing wildcard from the domain if exists
NO_WC_DOMAIN=$(echo ${DOMAIN} | sed -e 's/^*.//g')

# Checking if a dry-run execution or staging server certificates are needed
if [[ ${DRY_RUN} == 'true' ]]; then DRY_RUN='--dry-run'; else unset DRY_RUN; fi
if [[ ${STAGING} == 'true' ]]; then STAGING='--staging'; else unset STAGING; fi

# Getting the owner and group for the output files
DST_OWNER=$(ls -la /challenge/certs | head -2 | tail -1 | awk '{print $3}')
DST_GROUP=$(ls -la /challenge/certs | head -2 | tail -1 | awk '{print $4}')


################
## Validation ##
################

# Exit if owner of the process is not root
if [[ $(id -u) -ne 0 ]]; then echo "Run as root"; exit 1; fi

# Exit if check expiry is enabled and the certificate expiry date is too far
if [[ ${CHECK_EXPIRY} == 'true' ]]; then
    now=$(date "+%s")
    expiry=$(date -d "$(echo | openssl s_client -connect ${NO_WC_DOMAIN}:443 -servername ${NO_WC_DOMAIN} 2> /dev/null | openssl x509 -enddate -noout | cut -d'=' -f2)" "+%s")
    cur_days_remaining=$((($expiry - $now) / 60 / 60 / 24))  # Remaining days before expiry
    if [[ ${cur_days_remaining} -gt ${DAYS_REMAINING} ]]; then
        echo -e "\nCurrent certificate will expire in ${cur_days_remaining} days."
        echo -e "A new certificate will be requested when remaining ${DAYS_REMAINING} days or less days for expiration date.\n"
        exit 0
    else
        echo -e "\nCurrent certificate will expire in ${cur_days_remaining} days."
    fi
fi


#################################
## Certificate request process ##
#################################

echo -e "Requesting new certificates"

certbot certonly -n                             \
    ${DRY_RUN}                                  \
    ${STAGING}                                  \
    --agree-tos                                 \
    --manual-public-ip-logging-ok               \
    --debug                                     \
    -m ${EMAIL}                                 \
    --manual                                    \
    --preferred-challenges=dns                  \
    --manual-auth-hook /challenge/auth.sh       \
    --manual-cleanup-hook /challenge/cleanup.sh \
    -d ${DOMAIN}

if [[ ${?} -ne 0 ]]; then echo -e "Error generating certificates\n"; exit 1; fi

echo ""
echo "Certbot finished"
if [[ -d /etc/letsencrypt/live/${NO_WC_DOMAIN} ]]; then
    echo "Copying certificates to /challenge/certs"
    cp /etc/letsencrypt/live/${NO_WC_DOMAIN}/* /challenge/certs
    chown ${DST_OWNER}:${DST_GROUP} /challenge/certs/*
else
    echo "No certificates were created"
fi
echo "Certifciate generation finished"
echo ""
