#!/bin/bash

# Usage: ./script_name.sh <branch_name> <frr_version>

BRANCH=$1
FRR_VERSION=$2
CONTAINER=frrbuild
IMAGE_NAME="piotrsuchydocker/tinynetlab:frrbuild-${FRR_VERSION}-debian-11"
REPO="https://github.com/piotrsuchy/frr.git"

echo "Checking if docker image ${IMAGE_NAME} is running..."
if ! docker images ${IMAGE_NAME} | grep -q ${IMAGE_NAME}; then
    echo "Image ${IMAGE_NAME} does not exist. Attempting to pull from registry..."

    if ! docker pull ${IMAGE_NAME}; then
        echo "Pull failed. Attempting to build the image locally..."
        if ! docker build -t ${IMAGE_NAME} ./docker/frr/build; then
            echo "Failed to build the image."
            exit 1
        fi
    else
	echo "Pull successful"
    fi
fi

docker stop ${CONTAINER}
docker rm ${CONTAINER}

echo "Checking if the container ${CONTAINER} is running..."
if ! docker ps | grep -q ${CONTAINER}; then
    echo "Container frrbuild is not running. Starting container..."
    docker run --init --privileged -itd --name ${CONTAINER} ${IMAGE_NAME}
else
    echo "Docker container ${CONTAINER} is running properly"
fi

echo "Cloning the repo into the container on branch ${BRANCH}..."
if docker exec ${CONTAINER} git clone -b ${BRANCH} ${REPO}; then
    echo "Repository cloned successfully."
else
    echo "Failed to clone repository."
    exit 1
fi

echo "Building FRR .deb package..."
if docker exec ${CONTAINER} /bin/bash -c "cd frr && dpkg-buildpackage -b -rfakeroot --no-sign -Ppkg.frr.nortrlib,pkg.frr.nolua"; then
    echo ".deb package built successfully."
    docker exec ${CONTAINER} bash -c 'mkdir -p debs'
    docker exec ${CONTAINER} bash -c 'mv /root/*.deb debs'
    docker cp ${CONTAINER}:/root/debs .
else
    echo "Failed to build .deb package."
    exit 1
fi
