#!/bin/bash

$INSTALLATION_TYPE=$1

# git + docker installation
sudo apt update && sudo apt install -y git
sudo ./docker_setup.sh

if [ $INSTALLATION_TYPE=="FRR" ]; then
    echo "One-host FRR installation"
    git clone https://github.com/FRRouting/frr.git
    cd frr
    docker build -t frr-debian:11 -f docker/debian/Dockerfile .
    docker run --privileged --init --name frr-deb -itd frr-debian-11 bash
	docker exec -it frr-deb git clone https://github.com/piotrsuchy/frr && bash
else
    echo "Full installation of containerlab and basic topology"
    bash -c "$(curl -sL https://get.containerlab.dev)"
    # containerlab create -t 3-tier-topology.yaml
fi
