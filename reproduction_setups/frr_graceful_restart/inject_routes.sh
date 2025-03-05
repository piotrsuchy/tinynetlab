#!/bin/bash
PREFIXES=(
  "192.168.9.100/32"
  "192.168.9.101/32"
  "192.168.9.102/32"
  "192.168.9.103/32"
  "192.168.9.104/32"
  "192.168.9.105/32"
  "192.168.9.106/32"
  "192.168.9.107/32"
  "192.168.9.108/32"
)

IFACE="vrfv3"

NEXT_HOP="192.168.9.2"

echo "Injecting kernel routes for EVPN advertisement with next-hop ${NEXT_HOP}..."

for prefix in "${PREFIXES[@]}"; do
    ip route add "$prefix" via "$NEXT_HOP" dev "$IFACE"
    if [ $? -eq 0 ]; then
      echo "Added route $prefix via next-hop ${NEXT_HOP} on interface ${IFACE}"
    else
      echo "Failed to add route $prefix"
    fi
done

echo "Done injecting routes."

