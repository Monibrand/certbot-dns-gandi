####################
## Initialization ##
####################

# Get paths and names
sn=$(echo ${0%.*} | sed 's,^./,,g') # Script name
sp="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" # Script path

# Load .env file for the script
if [[ -f ${sp}/${sn}.env ]]; then . ${sp}/${sn}.env; else echo "Missing ${sn}.env file"; exit 1; fi

# Calculate variables
IMG_NAME=$(echo "${REG}/${IMG_ORG}/${IMG_REPO}" | sed 's,^/,,g')
if [[ -z ${IMG_TAG} ]]; then IMG_TAG=$(date +"%s"); fi


###################
## Build process ##
###################

# Confirm build
echo ""
echo "Following images will be built:"
echo "  * ${IMG_NAME}:${IMG_TAG}"
echo "  * ${IMG_NAME}:latest"
read -p "Do you want to continue? (y/N): " cont
if [[ ! $cont =~ ^[Yy]$ ]]; then echo -e "Exiting...\n"; exit 1; fi
unset cont && echo ""

# If registry data is defined, log into registry
if [[ -n "${REG_USER}" && -n "${REG_PASS}" ]]; then
    echo "[$0] Logging into container registry ${REG}"
    docker login -u ${REG_USER} -p ${REG_PASS} ${REG}
    if [[ ${?} -eq 0 ]]; then echo "[${0}] Logged in"; else echo "[${0}] Login failed"; exit 1; fi
fi

# Build image
echo "[$0] Building image \"${IMG_NAME}:${IMG_TAG}\""
docker build --no-cache -t ${IMG_NAME}:${IMG_TAG} .
if [[ ${?} -eq 0 ]]; then echo "[${0}] Build done"; else echo "[${0}] Build failed"; exit 1; fi

# Tag image
echo "[$0] Tagging image as \"latest\""
docker tag ${IMG_NAME}:${IMG_TAG} ${IMG_NAME}:latest
if [[ ${?} -eq 0 ]]; then echo "[${0}] Tagging done"; else echo "[${0}] Tagging failed"; exit 1; fi

# Confirm push
echo ""
echo "Following images will be pushed:"
echo "  * ${IMG_NAME}:${IMG_TAG}"
echo "  * ${IMG_NAME}:latest"
read -p "Do you want to continue? (y/N): " cont
if [[ ! $cont =~ ^[Yy]$ ]]; then echo -e "Exiting...\n"; exit 1; fi
unset cont && echo ""

# Push image
echo "[$0] Pushing image ${IMG_NAME}:${IMG_TAG}"
docker push ${IMG_NAME}:${IMG_TAG}
if [[ ${?} -eq 0 ]]; then echo "[${0}] Push done"; else echo "[${0}] Push failed"; exit 1; fi

