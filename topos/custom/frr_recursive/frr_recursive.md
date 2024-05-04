# FRR RECURSIVE

## HOST 1

```txt
oot@1a1ced59b9dc:/# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 33.33.33.33/32 scope global lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
138: eth0@if139: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

```txt
root@1a1ced59b9dc:/# ip route
default via 172.18.0.1 dev eth0
22.22.22.22 via 33.33.33.33 dev lo
172.18.0.0/16 dev eth0 proto kernel scope link src 172.18.0.2
192.168.50.0/24 via 172.18.0.1 dev eth0
```

```txt
root@1a1ced59b9dc:/# vtysh -c 'show run'
Building configuration...

Current configuration:
!
frr version 10.0
frr defaults traditional
hostname 1a1ced59b9dc
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65001
 bgp router-id 172.18.0.2
 neighbor 172.18.0.3 remote-as 65001
 !
 address-family ipv4 unicast
  redistribute kernel
  redistribute static
 exit-address-family
exit
!
end
```

```txt

t@1a1ced59b9dc:/# vtysh -c 'show ip route'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 172.18.0.1, eth0, 00:19:06
K>* 22.22.22.22/32 [0/0] via 33.33.33.33, lo, 00:09:58
L * 33.33.33.33/32 is directly connected, lo, 00:10:04
C>* 33.33.33.33/32 is directly connected, lo, 00:10:04
C>* 172.18.0.0/16 is directly connected, eth0, 00:19:06
L>* 172.18.0.2/32 is directly connected, eth0, 00:19:06
K>* 192.168.50.0/24 [0/0] via 172.18.0.1, eth0, 00:15:01
```

## HOST 2

```txt
t@1ffb0b624c8e:/# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
140: eth0@if141: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:12:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.18.0.3/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

```txt
root@1ffb0b624c8e:/# ip route
default via 172.18.0.1 dev eth0
22.22.22.22 via 172.18.0.1 dev eth0 proto bgp metric 20
33.33.33.33 via 172.18.0.1 dev eth0
172.18.0.0/16 dev eth0 proto kernel scope link src 172.18.0.3
192.168.50.0/24 via 172.18.0.1 dev eth0 proto bgp metric 20
```

```txt
root@1ffb0b624c8e:/# vtysh -c 'show run'
Building configuration...

Current configuration:
!
frr version 10.0
frr defaults traditional
hostname 1ffb0b624c8e
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
router bgp 65001
 bgp router-id 172.18.0.3
 neighbor 172.18.0.2 remote-as 65001
exit
!
end
```

```txt
root@1ffb0b624c8e:/# vtysh -c 'show ip route'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

B   0.0.0.0/0 [200/0] via 172.18.0.1, eth0, weight 1, 00:13:52
K>* 0.0.0.0/0 [0/0] via 172.18.0.1, eth0, 00:19:06
B>  22.22.22.22/32 [200/0] via 33.33.33.33 (recursive), weight 1, 00:09:52
  *                          via 172.18.0.1, eth0, weight 1, 00:09:52
K>* 33.33.33.33/32 [0/0] via 172.18.0.1, eth0, 00:11:07
C>* 172.18.0.0/16 is directly connected, eth0, 00:19:06
L>* 172.18.0.3/32 is directly connected, eth0, 00:19:06
B>* 192.168.50.0/24 [200/0] via 172.18.0.1, eth0, weight 1, 00:13:52
```

