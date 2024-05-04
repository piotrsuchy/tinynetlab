#!/bin/bash

# HOST1:
docker exec -c host1 ip address add 33.33.33.33/32 dev lo
docker exec -c host1 ip route add 22.22.22.22 via 33.33.33.33 dev lo

# HOST2:
# docker exec -c host2 ip route 22.22.22.22 via 172.18.0.1 dev eth0
docker exec -c host2 ip route add 33.33.33.33 via 172.18.0.1 dev eth0

# HOST3:

