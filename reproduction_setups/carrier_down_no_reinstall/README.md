## Reproduction steps for [Routing Loop for IPv6 Ranges in par3](https://track.akamai.com/jira/browse/PAR3-161)

Dockerfile in this directory allows for two FRR releases - 8.4.2 and 10.1.1.
This bug was observed in FRR version 8.4.2 and is reliably reprudicible with this setup. In version 10.1.1 this bug should not occur.

### Instruction

1. Build the image with proper build-arg depending on which FRR version you want to target:<br>
``` docker build --build-arg FRR_VERSION=10 -t frr-reprod:frr10 .```

2. Create docker network and run routeserver and hypervisor containers:<br>
```
docker network create --ipv6 --subnet 2001:db8::/64 frr_reprod
docker run -it --privileged --name routeserver --network frr_reprod --ip6 2001:db8::2 --device /dev/net/tun:/dev/net/tun frr-reprod:frr10
docker run -it --privileged --name hypervisor --network frr_reprod --ip6 2001:db8::3 --device /dev/net/tun:/dev/net/tun frr-reprod:frr10
```

3. Start interactive terminal session with each container
4. Copy respective ```frr-<box_name>.conf``` configs to the containers
5. Start daemons on each container:
- per FRR-8.4.2:<br>
    ``` /usr/sbin/zebra -d && /usr/sbin/bgpd -d && /usr/sbin/staticd -d ```
- per FRR-10.1.1:<br> 
``` /usr/sbin/zebra -d && /usr/sbin/bgpd -d && /usr/sbin/staticd -d && /usr/sbin/mgmtd -d ```
6. Load configs on both boxes:<br>
```vtysh -f <path to frr.conf>```
* On FRR-10.1.1 box you might want to tweak nexthop-group timer to not wait 3 minutes for the update:<br>
    - enter ```vtysh```
    - ```configure```
    - ```zebra nexthop-group keep 20``` 20 seconds should be good enough
    - ```exit```
    - ```write memory```
7. Your ```vtysh -c 'show bgp summary'``` and ```ip -6 route``` outputs from hypervisor box should look like this:

```
root@6a873715ed5c:~# vtysh -c 'show bgp sum'

IPv4 Unicast Summary (VRF default):
BGP router identifier 192.168.9.3, local AS number 65001 vrf-id 0
BGP table version 0
RIB entries 0, using 0 bytes of memory
Peers 1, using 724 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor                  V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
51462d451a7f(2001:db8::2) 4      65002        10        11        0    0    0 00:00:10            0        0 N/A

Total number of neighbors 1

IPv6 Unicast Summary (VRF default):
BGP router identifier 192.168.9.3, local AS number 65001 vrf-id 0
BGP table version 4
RIB entries 4, using 768 bytes of memory
Peers 1, using 724 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor                  V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
51462d451a7f(2001:db8::2) 4      65002        10        11        0    0    0 00:00:10            2        2 N/A

Total number of neighbors 1
root@6a873715ed5c:~# ip -6 r
2001:db8::/64 dev eth0 proto kernel metric 256 pref medium
2001:db8:1::1 dev lo proto kernel metric 256 pref medium
2001:1111:1::/48 nhid 16 via 2001:db8::1 dev eth0 proto bgp metric 20 pref medium
fe80::/64 dev eth0 proto kernel metric 256 pref medium
default via 2001:db8::1 dev eth0 metric 1024 pref medium
default via fe80::42:c0ff:fea8:802 dev eth0 proto ra metric 1024 expires 20sec hoplimit 64 pref medium
```

A BGP session between the two should be established and we should have an entry ``` 2001:1111:1::/48 nhid 16 via 2001:db8::1``` learned through BPG

8. Add tap device on hypervisor, bring the link up and add a static route:<br>
```
ip tuntap add dev tap_test02 mode tap
ip link set tap_test02 up
ip neigh add fe80::2 lladdr 90:de:02:ff:ee:dd dev tap_test02 router
ip route add 2001:db8::1 via fe80::2 dev tap_test02
```

Watch as on FRR-8.4.2 box the entry for ```2001:1111:1::/48``` disappeared from kernel routing table. On FRR-10.1.1 that should not be the case. Then when you bring the carrier up:

```/usr/local/bin/simpletun -i tap_test02 -a -s -d &```

The state on 8.4.2 should not change. On 10.1.1 after timer for ```zebra nexthop-group``` elapses the kernel should be updated correctly:<br>
```2001:1111:1::/48 nhid 32 via fe80::2 dev tap_test02 proto bgp metric 20 pref medium```

On 8.4.2 you would need to delete and re-add the static route ```2001:db8::1``` with the carrier up to observer the correct behavior. 
