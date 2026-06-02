#!/usr/bin/env bash

REGISTRY=harbor.honeur.org
VERSION="2.3.4"
TAG=$VERSION

DOCKER_HOST_CONFIG="${DOCKER_HOST_CONFIG:-172.17.0.1}"

# Proxy configuration — set both to the same value if your proxy handles HTTP and HTTPS
# Check if HTTP_PROXY is set or empty
if [[ -z "${HTTP_PROXY}" ]]; then
    echo -e "\e[31m[ERROR]\e[0m HTTP_PROXY environment variable is not set."
    echo "Please set it using: export HTTP_PROXY='http://your-proxy:port'"
    exit 1
fi
HTTP_PROXY="${HTTP_PROXY}"
HTTPS_PROXY="${HTTPS_PROXY:-$HTTP_PROXY}"

if systemctl show --property ActiveState docker &> /dev/null; then
    DOCKER_CERT_SUPPORT=true
else
    DOCKER_CERT_SUPPORT=false
fi

if [[ $OSTYPE == 'darwin'* ]]; then
  IS_MAC=true
else
  IS_MAC=false
fi

VERBOSITY_LEVEL="INFO" # Options: INFO, DEBUG

docker pull ${REGISTRY}/library/install-script:${TAG}

docker run --rm -it --name feder8-installer \
  -e VERBOSITY_LEVEL=${VERBOSITY_LEVEL} \
  -e CURRENT_DIRECTORY=${PWD} \
  -e IS_WINDOWS=false \
  -e IS_MAC=$IS_MAC \
  -e DOCKER_CERT_SUPPORT=$DOCKER_CERT_SUPPORT \
  -e ENVIRONMENT=PRD \
  -e CLEAN_UP_IMAGES=false \
  -e DOCKER_HOST_CONFIG=$DOCKER_HOST_CONFIG \
  -e HTTP_PROXY=$HTTP_PROXY \
  -e HTTPS_PROXY=$HTTPS_PROXY \
  -v ${PWD}/info_feder8_installation:/opt/install-script/info_feder8_installation \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${REGISTRY}/library/install-script:${TAG} feder8 init full
