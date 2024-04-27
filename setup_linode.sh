#!/bin/bash

# This bash script should be used setup the linode to use docker and to bootstrap containerlab or a singular FRR instance.
# Usage: ./setup_linode.sh <FRR|CONTAINERLAB>

LAB_TYPE=$1 

sudo apt update && sudo apt install -y git
sudo ./setup/setup_docker.sh

if [ "$LAB_TYPE" == "FRR" ]; then
    echo "-------------------------"
    echo "One-host FRR installation"
    echo "-------------------------"

    if docker pull piotrsuchydocker/tinynetlab:frrready:debian-11; then
        echo "Docker image pulled successfully"
        IMAGENAME="piotrsuchydocker/tinynetlab:frrready:debian-11"
    else
        # if pull doesn't work - build the image instead
        echo "Docker image pull didn't work. Building the image locally instead"
        cd docker/frrready
        IMAGENAME="frrready:debian-11"
        docker build -t ${IMAGENAME} -f Dockerfile . || { echo "Docker build failed"; exit 1; }
    fi
    docker run --privileged --init --name frr -itd ${IMAGENAME} bash || { echo "Docker run failed"; exit 1; }

elif [ "$LAB_TYPE" == "CONTAINERLAB_FRR" ]; then
    echo "----------------------------------------------------"
    echo "Full installation of containerlab and basic topology"
    echo "----------------------------------------------------"

    bash -c "$(curl -sL https://get.containerlab.dev)"
    ./topos/frr01/start.sh
else 
    echo "Specify installation type, either: 'FRR' or 'CONTAINERLAB_FRR'"
    exit 1
fi
