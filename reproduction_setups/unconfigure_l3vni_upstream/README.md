# Reproduction for unconfigure_l3vni issue

- move frr deb and frr-pythontools deb to this folder with names `frr.deb` and `frr-pythontools.deb`.
- I was using tinynetlab/docker/frr/topotest/Dockerfile with build argument frr_version = '9' (the same one for FRR10) to build the image that I called: frrtopotests:debian-11

```
docker build -t frrtopotests:debian-11 --build-arg=FRR_VERSION="9" -f Dockerfile .
```
The same docker image is in the dockerhub ready to be pulled:

```
https://hub.docker.com/layers/piotrsuchydocker/tinynetlab/frrtopotests-debian-11/images/sha256-5fbb0c6b32e4e61a840e02cb9caefdd940a848271f2e63c39b0995665b4b9b97
```

You can of course modify the names, IPs etc used in the bash scripts.
It can take between 1 to 100 iterations (very rarely even more) to reproduce this bug.

Use:

```
./prepare_environment.sh
```

That will spin up two basic docker containers and then prepare the setup for this bug - assign loopback interfaces, peer them with each other etc., finally use ./loop.sh which uses ./setup_vrf.sh to prepare the vrf and bgp instance on it, and ./teardown_vrf.sh that removes it and associated state.
