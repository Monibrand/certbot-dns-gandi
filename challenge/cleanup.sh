#!/usr/bin/env bash

####################
## Initialization ##
####################

NO_WC_DOMAIN=$(echo ${CERTBOT_DOMAIN} | sed -e 's/^*.//g')


#####################
## Cleanup process ##
#####################

echo "Deleting challenge record \"_acme-challenge.${domain}\""

curl                                                                           \
    --silent                                                                   \
    --request DELETE                                                           \
    --header "Authorization: Apikey ${GANDI_API_KEY}"                          \
    https://api.gandi.net/v5/livedns/domains/${NO_WC_DOMAIN}/records/_acme-challenge
