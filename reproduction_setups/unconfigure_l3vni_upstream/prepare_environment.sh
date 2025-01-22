# Prepare two docker containers, one so that it injects routes (some small scale)
# The second one is where we provoke the bug

# create a network
docker network create --subnet=192.168.10.0/24 --driver bridge bridge_1

# create two containers, both in the same network
docker run -itd --init --privileged --network bridge_1 --hostname host1 --name host1 piotrsuchy/tinynetlab:frrtopotests-debian-11 bash
docker run -itd --init --privileged --network bridge_1 --hostname host2 --name host2 piotrsuchy/tinynetlab:frrtopotests-debian-11 bash

# adding debug file for both hosts
docker exec host1 bash -c 'touch /frr.log && chmod 777 /frr.log'
docker exec host2 bash -c 'touch /frr.log && chmod 777 /frr.log'

# setting loopback addresses for both hosts
docker exec host1 bash -c 'ip a add 10.40.0.1 dev lo'
docker exec host2 bash -c 'ip a add 10.40.0.2 dev lo'

# adding the routes to loopbacks of the other host on those hosts
docker exec host1 bash -c 'ip route add 10.40.0.2 via 192.168.10.2 dev eth0'
docker exec host2 bash -c 'ip route add 10.40.0.1 via 192.168.10.3 dev eth0'

# adding some routes on host2 so that the race condition after adding the interfaces happens more often
docker exec host2 bash -c 'for i in {1..255}; do ip route add 172.168.1.${i} dev lo; done'

# install some frr version on those two containers 
docker cp frr.deb host1:/
docker cp frr-pythontools.deb host1:/
docker cp frr.deb host2:/
docker cp frr-pythontools.deb host2:/

# install frr from a deb file
docker exec host1 bash -c 'dpkg --force-confold -i /frr.deb'
docker exec host1 bash -c 'dpkg --force-confold -i /frr-pythontools.deb'
docker exec host2 bash -c 'dpkg --force-confold -i /frr.deb'
docker exec host2 bash -c 'dpkg --force-confold -i /frr-pythontools.deb'

# HOST1: setup frr configuration and copy scripts
docker cp frr-vrf-host1.conf host1:/etc/frr/frr-vrf.conf
docker cp frr-no-vrf-host1.conf host1:/etc/frr/frr-no-vrf.conf
docker cp setup_vrf.sh host1:/
docker cp teardown_vrf.sh host1:/
docker cp loop.sh host1:/

# HOST2: setup frr configuration and run reload
docker cp frr-host2.conf host2:/etc/frr/frr.conf

# both hosts - sed bgpd=yes into daemons file
docker exec host1 sed -i '/bgpd=no/c\bgpd=yes' /etc/frr/daemons
docker exec host2 sed -i '/bgpd=no/c\bgpd=yes' /etc/frr/daemons

# both hosts - restart frr after new install
docker exec host1 /etc/init.d/frr restart
docker exec host2 /etc/init.d/frr restart

docker exec host1 bash -c '/setup_vrf.sh'
docker exec host2 bash -c '/usr/lib/frr/frr-reload.py --debug --reload /etc/frr/frr.conf'

echo "Setup completed. Now runnig loop.sh - looping setup_vrf.sh and teardown_vrf.sh X times on host1 to provoke the bug."
docker exec host1 bash -c '/loop.sh'
