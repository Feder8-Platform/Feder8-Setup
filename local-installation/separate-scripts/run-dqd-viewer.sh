#!/usr/bin/env bash
set -ex

VERSION=1.0
TAG=$VERSION
REGISTRY=harbor.honeur.org
REPOSITORY=honeur
IMAGE=dqd-viewer

read -p "Please enter the path of your DQD: " FILE_PATH

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run \
--rm \
--name dqd-viewer \
-v $FILE_PATH:/dqd/dqd.json \
-p 3838:3838 \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
