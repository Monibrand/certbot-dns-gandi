#!/usr/bin/env bash

################
## Data types ##
################

# Body of the record creation request
function rec_body {
cat <<EOF
{
  "items": [
    {
      "rrset_name": "${DOMAIN}",
      "rrset_type": "TXT",
      "rrset_ttl": ${CHALLENGE_TTL},
      "rrset_values": ["\"${CERTBOT_VALIDATION}\""]
    }
  ]
}
EOF
}


####################
## Initialization ##
####################

NO_WC_DOMAIN=$(echo ${CERTBOT_DOMAIN} | sed -e 's/^*.//g')
MAIN_DOMAIN=$(echo ${CERTBOT_DOMAIN} | awk -F '.' '{print $(NF-1)"."$NF}')
SUB_DOMAIN=$(echo ${CERTBOT_DOMAIN} | awk -F ".${MAIN_DOMAIN}" '{print $1}')
NO_WC_SUB_DOMAIN=$(echo ${SUB_DOMAIN} | sed -e 's/^*.//g')

############################
## Authentication process ##
############################
# Doc: https://api.gandi.net/docs/livedns/

echo ""
echo "Creating subdomain \"_acme-challenge\" for the DNS challenge"
printf "Response: "
curl                                                                           \
    --silent                                                                   \
    --request PUT                                                              \
    --header "Authorization: Apikey ${GANDI_API_KEY}"                          \
    --header "Content-Type:application/json"                                   \
    --data "$(rec_body)"                                                       \
    https://api.gandi.net/v5/livedns/domains/${MAIN_DOMAIN}/records/_acme-challenge.${SUB_DOMAIN}
echo ""
echo ""
sleep ${CHALLENGE_WAIT}
