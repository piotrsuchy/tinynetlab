#!/bin/bash
# setup_vrf.sh
#
# Creates the VRF + bridge + VXLAN interfaces, brings them up

echo "Creating VRF, bridge, and VXLAN..."
ip link add vrfv10 type vrf table 10 >> /dev/null 2>&1
ip link add brv10 type bridge >> /dev/null 2>&1
ip link add vxlan10 type vxlan id 10 dstport 4789 >> /dev/null 2>&1
ip link set vxlan10 master brv10>> /dev/null 2>&1
ip link set brv10 master vrfv10 >> /dev/null 2>&1


echo "Bringing them up..."
ip link set vrfv10 up >> /dev/null 2>&1
ip link set brv10 up >> /dev/null 2>&1
ip link set vxlan10 up >> /dev/null 2>&1


echo "Reloading FRR with the VRF/BGP config..."
/usr/lib/frr/frr-reload.py --debug --reload /etc/frr/frr-vrf.conf >> /dev/null 2>&1

echo "Setup complete."

