#!/usr/bin/env bash

####################
## Initialization ##
####################

NO_WC_DOMAIN=$(echo ${CERTBOT_DOMAIN} | sed -e 's/^*.//g')
MAIN_DOMAIN=$(echo ${CERTBOT_DOMAIN} | awk -F '.' '{print $(NF-1)"."$NF}')
SUB_DOMAIN=$(echo ${CERTBOT_DOMAIN} | awk -F ".${MAIN_DOMAIN}" '{print $1}')
NO_WC_SUB_DOMAIN=$(echo ${SUB_DOMAIN} | sed -e 's/^*.//g')


#####################
## Cleanup process ##
#####################

echo "Deleting challenge record \"_acme-challenge.${domain}\""

curl                                                                           \
    --silent                                                                   \
    --request DELETE                                                           \
    --header "Authorization: Apikey ${GANDI_API_KEY}"                          \
    https://api.gandi.net/v5/livedns/domains/${MAIN_DOMAIN}/records/_acme-challenge.{NO_WC_SUB_DOMAIN}
