#!/usr/bin/env bash
TAG=2.2.4
REGISTRY=harbor.honeur.org

echo "Downloading configuration files..."
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/refs/heads/main/local-installation/config/feder8-local-images.json --output feder8-local-images.json
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/refs/heads/main/local-installation/config/therapeutic-areas.json --output therapeutic-areas.json

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY="$(pwd)" -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock -v ./feder8-local-images.json:/opt/install-script/feder8-local-images.json -v ./therapeutic-areas.json:/opt/install-script/therapeutic-areas.json ${REGISTRY}/library/install-script:${TAG} feder8 init update-custom-concepts
