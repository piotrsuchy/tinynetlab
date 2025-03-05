echo "Creating VRF, bridge, and VXLAN..."
ip link add vrfv3 type vrf table 3
ip link add brv3 type bridge
ip link add vxlan3 type vxlan id 3 local 192.168.9.20 dstport 4789
ip link set vxlan3 master brv3
ip link set brv3 master vrfv3

echo "Bringing them up and setting MTU..."
ip link set dev vrfv3 up
ip link set brv3 mtu 9060 up
ip link set vxlan3 mtu 9060 up

