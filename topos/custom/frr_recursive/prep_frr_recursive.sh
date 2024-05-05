#!/bin/bash

HOST1=$1
HOST2=$2
HOST3=$3

# HOST1:
docker exec ${HOST1} /bin/bash -c 'ip address add 33.33.33.33/32 dev lo'
docker exec ${HOST1} /bin/bash -c 'ip route add 22.22.22.22 via 33.33.33.33 dev lo'

docker exec ${HOST1} /bin/bash -c 'ip link add dummy1 type dummy'
docker exec ${HOST1} /bin/bash -c 'ip address add 20.20.20.20/32 dev dummy1'
docker exec ${HOST1} /bin/bash -c 'ip link set dummy1 up'

# HOST2:
# docker exec -c ${HOST2} ip route add 33.33.33.33 via 20.20.20.20 dev eth0

# HOST3:
docker exec ${HOST3} /bin/bash -c 'ip address add 33.33.33.33/32 dev lo'
docker exec ${HOST3} /bin/bash -c 'ip link add dummy1 type dummy'
docker exec ${HOST3} /bin/bash -c 'ip address add 20.20.20.20/32 dev dummy1'
docker exec ${HOST3} /bin/bash -c 'ip link set dummy1 up'
