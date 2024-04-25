#!/bin/bash

CONTAINER=$1
BRANCH=$2

DOCKER_PATH="/docker/debian/Dockerfile"

echo "Check if the container is running, if it isn't pull it / build it"
if ! docker ps | grep -q ${CONTAINER}; then
    echo "Container ${CONTAINER} is not running. Building it instead"
    docker build -t frrbuild -f ${DOCKER_PATH}
    docker run --init --privileged -d --name ${CONTAINER} frrbuild
fi

# path to build docker/debian/Dockerfile

echo "Cloning the repo in the container on branch ${BRANCH}"
if docker exec ${CONTAINER} git clone -b ${BRANCH} https://github.com/piotrsuchy/frr.git; then
    echo "Repository cloned successfully."
else
    echo "Failed to clone repository."
    exit 1
fi

echo "Building FRR .deb"
docker exec ${CONTAINER} cd frr && dpkg-buildpackage -b -rfakeroot --no-sign -Ppkg.frr.nortrlib,pkg.frr.nolua
