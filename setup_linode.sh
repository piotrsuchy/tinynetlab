#!/bin/bash

LAB_TYPE=$1 

# git + docker installation
sudo apt update && sudo apt install -y git
sudo ./setup/setup_docker.sh

if [ "$LAB_TYPE" == "FRR" ]; then
    echo "-------------------------"
    echo "One-host FRR installation"
    echo "-------------------------"
    cd docker/frrready
    docker build -t frr:debian-11 -f Dockerfile .
    docker run --privileged --init --name frr -itd frr:debian-11 bash
    docker exec frr apt update 
    docker exec frr apt install -y git
    docker exec frr git clone https://github.com/piotrsuchy/frr
elif [ "$LAB_TYPE" == "CONTAINERLAB_FRR" ]; then
    echo "----------------------------------------------------"
    echo "Full installation of containerlab and basic topology"
    echo "----------------------------------------------------"
    bash -c "$(curl -sL https://get.containerlab.dev)"
    ./topos/frr01/start.sh
else 
    echo "Specify installation type, either: 'FRR' or 'CONTAINERLAB_FRR'"
fi
