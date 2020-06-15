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
    https://api.gandi.net/v5/livedns/domains/${NO_WC_DOMAIN}/records/_acme-challenge 
echo ""
echo ""
sleep ${CHALLENGE_WAIT}
