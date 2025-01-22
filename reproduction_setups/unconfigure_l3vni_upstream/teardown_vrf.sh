#!/bin/bash
# teardown_vrf.sh

echo "Removing VRF, bridge, and VXLAN..."
ip link del vrfv10 type vrf table 10 >> /dev/null 2>&1
ip link del brv10 type bridge >> /dev/null 2>&1
ip link del vxlan10 type vxlan id 10 dstport 4789 >> /dev/null 2>&1

echo "Reloading FRR with the no vrf / vpc config..."
/usr/lib/frr/frr-reload.py --debug --reload /etc/frr/frr-no-vrf.conf | grep 'no router'

if vtysh -c 'show run' | grep 'router bgp' | grep 'vrf'; then
        echo "BUG FOUND. It wasn't possible to delete 'router bgp ASN vrf VRF_NAME'. Stopping script"
        exit 1
fi
